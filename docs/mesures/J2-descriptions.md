# Jugement J2, descriptions seules (24 novembre 2026)

Après D15 (le titre n'est qu'un indice) et D16 (corrections du premier tour). Textes : 853 notices Joconde dont la
description parle de l'image (« premier plan », « représente », « figure », « scène »…), titre fourni à part.
Échantillon : 50 codes T2 et les 17 documents T1 disponibles (24 codes T1 en tout). Juge : Opus, à l'aveugle, même
grille ; 13 jugements contrôlés à la main, tous conformes.

| Type | Codes | Justes | Précision | Borne basse |
|---|---|---|---|---|
| T1 nom explicite | 17 | 4 | 0,24 | 0,10 |
| T2 chose décrite | 50 | 15 | 0,30 | 0,19 |

## Diagnostic

Le moteur suppose que **tout nom de la description désigne une chose représentée**. Dans une prose de notice, c'est
faux la plupart du temps :

1. **Locutions et noms sans référent** : « en bas » → bas (vêtement), « fait preuve » → Preuve, « au début des années
   1780 » → Début. Un nom sans déterminant dans une locution prépositionnelle ou après un verbe support ne désigne
   rien.
2. **Phrases qui ne parlent pas de l'image** : annotations (« annoté et daté en bas à la plume »), inscriptions au
   verso, provenance, biographie (« Claude, fils du peintre »), commentaire de style.
3. **Bon mot, mauvaise branche** : « niche » → niche d'église pour une stèle, « tronc » d'arbre → tronc d'église. Le
   libellé « parties intérieures d'une église: niche » pose un contexte (l'église) que le texte ne donne pas.
4. **Nom propre sans titre** : « Claude » → l'empereur, « Anne » → la sœur de Didon. Sans « saint », « sainte » ni
   autre indice, un prénom ne suffit pas.

## Corrections proposées

| Motif | Règle |
|---|---|
| 1 | un nom sans déterminant dans un groupe prépositionnel figé (« en bas », « à gauche », « au début ») ou complément d'un verbe support (« faire preuve », « prendre place ») n'est pas un référent |
| 2 | une phrase d'annotation, d'inscription, de provenance ou de biographie (annoté, daté, signé, inscription, verso, cat., acquis, né, fils de, élève de…) a la portée « œuvre » ou « histoire » |
| 3 | quand le libellé est « contexte : mot » et que le contexte n'est pas une catégorie du mot dans WordNet (« animaux prédateurs : lion » oui ; « parties d'une église : niche » non), le contexte doit être dit dans le texte, sinon candidat |
| 4 | T1 n'établit qu'un nom porteur d'un titre (saint, sainte…) ; un prénom seul reste candidat |

## Ce que cela dit du projet

Sur une prose de notice, l'étape difficile n'est pas Iconclass : c'est de savoir **quels mots du texte désignent ce que
l'image montre**. Les sorties d'Opus, où chaque entité est déjà une chose vue, posent beaucoup moins ce problème ; les
cartels et catalogues, beaucoup plus.
