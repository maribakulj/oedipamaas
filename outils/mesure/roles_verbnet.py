"""Le contrôle par VerbNet 3.3 des rôles que la PR #16 donne aux participes et aux sujets partagés (contre-expertise).

Usage : python outils/mesure/roles_verbnet.py VERBNET_DIR SITES.jsonl SORTIE.json

Pour chaque verbe anglais de VerbNet (membres des classes et sous-classes, une sous-classe héritant des cadres de sa
classe), les rôles thématiques de son sujet (le premier NP avant VERB, dans chaque cadre) et de son objet (le premier
NP après VERB, dans les cadres transitifs). Les rôles de VerbNet sont ramenés à ceux du guide du banc
(docs/BANC_GRAPHES.md) : Agent, Experiencer (sujet) → agent ; un Experiencer objet est compté ambigu pour patient ; Patient → patient ; Theme, Topic, Stimulus, Attribute, Pivot →
theme ; Location, Destination, Source → lieu ; Recipient → destinataire ; Instrument → instrument ; les autres → autre.
Puis, pour chaque site anglais où #16 change un participe en événement (participe présent : agent ; passé : patient),
le rôle que VerbNet donne à l'argument qui porte le participe : le sujet pour un participe présent ; pour un participe
passé, l'objet si le verbe a un cadre transitif, le sujet sinon (« fallen » : le sujet de fall). Le verdict :
  juste        VerbNet ne donne que le rôle de #16 (après réduction) ;
  faux         VerbNet ne donne jamais ce rôle ;
  ambigu       VerbNet donne ce rôle et d'autres (des classes différentes : le sens décide) ;
  hors_verbnet le verbe n'est pas dans VerbNet."""
import collections
import json
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

GUIDE = {"agent": "agent", "experiencer": "agent", "patient": "patient", "theme": "theme", "topic": "theme",
         "stimulus": "theme", "attribute": "theme", "pivot": "theme", "location": "lieu", "destination": "lieu",
         "source": "lieu", "recipient": "destinataire", "instrument": "instrument"}


def roles_du_cadre(frame):
    syn = frame.find("SYNTAX")
    if syn is None:
        return None, None
    items = list(syn)
    v = next((i for i, x in enumerate(items) if x.tag == "VERB"), None)
    if v is None:
        return None, None
    suj = next((x.get("value") for x in items[:v] if x.tag == "NP"), None)
    obj = items[v + 1].get("value") if v + 1 < len(items) and items[v + 1].tag == "NP" else None
    return suj, obj


def classe(node, cadres_herites, out):
    cadres = cadres_herites + [roles_du_cadre(f) for f in node.findall("FRAMES/FRAME")]
    for m in node.findall("MEMBERS/MEMBER"):
        v = m.get("name").replace("_", " ")
        for s, o in cadres:
            if s:
                out[v]["sujet"].add(GUIDE.get(s.lower(), "autre"))
            if o:   # un expérienceur objet (« frighten the child ») : le guide ne le range pas sous agent
                out[v]["objet"].add("experienceur" if o.lower() == "experiencer" else GUIDE.get(o.lower(), "autre"))
    for sc in node.findall("SUBCLASSES/VNSUBCLASS"):
        classe(sc, cadres, out)


def main():
    vn, sites, sortie = Path(sys.argv[1]), sys.argv[2], sys.argv[3]
    R = collections.defaultdict(lambda: {"sujet": set(), "objet": set()})
    for f in sorted(vn.glob("*.xml")):
        classe(ET.parse(f).getroot(), [], R)
    comptes = collections.Counter()
    distincts = collections.Counter()
    vus = set()
    detail = []
    for l in open(sites, encoding="utf-8"):
        x = json.loads(l)
        if x["l"] != "en" or x["op"] not in ("participes", "sujets_partages"):
            continue
        # le verbe et le rôle de chaque événement ajouté (un sujet partagé n'ajoute qu'un rôle : son verbe est dans
        # le graphe, il n'est pas contrôlé ici)
        for ev in x["apres"].split("evenement(v(")[1:]:
            ident, reste = ev.split("),", 1)
            verbe = reste.split(")", 1)[0].strip("'")
            role = None
            for r in x["apres"].split("role(v(" + ident + "),")[1:]:
                role = r.split(",")[0]
                break
            if role is None:
                continue
            e = R.get(verbe)
            if not e:
                v = "hors_verbnet"
            else:
                if x["op"] == "participes" and role == "patient":
                    rs = e["objet"] if e["objet"] else e["sujet"]
                elif x["op"] == "sujets_partages" and role == "patient":
                    rs = e["objet"]
                else:
                    rs = e["sujet"]
                if role == "patient" and "experienceur" in rs:
                    rs = (rs - {"experienceur"}) | {"patient", "autre"}     # l'expérienceur objet : ambigu
                v = "hors_verbnet" if not rs else ("juste" if rs == {role} else ("ambigu" if role in rs else "faux"))
            cle = (x["op"], role)
            comptes[cle + (v,)] += 1
            if (x["libelle"], verbe, role) not in vus:
                vus.add((x["libelle"], verbe, role))
                distincts[cle + (v,)] += 1
                detail.append({"n": x["n"], "libelle": x["libelle"], "op": x["op"], "verbe": verbe, "role": role,
                               "verdict": v, "verbnet": sorted((R.get(verbe) or {}).get("objet" if role == "patient" else "sujet", []))})
    out = {"verbes_verbnet": len(R),
           "sites": {"/".join(k): n for k, n in sorted(comptes.items())},
           "libelles_distincts": {"/".join(k): n for k, n in sorted(distincts.items())},
           "detail": detail}
    Path(sortie).write_text(json.dumps(out, ensure_ascii=False, indent=1), encoding="utf-8")
    print(json.dumps({"sites": out["sites"], "libelles_distincts": out["libelles_distincts"]}, ensure_ascii=False, indent=1))


if __name__ == "__main__":
    main()
