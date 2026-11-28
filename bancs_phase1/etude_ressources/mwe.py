import json, re, collections
WOLF=collections.defaultdict(set)
for line in open('/home/user/donnees/ressources/omw/omw-1.4/fra/wn-data-fra.tab'):
    if line.startswith('#'): continue
    s,_,l=line.rstrip('\n').split('\t'); WOLF[l.lower()].add(s)
blob='\n'.join(t for _,t in json.load(open('textes_fr.json'))).lower()
L=["jeune femme","jeune homme","jeune fille","main droite","main gauche","bras droit","premier plan|au premier plan","arrière-plan|arrière plan","côte à côte","à cheval","à genoux","pieds nus|pied nu","torse nu","mains jointes|main jointe","nature morte","scène de genre","peinture murale","tableau d'autel","fond d'or","livre d'heures","enfant de chœur","mise à mort","nouveau-né","couronne d'épines","couronne de laurier","peau de bête","tronc d'arbre","monument funéraire","copie d'atelier","couche picturale","cabinet d'amateur","arts libéraux","histoire naturelle","légende dorée","fuite en égypte","christ en croix","jugement de pâris","jugement dernier","vierge à l'enfant","mise au tombeau","descente de croix","adoration des mages","annonciation","dernière cène|la cène","sainte famille","saint jean-baptiste","jean-baptiste","marie-madeleine","saint jérôme","saint pierre","saint paul","saint georges","saint michel","saint martin","eau-forte","bas-relief","vieillard barbu","or bruni","livre ouvert","manteau rouge","ange gardien","ange gabriel|archange gabriel","archange michel","bible historiale","école vénitienne"]
rows=[]
for e in L:
    forms=e.split('|')
    n=sum(len(re.findall(r'(?<![\w])'+re.escape(f)+r'(?![\w])',blob)) for f in forms)
    if n==0: continue
    w=set().union(*[WOLF.get(f,set()) for f in forms])
    rows.append((forms[0],n,sorted(w)))
for r in rows: print(f"{r[0]}\t{r[1]}\t{len(r[2])}\t{' '.join(r[2])}")
print('total',len(rows),'presentes',sum(1 for r in rows if r[2]))
