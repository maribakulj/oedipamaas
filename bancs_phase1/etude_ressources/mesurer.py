import json, sys, collections, statistics, re
import spacy
nlp = spacy.load('fr_core_news_sm')
textes = json.load(open(sys.argv[1]))
WOLF = collections.defaultdict(set)
for line in open('/home/user/donnees/ressources/omw/omw-1.4/fra/wn-data-fra.tab'):
    if line.startswith('#'): continue
    s, _, l = line.rstrip('\n').split('\t'); WOLF[l].add(s)
WOLF_low = collections.defaultdict(set)
for l, ss in WOLF.items(): WOLF_low[l.lower()] |= ss
PM = {'NOUN':'n','VERB':'v','ADJ':'a','ADV':'r'}
# dedup textes identiques
uniq = list(dict.fromkeys(t for _, t in textes))
tok = collections.Counter(); docs = []
for doc in nlp.pipe(uniq):
    docs.append(doc)
    for t in doc:
        if t.pos_ in ('NOUN','VERB','ADJ','ADV','PROPN') and t.is_alpha:
            tok[(t.lemma_.lower() if t.pos_!='PROPN' else t.lemma_, t.pos_)] += 1
res = {}
def stats(keys):
    pres = [k for k in keys if k[0] in WOLF_low]
    pres_pos = [k for k in keys if k[1] in PM and any(s.endswith('-'+PM[k[1]]) for s in WOLF_low.get(k[0], ()))]
    return pres, pres_pos
out = {'textes_total': len(textes), 'textes_uniques': len(uniq), 'tokens_pleins': sum(tok.values())}
for pos in ['NOUN','VERB','ADJ','ADV','PROPN','ALL4']:
    keys = [k for k in tok if (k[1]==pos if pos!='ALL4' else k[1] in PM)]
    pres, pres_pos = stats(keys)
    toks = sum(tok[k] for k in keys); tpres = sum(tok[k] for k in pres_pos) if pos!='PROPN' else sum(tok[k] for k in pres)
    nb = [len([s for s in WOLF_low[k[0]] if k[1] not in PM or s.endswith('-'+PM[k[1]])]) for k in (pres_pos if pos!='PROPN' else pres)]
    out[pos] = dict(types=len(keys), types_presents_toutes_pos=len(pres), types_presents_meme_pos=len(pres_pos),
        absents_pct=round(100*(1-len(pres_pos if pos!='PROPN' else pres)/max(1,len(keys))),1),
        tokens=toks, tokens_couverts_pct=round(100*tpres/max(1,toks),1),
        synsets_moy_par_lemme=round(statistics.mean(nb),2) if nb else None,
        synsets_mediane=statistics.median(nb) if nb else None,
        synsets_moy_pondere_tokens=round(sum(n*tok[k] for n,k in zip(nb,(pres_pos if pos!='PROPN' else pres)))/max(1,tpres),2),
        monosemiques_pct=round(100*sum(1 for n in nb if n==1)/max(1,len(nb)),1))
json.dump(out, open('stats.json','w'), indent=1, ensure_ascii=False)
print(json.dumps(out, indent=1, ensure_ascii=False))
# listes
abs_ = sorted([k for k in tok if k[1] in PM and not any(s.endswith('-'+PM[k[1]]) for s in WOLF_low.get(k[0], ()))], key=lambda k:-tok[k])
open('absents.tsv','w').write('\n'.join(f'{k[0]}\t{k[1]}\t{tok[k]}\t{"autre_pos" if k[0] in WOLF_low else ""}' for k in abs_))
pres_ = sorted([k for k in tok if k[1] in PM and any(s.endswith('-'+PM[k[1]]) for s in WOLF_low.get(k[0], ()))], key=lambda k:-tok[k])
open('presents.tsv','w').write('\n'.join(f'{k[0]}\t{k[1]}\t{tok[k]}\t{len([s for s in WOLF_low[k[0]] if s.endswith("-"+PM[k[1]])])}' for k in pres_))
propn = sorted([k for k in tok if k[1]=='PROPN'], key=lambda k:-tok[k])
open('propn.tsv','w').write('\n'.join(f'{k[0]}\t{tok[k]}\t{len(WOLF.get(k[0],()))}' for k in propn))
# polylexicales : entrees WOLF a espaces presentes dans les textes (surface, minuscules)
mw = [l for l in WOLF_low if ' ' in l and len(l.split())<=4]
blob = '\n'.join(uniq).lower()
found = collections.Counter()
for l in mw:
    if re.search(r'(?<![\w])'+re.escape(l)+r'(?![\w])', blob): found[l] = len(re.findall(r'(?<![\w])'+re.escape(l)+r'(?![\w])', blob))
open('wolf_mwe_trouvees.tsv','w').write('\n'.join(f'{l}\t{n}\t{len(WOLF_low[l])}' for l,n in found.most_common()))
# candidats n-grammes (motifs) en surface lemmatisee
cand = collections.Counter()
for doc in docs:
    ts = [t for t in doc]
    for i in range(len(ts)):
        a = ts[i]
        if i+1 < len(ts):
            b = ts[i+1]
            if (a.pos_=='NOUN' and b.pos_=='ADJ') or (a.pos_=='ADJ' and b.pos_=='NOUN') or (a.pos_=='NOUN' and b.pos_=='PROPN') or (a.pos_ =='VERB' and b.pos_=='NOUN'):
                cand[(a.lemma_.lower()+' '+b.text.lower(), 2)] += 1
        if i+2 < len(ts):
            b, c = ts[i+1], ts[i+2]
            if a.pos_ in ('NOUN','PROPN') and b.lower_ in ('de','à','d\'','en') and c.pos_ in ('NOUN','PROPN'):
                cand[(a.lemma_.lower()+' '+b.lower_+(' ' if not b.lower_.endswith("'") else '')+c.text.lower(), 3)] += 1
open('candidats.tsv','w').write('\n'.join(f'{k[0]}\t{n}\t{"WOLF" if k[0] in WOLF_low else ""}' for k,n in cand.most_common() if n>=2))
