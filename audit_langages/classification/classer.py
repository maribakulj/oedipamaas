#!/usr/bin/env python3
"""Classe chaque fichier de l'inventaire (catégories a-g du contrat) d'après des règles écrites ici, lisibles et
réexécutables. Lecture seule. Usage : python3 -I classer.py INVENTAIRE.tsv SORTIE.tsv
La catégorie PRIMAIRE (première) sert aux sommes ; les suivantes sont des rôles secondaires.
« raisonne » : oui = dérive des conclusions logiques qui comptent pour une preuve ou un statut ;
               amont = produit les prémisses ou les définitions dont dépend un statut, sans en dériver ;
               non = ne dérive aucune conclusion de ce genre (mesure, transformation de format, glue)."""
import csv, re, sys

R = []   # (regex sur le chemin, catégories, raisonne, note)
def r(p, cat, rais, note=""): R.append((re.compile(p), cat, rais, note))

# ---- (a) historique : 0.2 et 1.0
r(r"^oedipamaas/(?!socle/)", "a", "non", "version 0.2 (ligne de base de la mesure finale)")
r(r"^oedipamaas/socle/__init__\.py$", "b", "non", "paquet")
r(r"^tests/test_moteur\.py|^tests/descriptions_synthetiques\.py", "a", "non", "tests de la 0.2")
r(r"^oedipamaas/socle/(moteur|coder|candidats|faits_description|compiler_decision)\.py$", "a", "non", "chaîne 1.0 (BM25, traits, décision apprise)")
r(r"^oedipamaas/socle/construire_base\.py$", "a,c", "non", "index de la chaîne 1.0 ; encore cité dans INSTALLATION.md")
r(r"^oedipamaas/socle/(cadres|cles|decision|description|lexique|noms|preuve|recherche|specialisation|traits)\.pl$", "a", "oui", "chaîne 1.0 (décision apprise compilée en clauses, preuve lexicale)")
r(r"^tests/test_socle_(cles|decision|lexique|libelles|moteur_ordres|recherche|arbre|notation|morphologie)\.py$", "a", "non", "tests de la chaîne 1.0 ; arbre, notation et morphologie sont partagés")
r(r"^oedipamaas/socle/(projection|hypotheses)\.pl$", "a", "oui", "premier jet de projection / méthode des profils, abandonnés")
r(r"^outils/sujets/", "a", "non", "méthode des profils, abandonnée")
r(r"^outils/vertical/projeter\.pl$", "a", "non", "mesure du premier jet de projection")
# ---- (f) oracle indépendant
r(r"^tests/oracle/", "f", "oui", "oracle Python du noyau, écrit d'après NOYAU.md seul")
r(r"^semantique_reference/", "f", "oui", "interpréteur de référence du langage (stdlib seule)")
r(r"^tests/(semantique_reference_gen|test_semantique_reference|test_semantique_reference_exemples|test_oracle)\.py$", "f", "non", "tests / générateurs de l'oracle")
r(r"^oedipamaas/socle/satisfaction_reference\.pl$", "f,b", "oui", "moteur de référence en Prolog (même langage que le noyau)")
# ---- (b) moteur actuel : exécution
r(r"^oedipamaas/socle/(commande|oedipamaas|udpipe|conllu)\.pl$", "b", "non", "CLI et frontière CoNLL-U")
r(r"^oedipamaas/socle/(assertions|requetes|satisfaction|verificateur)\.pl$", "b", "oui", "noyau logique")
r(r"^oedipamaas/socle/(connaissances_commun|connaissances_en|connaissances_fr)\.pl$", "b", "amont", "module K actuel (WordNet 3.0 + WOLF)")
r(r"^oedipamaas/socle/(arbre|notation|morphologie|libelles|sens)\.pl$", "b", "amont", "pièces partagées Iconclass (arbre, notation, morphologie) ; libelles et sens chargés par la CLI ou la chaîne 1.0")
r(r"^oedipamaas/socle/raisonnement\.pl$", "b,a", "oui", "ancien raisonnement T1/T2, encore appelé par la CLI et par K (normaliser_nom)")
r(r"^oedipamaas/socle/sujets\.pl$", "a,b", "non", "méthode abandonnée ; fournit encore ferme/2 (mots-outils) au compilateur C3")
# ---- (d) transformations symboliques
r(r"^oedipamaas/socle/(codage|inclusion)\.pl$", "d,b", "oui", "couche Iconclass du noyau ; comparateur d'inclusion")
r(r"^oedipamaas/socle/(normalisation|interpretation|mondes|scene)\.pl$", "d", "amont", "canonisation C7 ; lecteur C7 (texte -> assertions) ; ancrage")
r(r"^oedipamaas/socle/(definitions|requetes_iconclass|libelles_iconclass|compilation)\.pl$", "d", "amont", "compilateur C3 (libellés -> requêtes)")
r(r"^outils/(definitions/(compiler_definitions|lire_libelles)|requetes/compiler_(tout|vertical))\.pl$", "c,d", "non", "compilation hors ligne des définitions et requêtes")
r(r"^outils/requetes/comparer\.pl$", "e,d", "oui", "compare les requêtes compilées aux références par inclusion (appelle le noyau)")
# ---- (c) compilation des connaissances
r(r"^oedipamaas/socle/compiler_(iconclass|wordnet|ressources)\.py$", "c,b", "non", "transcription Iconclass, WordNet, liens morphosémantiques, WOLF en faits Prolog (aucune provenance fine)")
r(r"^outils/ressources/(lexiques|manifeste|commun)\.py$", "c,e", "non", "lexiques normalisés, manifestes (prototype de construction de K)")
r(r"^outils/inference/morphosemantique\.py$", "c", "non", "lecture xls (xlrd)")
# ---- (g) dépendances NLP
r(r"^oedipamaas/socle/stanza_textes\.py$|^outils/definitions/stanza_conllu\.py$", "g,c", "non", "Stanza -> CoNLL-U (frontière)")
r(r"^outils/ressources/corpus\.py$", "g,e", "non", "lemmatisation Stanza du corpus de mesure")
# ---- (e) mesure et expériences
r(r"^outils/noyau/injection\.py$", "e,f", "non", "test des tests (mutation du noyau)")
r(r"^outils/bancs/comparer_formel\.py$", "e,f", "non", "recalcule les statuts par l'interpréteur de référence")
r(r"^outils/graphes/premisses\.pl$", "e", "oui", "appelle les prédicats du noyau pour l'admissibilité des prémisses")
r(r"^outils/(bancs|croise|graphes|inference|mesure|moisson|qualification|ressources|definitions|vertical)/", "e", "non", "outil de mesure ou d'expérience")
r(r"^tests/(test_bancs|test_croise|test_graphes|test_mesure_bancs)\.py$", "e", "non", "tests des outils de mesure")
# ---- tests Prolog / pytest d'orchestration
r(r"^tests/plunit/", "b", "non", "tests du moteur en Prolog, écrits d'après la spécification (ils vérifient, ne dérivent rien)")
r(r"^tests/test_plunit\.py$", "b", "non", "lance chaque fichier plunit")
r(r"^tests/", "b", "non", "tests")

rows = list(csv.DictReader(open(sys.argv[1], encoding="utf-8"), delimiter="\t"))
out = []
for x in rows:
    for p, cat, rais, note in R:
        if p.search(x["chemin"]):
            out.append((x["chemin"], x["langage"], int(x["lignes_code"]), cat, rais, note)); break
    else:
        raise SystemExit("non classé : " + x["chemin"])
with open(sys.argv[2], "w", encoding="utf-8") as f:
    f.write("chemin\tlangage\tlignes_code\tcategories\traisonne\tnote\n")
    for o in out: f.write("\t".join(map(str, o)) + "\n")
import collections
som = collections.defaultdict(collections.Counter); n = collections.defaultdict(collections.Counter)
for c, l, k, cat, rais, note in out:
    som[cat.split(",")[0]][l] += k; n[cat.split(",")[0]][l] += 1
print("catégorie primaire : lignes python / prolog ; fichiers python / prolog")
for c in "abcdefg":
    print(c, som[c]["python"], som[c]["prolog"], "|", n[c]["python"], n[c]["prolog"])
print("total", sum(sum(v.values()) for v in som.values()))
rs = collections.Counter(); 
for c, l, k, cat, rais, note in out: rs[(rais, l)] += k
print(dict(rs))
