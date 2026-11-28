import collections, statistics, re, json
WOLF = collections.defaultdict(set)
for line in open('/home/user/donnees/ressources/omw/omw-1.4/fra/wn-data-fra.tab'):
    if line.startswith('#'): continue
    s,_,l = line.rstrip('\n').split('\t'); WOLF[l].add(s)
PM={'NOUN':'n','VERB':'v','ADJ':'a','ADV':'r'}
def syn(l,p): return {s for s in WOLF.get(l,()) if s.endswith('-'+PM[p])}
# corrections manuelles d'erreurs de lemmatisation Stanza (constatees a la main)
CORR = {('peinter','VERB'):'peindre',('giser','VERB'):'gésir',('gîter','VERB'):'gésir',('éau-forte','NOUN'):'eau-forte',('gri','ADJ'):'gris',
 ('nue','ADJ'):'nu',('assoupis','ADJ'):'assoupi',('poinconner','VERB'):'poinçonner',('entrouvrerter','VERB'):'entrouvrir',('oiner','VERB'):'oindre',
 ('flaire','VERB'):'flairer',('dépourvoir','VERB'):'dépourvu',('défailler','VERB'):'défaillir',('agenouillés','NOUN'):'agenouillé',('lasse','NOUN'):'las',
 ('sainte','NOUN'):'saint',('grâces','NOUN'):'grâce',('actes','NOUN'):'acte',('assises','VERB'):'asseoir',('déchoir','ADJ'):'déchu',('bénissant','NOUN'):'bénir'}
ORD = re.compile(r'^[xvi]+e$|^ier$')
rows=[]
for f in ('absents.tsv','presents.tsv'):
    for line in open(f):
        p=line.rstrip('\n').split('\t'); rows.append((p[0],p[1],int(p[2])))
tot=collections.Counter(); cov=collections.Counter(); ttot=collections.Counter(); tcov=collections.Counter()
nb=collections.defaultdict(list); vrais_abs=collections.defaultdict(list); pron=[]; exclus=[]
for l,p,n in rows:
    if ORD.match(l): exclus.append((l,n)); continue
    l2 = CORR.get((l,p), l)
    s = syn(l2,p)
    if not s and p=='VERB':
        s2 = syn("s'"+l2,p) | syn('se '+l2,p)
        if s2: pron.append(l2); s=s2
    tot[p]+=1; ttot[p]+=n
    if s: cov[p]+=1; tcov[p]+=n; nb[p].append((len(s),n))
    else: vrais_abs[p].append((l2,n))
out={}
for p in PM:
    ns=[a for a,_ in nb[p]]
    out[p]=dict(types=tot[p], absents=tot[p]-cov[p], absents_pct=round(100*(tot[p]-cov[p])/tot[p],1), tokens=ttot[p], tokens_absents_pct=round(100*(ttot[p]-tcov[p])/ttot[p],1),
      syn_moy=round(statistics.mean(ns),2), syn_med=statistics.median(ns), syn_moy_tok=round(sum(a*b for a,b in nb[p])/sum(b for _,b in nb[p]),2), mono_pct=round(100*sum(1 for a in ns if a==1)/len(ns),1), max=max(ns))
T=sum(tot.values()); C=sum(cov.values()); TT=sum(ttot.values()); TC=sum(tcov.values())
alln=[a for p in PM for a,_ in nb[p]]; allw=[(a,b) for p in PM for a,b in nb[p]]
out['TOTAL']=dict(types=T, absents=T-C, absents_pct=round(100*(T-C)/T,1), tokens=TT, tokens_absents_pct=round(100*(TT-TC)/TT,1), syn_moy=round(statistics.mean(alln),2), syn_med=statistics.median(alln), syn_moy_tok=round(sum(a*b for a,b in allw)/sum(b for _,b in allw),2), mono_pct=round(100*sum(1 for a in alln if a==1)/len(alln),1))
out['pronominaux_recuperes']=pron; out['ordinaux_exclus']=exclus
# noms propres, casse respectee
pp=[]; 
for line in open('propn.tsv'):
    l,n,_=line.rstrip('\n').split('\t'); n=int(n)
    forms={l[:1].upper()+l[1:], '-'.join(x[:1].upper()+x[1:] for x in l.split('-'))}
    hit=set().union(*[WOLF.get(f,set()) for f in forms])
    pp.append((l,n,len(hit)))
pt=len(pp); pc=sum(1 for x in pp if x[2]); ptt=sum(x[1] for x in pp); ptc=sum(x[1] for x in pp if x[2])
out['PROPN']=dict(types=pt, presents=pc, absents_pct=round(100*(pt-pc)/pt,1), tokens=ptt, tokens_absents_pct=round(100*(ptt-ptc)/ptt,1))
out['PROPN_absents']=[(l,n) for l,n,h in sorted(pp,key=lambda x:-x[1]) if not h][:80]
out['PROPN_presents']=[(l,n,h) for l,n,h in sorted(pp,key=lambda x:-x[1]) if h]
for p in PM: out['abs_'+p]=sorted(vrais_abs[p],key=lambda x:-x[1])[:60]
json.dump(out,open('stats2.json','w'),ensure_ascii=False,indent=0)
for k,v in out.items(): print(k, v)
