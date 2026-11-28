#!/usr/bin/env python3
"""Fabrique des bases K à un seul défaut chacune (mutants), à partir d'un k.tsv sain, avec le résultat attendu.

Usage : python3 -I fabriquer_mutants.py K_SAIN.tsv SORTIE_DIR

Les attendus sont écrits à la main d'après spec/SPEC.md (jamais d'après la sortie d'un contrôleur). Ils sont rangés dans
SORTIE_DIR/attendus.tsv : « mutant<TAB>code<TAB>identifiant », un mutant sans ligne = aucune violation attendue. Le
mutant M15 est un témoin : une entrée légitimement attestée, que le contrôle ne doit pas rejeter.
"""
import sys
from pathlib import Path

CHAMPS = {  # nom des colonnes, après le code de type
    "S": "id ressource version sha256 couche_licence famille",
    "A": "id de_ressource de_version de_id vers_ressource vers_version vers_id methode statut attestation",
    "E": "id genre lemme synset source localisateur nature detail statut attestation couche_licence",
    "V": "id lemme synset rang familles entrees statut",
}
CHAMPS = {t: c.split() for t, c in CHAMPS.items()}


def lire(chemin):
    k = []
    for ligne in Path(chemin).read_text(encoding="utf-8").splitlines():
        t, *c = ligne.split("\t")
        k.append((t, dict(zip(CHAMPS[t], c))))
    return k


def ecrire(k, chemin):
    Path(chemin).write_text("\n".join("\t".join([t] + [d[c] for c in CHAMPS[t]]) for t, d in k) + "\n", encoding="utf-8")


def un(k, t, pred=lambda d: True):
    return next(d for tt, d in k if tt == t and pred(d))


def copie(k):
    return [(t, dict(d)) for t, d in k]


def main(sain, sortie):
    out = Path(sortie)
    out.mkdir(parents=True, exist_ok=False)
    base = lire(sain)
    attendus = []                                   # (mutant, code, id)

    def emettre(nom, k, attendu):
        ecrire(k, out / f"{nom}.tsv")
        attendus.extend((nom, c, i) for c, i in sorted(set(attendu)))

    def e1(k):  return un(k, "E", lambda d: d["source"] == "src:wolf")
    def e2(k):  return un(k, "E", lambda d: d["source"] == "src:wonef-f")
    ecrire(base, out / "M00_sain.tsv")

    # M01 : entrée dont la source n'existe pas -> pas de source, donc pas d'alignement non plus (spec INV1 et INV7)
    k = copie(base); x = e1(k); x["source"] = "src:fantome"
    emettre("M01_source_inexistante", k, [("INV1_SOURCE", x["id"]), ("INV7_ENTREE_ALIGNEE", x["id"])])
    # M02 : une source sans version -> toutes ses entrées violent INV1
    k = copie(base); un(k, "S", lambda d: d["id"] == "src:wolf")["version"] = ""
    emettre("M02_source_sans_version", k, [("INV1_SOURCE", d["id"]) for t, d in k if t == "E" and d["source"] == "src:wolf"])
    # M03 : alignement sans version du côté de la ressource
    k = copie(base); a = un(k, "A"); a["de_version"] = ""
    emettre("M03_alignement_sans_version_source", k, [("INV2_ALIGN_VERSION", a["id"])])
    # M04 : alignement sans version du pivot (INV2, et INV3 puisque le pivot n'est plus « WordNet 3.0 »)
    k = copie(base); a = un(k, "A"); a["vers_version"] = ""
    emettre("M04_alignement_sans_version_pivot", k, [("INV2_ALIGN_VERSION", a["id"]), ("INV3_PIVOT", a["id"])])
    # M05 : alignement vers un identifiant absent du pivot ; les entrées de ce synset perdent leur alignement (INV7)
    k = copie(base); a = un(k, "A", lambda d: d["de_ressource"] == "WOLF"); ancien = a["vers_id"]; a["vers_id"] = "99999999-n"
    emettre("M05_pivot_inconnu", k, [("INV3_PIVOT", a["id"])] +
            [("INV7_ENTREE_ALIGNEE", d["id"]) for t, d in k if t == "E" and d["source"] == "src:wolf" and d["synset"] == ancien])
    # M06 : un vote attesté
    k = copie(base); v = un(k, "V"); v["statut"] = "attestee"
    emettre("M06_vote_atteste", k, [("INV4_VOTE_CLASSE", v["id"])])
    # M07 : une entrée attestée sans attestation
    k = copie(base); x = e1(k); x["statut"] = "attestee"
    emettre("M07_attestee_sans_attestation", k, [("INV5_ATTESTATION", x["id"])])
    # M08 : une entrée non attestée qui porte une attestation
    k = copie(base); x = e1(k); x["attestation"] = "relu par un agent"
    emettre("M08_non_attestee_avec_attestation", k, [("INV5_ATTESTATION", x["id"])])
    # M09 : identifiant d'entrée en double
    k = copie(base); x = e1(k); k.append(("E", dict(x)))
    emettre("M09_identifiant_double", k, [("INV6_UNICITE", x["id"])])
    # M10 : un alignement retiré ; les entrées de ce synset et de cette source ne sont plus alignées
    k = copie(base); a = un(k, "A", lambda d: d["de_ressource"] == "WOLF")
    k = [(t, d) for t, d in k if d is not a]
    emettre("M10_entree_non_alignee", k, [("INV7_ENTREE_ALIGNEE", d["id"]) for t, d in k
                                          if t == "E" and d["source"] == "src:wolf" and d["synset"] == a["vers_id"]])
    # M11 : un rang de vote faux (deux familles annoncées pour une seule)
    k = copie(base); v = un(k, "V", lambda d: d["rang"] == "1"); v["rang"] = "2"
    emettre("M11_rang_faux", k, [("INV8_VOTE", v["id"])])
    # M12 : deux versions d'une même famille comptées pour deux voix (la règle des familles du § 7.3 de MESURE_RESSOURCES)
    k = copie(base); v = un(k, "V", lambda d: d["familles"] == "WoNeF"); x = un(k, "E", lambda d: d["id"] == v["entrees"])
    k.append(("S", {"id": "src:wonef-p", "ressource": "WoNeF", "version": "0.1 precision (2013-07-03)", "sha256": "f" * 64,
                    "couche_licence": "CC-BY-SA", "famille": "WoNeF"}))
    k.append(("A", {"id": "aln:src:wonef-p:" + x["synset"], "de_ressource": "WoNeF", "de_version": "0.1 precision (2013-07-03)",
                    "de_id": "eng-30-" + x["synset"], "vers_ressource": "WordNet", "vers_version": "3.0",
                    "vers_id": x["synset"], "methode": "essai", "statut": "non_attestee", "attestation": ""}))
    y = dict(x); y["id"] = "lex:src:wonef-p:" + x["synset"] + ":" + x["lemme"]; y["source"] = "src:wonef-p"
    k.append(("E", y))
    v["rang"] = "2"; v["entrees"] = ",".join(sorted([x["id"], y["id"]]))
    emettre("M12_deux_versions_deux_voix", k, [("INV8_VOTE", v["id"])])
    # M13 : un vote qui cite une entrée inexistante
    k = copie(base); v = un(k, "V"); v["entrees"] = v["entrees"] + ",lex:src:fantome:00000000-n:x"
    emettre("M13_vote_entree_inexistante", k, [("INV8_VOTE", v["id"])])
    # M14 : couche de licence incohérente avec la source
    k = copie(base); x = e1(k); x["couche_licence"] = "MIT"
    emettre("M14_licence_incoherente", k, [("INV9_LICENCE", x["id"])])
    # M15 : TÉMOIN. Une entrée attestée AVEC attestation est légitime : aucune violation.
    k = copie(base); x = e1(k); x["statut"] = "attestee"; x["attestation"] = "relecture nommée, guide G, 28/11"
    emettre("M15_temoin_attestee_legitime", k, [])
    # M16 : un statut hors du domaine
    k = copie(base); x = e2(k); x["statut"] = "probable"
    emettre("M16_statut_hors_domaine", k, [("INV5_ATTESTATION", x["id"])])
    # M17 : un vote sans entrée
    k = copie(base); v = un(k, "V"); v["entrees"] = ""
    emettre("M17_vote_sans_entree", k, [("INV8_VOTE", v["id"])])
    (out / "attendus.tsv").write_text("".join(f"{m}\t{c}\t{i}\n" for m, c, i in attendus), encoding="utf-8")
    print(len({m for m, _, _ in attendus}), "mutants avec violation attendue ;", len(attendus), "violations attendues")


if __name__ == "__main__":
    main(*sys.argv[1:])
