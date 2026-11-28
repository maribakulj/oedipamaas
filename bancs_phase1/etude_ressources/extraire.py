import json, glob, collections, re, sys
SW_FR = set("le la les un une des de du et est dans sur avec qui que au aux par pour son sa ses il elle ne pas".split())
SW_EN = set("the a an of and is in on with who that to by for his her he she not are".split())
def lang(t):
    w = re.findall(r"[a-zà-ÿ']+", t.lower())
    f = sum(x in SW_FR for x in w); e = sum(x in SW_EN for x in w)
    return 'fr' if f > e else 'en'
textes = []; desaccord = 0; n_cas_fr = 0; n_var_fr = 0
for f in sorted(glob.glob('/home/user/donnees/bancs_phase1/dev/*.json')):
    for cas in json.load(open(f)):
        lc = cas.get('langue')
        if lc == 'fr':
            textes.append(('cas', cas['description'])); n_cas_fr += 1
        for v in cas.get('variantes') or []:
            lv = v.get('langue') or ({'fr':'en','en':'fr'}[lc] if v.get('variation')=='traduction' else lc)
            d = lang(v['description'])
            if d != lv: desaccord += 1
            if lv == 'fr':
                textes.append(('var', v['description'])); n_var_fr += 1
json.dump(textes, open(sys.argv[1], 'w'), ensure_ascii=False)
print('cas fr', n_cas_fr, 'variantes fr', n_var_fr, 'desaccord heuristique', desaccord)
