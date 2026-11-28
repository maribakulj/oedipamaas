#!/usr/bin/env python3
"""Inventaire mécanique des fichiers .py et .pl suivis par git.

Bibliothèque standard seulement. Lecture seule du dépôt.
Usage : python3 inventaire.py <racine_depot> <dossier_sortie>
"""
import ast
import collections
import io
import os
import re
import subprocess
import sys
import tokenize

DEPOT = sys.argv[1] if len(sys.argv) > 1 else "/home/user/oedipamaas-v3-wt"
SORTIE = sys.argv[2] if len(sys.argv) > 2 else "/home/user/donnees/audit_langages"
INTERNES_CONTRAT = {"oedipamaas", "semantique_reference", "outils"}
STDLIB = set(sys.stdlib_module_names)

anomalies = []      # (chemin, texte)
basename_seul = []  # (chemin_source, chemin_cible) correspondances par nom de base seulement


def git(*args):
    return subprocess.run(["git", "-C", DEPOT, *args], capture_output=True, text=True, check=True).stdout


def lire(chemin):
    with open(os.path.join(DEPOT, chemin), "rb") as f:
        brut = f.read()
    try:
        return brut.decode("utf-8"), True
    except UnicodeDecodeError:
        anomalies.append((chemin, "non décodable en UTF-8, relu en latin-1"))
        return brut.decode("latin-1"), False


# ---------- Python ----------

def modules_internes_depot(fichiers_py):
    tops = set(INTERNES_CONTRAT)
    for p in fichiers_py:
        parts = p.split("/")
        tops.add(parts[0][:-3] if len(parts) == 1 else parts[0])
    return tops


def py_lignes_code(src, chemin):
    """Lignes de code : ni vides, ni commentaires, ni docstrings (chaîne seule dans une instruction)."""
    code, doc = set(), set()
    try:
        logique = []  # tokens significatifs de l'instruction courante
        for tok in tokenize.generate_tokens(io.StringIO(src).readline):
            if tok.type in (tokenize.COMMENT, tokenize.NL, tokenize.INDENT,
                            tokenize.DEDENT, tokenize.ENCODING, tokenize.ENDMARKER):
                continue
            if tok.type == tokenize.NEWLINE:
                if logique:
                    seuls_chaine = len(logique) == 1 and logique[0].type == tokenize.STRING
                    for t in logique:
                        plage = range(t.start[0], t.end[0] + 1)
                        (doc if seuls_chaine else code).update(plage)
                logique = []
                continue
            logique.append(tok)
        if logique:
            for t in logique:
                code.update(range(t.start[0], t.end[0] + 1))
    except (tokenize.TokenError, IndentationError, SyntaxError) as e:
        anomalies.append((chemin, f"tokenize échoue ({e}); lignes_code en repli heuristique"))
        return sum(1 for l in src.splitlines() if l.strip() and not l.strip().startswith("#"))
    return len(code - doc)


def py_analyse(chemin, src, internes_tops):
    res = {"internes": [], "externes": [], "janus": False, "subprocess_swipl": False,
           "pl_charge": False, "main": False, "candidats_from": set()}
    try:
        arbre = ast.parse(src, filename=chemin)
    except SyntaxError as e:
        anomalies.append((chemin, f"ast.parse échoue ({e}); imports non relevés"))
        return res
    chaines = []
    for noeud in ast.walk(arbre):
        if isinstance(noeud, ast.Import):
            for a in noeud.names:
                _classer_py(a.name, res, internes_tops)
        elif isinstance(noeud, ast.ImportFrom):
            if noeud.level and noeud.level > 0:
                res["internes"].append("." * noeud.level + (noeud.module or ""))
                continue
            _classer_py(noeud.module or "", res, internes_tops)
            for a in noeud.names:
                if noeud.module:
                    res["candidats_from"].add(f"{noeud.module}.{a.name}")
        elif isinstance(noeud, ast.Constant) and isinstance(noeud.value, str):
            chaines.append(noeud.value)
        elif isinstance(noeud, ast.If):
            t = noeud.test
            if (isinstance(t, ast.Compare) and isinstance(t.left, ast.Name) and t.left.id == "__name__"
                    and len(t.ops) == 1 and isinstance(t.ops[0], ast.Eq)
                    and isinstance(t.comparators[0], ast.Constant) and t.comparators[0].value == "__main__"):
                res["main"] = True
    if res["janus"] is False and any(
            (i == "janus_swi" or i.startswith("janus_swi.")) for i in res["externes"] + res["internes"]):
        res["janus"] = True
    utilise_subprocess = bool(re.search(r"\bsubprocess\b", src))
    if utilise_subprocess and any("swipl" in c for c in chaines):
        res["subprocess_swipl"] = True
    if any(re.search(r"\.pl$", c.strip()) for c in chaines if len(c) < 300):
        res["pl_charge"] = True
    res["internes"] = sorted(set(res["internes"]))
    res["externes"] = sorted(set(res["externes"]))
    res["candidats_from"] = res["candidats_from"] - set()
    return res


STEMS_DEPOT = set()  # noms de fichiers .py du dépôt, pour résoudre les imports frères


def _classer_py(nom, res, internes_tops):
    if not nom:
        return
    top = nom.split(".")[0]
    if top in internes_tops:
        res["internes"].append(nom)
    elif top in STDLIB:
        return
    elif top in STEMS_DEPOT:
        res["internes"].append("~" + nom)  # import frère résolu par nom de fichier (sys.path)
    else:
        res["externes"].append(top)


def nomme_dans(texte, chemin):
    """Vrai si le chemin complet ou le nom de base (à frontières de mots) apparaît dans le texte."""
    if chemin in texte:
        return True
    base = os.path.basename(chemin)
    if base == "__init__.py":
        return False
    return re.search(r"(?<![\w.])" + re.escape(base) + r"(?!\w)", texte) is not None


def modules_nommes_par_py(chemin, tops):
    """Nom pointé d'un fichier .py du dépôt (sans __init__)."""
    p = chemin[:-3].replace("/", ".")
    if p.endswith(".__init__"):
        p = p[: -len(".__init__")]
    return p


# ---------- Prolog ----------

def pl_nettoyer(src):
    """Retire les commentaires % et /* */ ; renvoie (texte_sans_commentaires, lignes_de_code)."""
    out = []
    lignes_code = set()
    ligne = 1
    etat = "code"
    quote = None
    i, n = 0, len(src)
    while i < n:
        c = src[i]
        if c == "\n":
            ligne += 1
            out.append("\n")
            if etat == "line":
                etat = "code"
            i += 1
            continue
        if etat == "block":
            if src.startswith("*/", i):
                etat = "code"
                out.append("  ")
                i += 2
            else:
                out.append(" ")
                i += 1
            continue
        if etat == "line":
            out.append(" ")
            i += 1
            continue
        if etat == "code":
            if src.startswith("/*", i):
                etat = "block"
                out.append("  ")
                i += 2
                continue
            if c == "%":
                etat = "line"
                out.append(" ")
                i += 1
                continue
            if c in "'\"`":
                etat, quote = "quote", c
                lignes_code.add(ligne)
                out.append(c)
                i += 1
                continue
            if not c.isspace():
                lignes_code.add(ligne)
            out.append(c)
            i += 1
            continue
        # etat == "quote"
        lignes_code.add(ligne)
        if c == "\\" and i + 1 < n:
            out.append(c + src[i + 1])
            if src[i + 1] == "\n":
                ligne += 1
            i += 2
            continue
        if c == quote:
            if i + 1 < n and src[i + 1] == quote:
                out.append(c + c)
                i += 2
                continue
            etat, quote = "code", None
        out.append(c)
        i += 1
    return "".join(out), len(lignes_code)


def pl_premier_argument(texte, debut):
    """Renvoie le premier argument (texte brut) d'un appel dont la parenthèse ouvrante est en `debut`."""
    profondeur, i, n = 0, debut, len(texte)
    dans_q = None
    arg_debut = debut + 1
    while i < n:
        c = texte[i]
        if dans_q:
            if c == dans_q:
                dans_q = None
        elif c in "'\"":
            dans_q = c
        elif c in "([{":
            profondeur += 1
        elif c in ")]}":
            profondeur -= 1
            if profondeur == 0:
                return texte[arg_debut:i].strip()
        elif c == "," and profondeur == 1:
            return texte[arg_debut:i].strip()
        i += 1
    return None


def pl_analyse(chemin, texte_nu):
    res = {"internes": [], "externes": [], "main": False, "appels": 0}
    for m in re.finditer(r"\b(use_module|consult|ensure_loaded|include)\s*\(", texte_nu):
        if m.group(1) == "include" and not re.search(r":-\s*$", texte_nu[max(0, m.start() - 10):m.start()]):
            continue  # include/N utilisé comme prédicat, pas comme directive
        res["appels"] += 1
        arg = pl_premier_argument(texte_nu, m.end() - 1)
        if not arg:
            anomalies.append((chemin, f"argument de {m.group(1)} non relevé"))
            continue
        elements = [e.strip() for e in arg.strip("[]").split(",")] if arg.startswith("[") else [arg]
        for e in elements:
            lib = re.match(r"library\(\s*'?([\w]+)", e)
            if lib:
                res["externes"].append(lib.group(1))
            else:
                nom = e.strip("'\"")
                if nom:
                    res["internes"].append(nom)
    if re.search(r":-\s*\[", texte_nu):
        anomalies.append((chemin, "chargement par liste `:- [fichier]` présent, non relevé"))
    if re.search(r":-\s*initialization\s*\(\s*main", texte_nu):
        res["main"] = True
    res["internes"] = sorted(set(res["internes"]))
    res["externes"] = sorted(set(res["externes"]))
    return res


# ---------- principal ----------

def main():
    fichiers = sorted(git("ls-files", "*.py", "*.pl").splitlines())
    fichiers = [f for f in fichiers if f.endswith((".py", ".pl"))]
    tops = modules_internes_depot([f for f in fichiers if f.endswith(".py")])
    STEMS_DEPOT.update(os.path.basename(f)[:-3] for f in fichiers if f.endswith(".py"))
    contenus = {}
    for f in fichiers:
        if not os.path.exists(os.path.join(DEPOT, f)):
            anomalies.append((f, "suivi par git mais absent du disque"))
            contenus[f] = ""
            continue
        contenus[f], _ = lire(f)
    py_fichiers = [f for f in fichiers if f.endswith(".py")]
    pl_fichiers = [f for f in fichiers if f.endswith(".pl")]

    # tests : fichiers de tests/ (.py) qui importent ou nomment le module
    tests_py = [f for f in py_fichiers if f.startswith("tests/")]
    tests_tous = [f for f in fichiers if f.startswith("tests/")]
    tests_analyse = {}
    for t in tests_py:
        tests_analyse[t] = py_analyse(t, contenus[t], tops)

    py_info = {}
    for f in py_fichiers:
        py_info[f] = py_analyse(f, contenus[f], tops)

    # appele_par_python pour les .pl : nommé dans un .py
    appele = {}
    for pl in pl_fichiers:
        base = os.path.basename(pl)
        par_chemin = [p for p in py_fichiers if pl in contenus[p]]
        par_base = [p for p in py_fichiers if p not in par_chemin and nomme_dans(contenus[p], pl)]
        appele[pl] = bool(par_chemin or par_base)
        for p in par_base:
            basename_seul.append((p, pl))

    lignes = []
    for f in fichiers:
        src = contenus[f]
        total = len(src.splitlines())
        if f.endswith(".py"):
            langage = "python"
            code_n = py_lignes_code(src, f)
            info = py_info[f]
            internes = info["internes"]
            externes = info["externes"]
            appelle = "oui" if (info["janus"] or info["subprocess_swipl"] or info["pl_charge"]) else "non"
            appele_par = "n/a"
            point = "oui" if info["main"] else "non"
            # teste_par : tests qui importent ce module ou le nomment
            mod = modules_nommes_par_py(f, tops)
            teste = []
            for t in tests_py:
                # import exact du module (import x.y ou from x import y, candidat x.y)
                if t == f:
                    continue
                importe = mod in tests_analyse[t]["internes"] or mod in tests_analyse[t]["candidats_from"]
                nomme = nomme_dans(contenus[t], f)
                if nomme and f not in contenus[t]:
                    basename_seul.append((t, f))
                if importe or nomme:
                    teste.append(t)
            teste = sorted(set(teste))
        else:
            langage = "prolog"
            texte_nu, code_n = pl_nettoyer(src)
            code_n = code_n  # lignes de code avec commentaires % et /* */ retirés
            info = pl_analyse(f, texte_nu)
            internes = info["internes"]
            externes = info["externes"]
            appelle = "n/a"
            appele_par = "oui" if appele[f] else "non"
            point = "oui" if info["main"] else "non"
            teste = sorted(set(t for t in tests_tous if t != f and nomme_dans(contenus[t], f)))
        dernier = git("log", "-1", "--format=%as", "--", f).strip() or "inconnu"
        lignes.append({
            "chemin": f, "langage": langage, "lignes": total, "lignes_code": code_n,
            "imports_internes": ";".join(internes), "imports_externes": ";".join(externes),
            "appelle_prolog": appelle, "appele_par_python": appele_par,
            "teste_par": ";".join(teste), "point_entree": point, "dernier_commit": dernier,
        })

    os.makedirs(SORTIE, exist_ok=True)
    colonnes = ["chemin", "langage", "lignes", "lignes_code", "imports_internes", "imports_externes",
                "appelle_prolog", "appele_par_python", "teste_par", "point_entree", "dernier_commit"]
    with open(os.path.join(SORTIE, "inventaire.tsv"), "w", encoding="utf-8") as fo:
        fo.write("\t".join(colonnes) + "\n")
        for r in lignes:
            fo.write("\t".join(str(r[c]).replace("\t", " ").replace("\n", " ") for c in colonnes) + "\n")

    # agrégation par dossier sur deux niveaux
    agg = collections.defaultdict(lambda: [0, 0])
    for r in lignes:
        parties = r["chemin"].split("/")[:-1]
        dossier = "/".join(parties[:2]) if parties else "."
        cle = (dossier, r["langage"])
        agg[cle][0] += 1
        agg[cle][1] += r["lignes_code"]
    with open(os.path.join(SORTIE, "par_dossier.tsv"), "w", encoding="utf-8") as fo:
        fo.write("dossier\tlangage\tfichiers\tlignes_code\n")
        for (dossier, langage) in sorted(agg):
            n, lc = agg[(dossier, langage)]
            fo.write(f"{dossier}\t{langage}\t{n}\t{lc}\n")

    # rapport de contrôle (sortie texte pour l'orchestrateur)
    print(f"fichiers: {len(lignes)} (py={len(py_fichiers)}, pl={len(pl_fichiers)})")
    for lang in ("python", "prolog"):
        sous = [r for r in lignes if r["langage"] == lang]
        print(f"{lang}: fichiers={len(sous)} lignes={sum(r['lignes'] for r in sous)} "
              f"lignes_code={sum(r['lignes_code'] for r in sous)}")
    print("py appelant prolog (oui):", sum(1 for r in lignes if r["appelle_prolog"] == "oui"))
    for lang in ("python", "prolog"):
        ext = collections.Counter()
        for r in lignes:
            if r["langage"] != lang:
                continue
            for m in set(filter(None, r["imports_externes"].split(";"))):
                ext[m] += 1
        print(f"modules externes {lang} (nb fichiers):")
        for m, k in sorted(ext.items(), key=lambda x: (-x[1], x[0])):
            print(f"  {m}: {k}")
    print("imports frères résolus par nom (~) :", sum(r["imports_internes"].count("~") > 0 for r in lignes), "fichiers")
    print("pl appelés par python:", sum(1 for r in lignes if r["appele_par_python"] == "oui"),
          "/", len(pl_fichiers))
    print("points d'entrée:", sum(1 for r in lignes if r["point_entree"] == "oui"))
    print("anomalies:", len(anomalies))
    for chemin, txt in anomalies:
        print(f"  ANOM {chemin}: {txt}")
    print("correspondances par nom de base seulement (non chemin complet):", len(basename_seul))
    for src_, cible in basename_seul:
        print(f"  BASE {src_} -> {cible}")


if __name__ == "__main__":
    main()
