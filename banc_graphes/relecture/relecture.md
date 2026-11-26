# Relecture humaine du banc de graphes (échantillon)

Pour chaque texte : chaque élément est-il juste d'après le guide (docs/BANC_GRAPHES.md, § 3) ? Les jugements vont dans relecture.tsv (colonnes jugement : juste, faux ou douteux ; correction : libre), et ce qui manque au graphe dans la ligne « manque » du texte.

## developpement — k 21, indetermine (en)

> A carriage lies overturned in the ditch and its horses are gone; how the accident happened is not shown.

1. entité carriage#e1 « A carriage » ; propriétés : overturned
2. entité ditch#e2 « the ditch »
3. entité horse#e3 « its horses » [polarite=neg]
4. événement accident#v1 « the accident » (nom d'action accident)
5. relation carriage#e1 —in→ ditch#e2
6. relation horse#e3 —of→ carriage#e1

## developpement — k 51, indetermine (en) — annoté deux fois

> The engraving shows only the lady's face; a fashion note printed below mentions a mantelet.

1. entité engraving#e1 « The engraving » [portee=oeuvre]
2. entité lady#e2 « the lady »
3. entité face#e3 « the lady's face »
4. entité note#e4 « a fashion note » ; propriétés : fashion, printed [portee=oeuvre]
5. entité mantelet#e5 « a mantelet » [portee=source]
6. événement mention#v1 « mentions » — agent : note#e4; theme : mantelet#e5 [portee=oeuvre]
7. relation face#e3 —of→ lady#e2

## developpement — k 21, negatif (en)

> A rider digs his spurs into his horse's flanks; the frightened animal bolts and the rider is thrown into the ditch.

1. entité rider#e1 « A rider »
2. entité spur#e2 « his spurs »
3. entité horse#e3 « his horse »
4. entité flank#e4 « flanks »
5. entité animal#e5 « the frightened animal » ; propriétés : frightened
6. entité rider#e6 « the rider »
7. entité ditch#e7 « the ditch »
8. événement dig#v1 « digs » — agent : rider#e1; theme : spur#e2; lieu : flank#e4
9. événement bolt#v2 « bolts » — agent : animal#e5
10. événement throw#v3 « thrown » — theme : rider#e6; lieu : ditch#e7
11. relation spur#e2 —of→ rider#e1
12. relation horse#e3 —of→ rider#e1
13. relation flank#e4 —of→ horse#e3
14. coréférence rider#e1 = rider#e6
15. coréférence horse#e3 = animal#e5

## developpement — k 11, negatif (en) — annoté deux fois

> Gravestones and leaning wooden crosses fill a large municipal cemetery outside the town, with no church anywhere in sight.

1. entité gravestone#e1 « Gravestones »
2. entité cross#e2 « leaning wooden crosses » ; propriétés : wooden
3. entité cemetery#e3 « a large municipal cemetery » ; propriétés : large, municipal
4. entité town#e4 « the town »
5. entité church#e5 « no church » [polarite=neg]
6. événement lean#v1 « leaning » — agent : cross#e2
7. événement fill#v2 « fill » — agent : gravestone#e1, cross#e2; lieu : cemetery#e3
8. relation cemetery#e3 —outside→ town#e4

## developpement — k 61, positif (en)

> A garden pavilion is filled with blossoming orange trees and bowls of rose petals, censers send perfumed smoke through the air, and the visitors breathe in the scent with delight.

1. entité pavilion#e1 « A garden pavilion » ; propriétés : garden
2. entité orange tree#e2 « blossoming orange trees »
3. entité bowl#e3 « bowls »
4. entité petal#e4 « rose petals » ; propriétés : rose
5. entité censer#e5 « censers »
6. entité smoke#e6 « perfumed smoke » ; propriétés : perfumed
7. entité air#e7 « the air »
8. entité visitor#e8 « the visitors »
9. entité scent#e9 « the scent »
10. événement fill#v1 « filled » — agent : orange tree#e2, bowl#e3; lieu : pavilion#e1
11. événement blossom#v2 « blossoming » — agent : orange tree#e2
12. événement send#v3 « send » — agent : censer#e5; theme : smoke#e6; lieu : air#e7
13. événement breathe in#v4 « breathe in » — agent : visitor#e8; theme : scent#e9
14. relation bowl#e3 —of→ petal#e4

## developpement — k 21, positif (en) — annoté deux fois

> A coachman lashes his horses with a whip; the frightened animals bolt and the carriage overturns into the ditch.

1. entité coachman#e1 « A coachman »
2. entité horse#e2 « his horses »
3. entité whip#e3 « a whip »
4. entité animal#e4 « the frightened animals » ; propriétés : frightened
5. entité carriage#e5 « the carriage »
6. entité ditch#e6 « the ditch »
7. événement lash#v1 « lashes » — agent : coachman#e1; patient : horse#e2; instrument : whip#e3
8. événement bolt#v2 « bolt » — agent : animal#e4
9. événement overturn#v3 « overturns » — agent : carriage#e5; lieu : ditch#e6
10. relation horse#e2 —of→ coachman#e1
11. coréférence horse#e2 = animal#e4

## developpement — k 36, indetermine (fr)

> Une cascade tombe entre des rochers ; le fragment conservé est trop petit pour juger du caractère du paysage.

1. entité cascade#e1 « Une cascade »
2. entité rocher#e2 « des rochers »
3. entité fragment#e3 « le fragment conservé » ; propriétés : conservé, petit [portee=oeuvre]
4. entité caractère#e4 « caractère » [modalite=non_affirme, portee=non_ancre]
5. entité paysage#e5 « paysage » [portee=oeuvre]
6. événement tomber#v1 « tombe » — agent : cascade#e1; lieu : rocher#e2
7. événement juger#v2 « juger » — theme : caractère#e4 [polarite=neg, portee=non_ancre]
8. relation caractère#e4 —de→ paysage#e5

## developpement — k 76, indetermine (fr) — annoté deux fois

> Saint Pantaléon, médecin, ses instruments chirurgicaux posés près de lui, se tient debout dans un paysage.

1. entité saint#e1 « Saint Pantaléon » ; noms : Pantaléon
2. entité médecin#e2 « médecin »
3. entité instrument#e3 « ses instruments chirurgicaux » ; propriétés : chirurgical
4. entité paysage#e4 « un paysage »
5. événement se tenir#v1 « se tient debout » — agent : saint#e1; lieu : paysage#e4
6. événement poser#v2 « posés » — theme : instrument#e3; lieu : saint#e1
7. relation instrument#e3 —de→ saint#e1
8. coréférence saint#e1 = médecin#e2

## developpement — k 126, negatif (fr)

> Un portefaix qui soulevait un lourd tonneau s'effondre, foudroyé par une rupture du cœur ; ses compagnons se découvrent devant son corps sans vie.

1. entité portefaix#e1 « Un portefaix »
2. entité tonneau#e2 « un lourd tonneau » ; propriétés : lourd
3. entité cœur#e3 « cœur »
4. entité compagnon#e4 « ses compagnons »
5. entité corps#e5 « son corps »
6. entité vie#e6 « vie » [polarite=neg]
7. entité rupture#e7 « rupture »
8. événement soulever#v1 « soulevait » — agent : portefaix#e1; theme : tonneau#e2
9. événement s'effondrer#v2 « s'effondre » — agent : portefaix#e1
10. événement foudroyer#v3 « foudroyé » — agent : rupture#e7; patient : portefaix#e1
11. événement rompre#v4 « rupture » (nom d'action rupture) — patient : cœur#e3
12. événement se découvrir#v5 « se découvrent » — agent : compagnon#e4; lieu : corps#e5
13. relation cœur#e3 —de→ portefaix#e1
14. relation compagnon#e4 —de→ portefaix#e1
15. relation corps#e5 —de→ portefaix#e1
16. relation vie#e6 —de→ corps#e5
17. relation rupture#e7 —de→ cœur#e3

## developpement — k 136, negatif (fr) — annoté deux fois

> Un homme nu est étendu de tout son long sur le flanc gauche, la tête appuyée sur son bras replié.

1. entité homme#e1 « Un homme nu » ; propriétés : nu
2. entité flanc#e2 « le flanc gauche » ; propriétés : gauche
3. entité tête#e3 « la tête »
4. entité bras#e4 « son bras replié » ; propriétés : replié
5. événement s'étendre#v1 « étendu » — agent : homme#e1; lieu : flanc#e2
6. événement appuyer#v2 « appuyée » — theme : tête#e3; lieu : bras#e4
7. relation flanc#e2 —de→ homme#e1
8. relation tête#e3 —de→ homme#e1
9. relation bras#e4 —de→ homme#e1

## validation — k 181, indetermine (en)

> A woman holds a balance. Whether it is level, or tipped by anything, cannot be seen: the pans are obscured or rendered too summarily to allow a reading. No blindfold, purse or other attribute clarifies the figure's meaning. She may personify Justice, a merchant's trade or another concept associated with weighing. It would therefore be imprudent to interpret the work as an image of fair or corrupt judgement. The painter's handling of the figure is careful, but the essential detail that would determine the allegory's sense remains invisible, and interpretation should respect this limit.

1. entité woman#e1 « A woman »
2. entité balance#e2 « a balance » ; propriétés : level [modalite=non_affirme]
3. entité pan#e3 « the pans »
4. entité reading#e4 « a reading » [modalite=non_affirme, portee=non_ancre]
5. entité blindfold#e5 « No blindfold » [polarite=neg]
6. entité purse#e6 « purse » [polarite=neg]
7. entité attribute#e7 « other attribute » ; propriétés : other [polarite=neg]
8. entité meaning#e8 « meaning »
9. entité figure#e9 « the figure »
10. entité justice#e10 « Justice » ; noms : Justice [modalite=possible]
11. entité trade#e11 « trade » [modalite=possible]
12. entité merchant#e12 « merchant » [modalite=possible]
13. entité concept#e13 « another concept » [modalite=possible]
14. entité weighing#e14 « weighing »
15. entité work#e15 « the work » [portee=oeuvre]
16. entité image#e16 « an image » [modalite=non_affirme, portee=non_ancre]
17. entité judgement#e17 « judgement » ; propriétés : fair [modalite=possible], corrupt [modalite=possible] [modalite=non_affirme, portee=non_ancre]
18. entité painter#e18 « painter » [portee=histoire]
19. entité handling#e19 « handling » ; propriétés : careful [portee=oeuvre]
20. entité figure#e20 « the figure »
21. entité detail#e21 « the essential detail » ; propriétés : essential, invisible
22. entité sense#e22 « sense »
23. entité allegory#e23 « the allegory »
24. entité interpretation#e24 « interpretation » [portee=non_ancre]
25. entité limit#e25 « this limit » [portee=non_ancre]
26. événement hold#v1 « holds » — agent : woman#e1; theme : balance#e2
27. événement tip#v2 « tipped » — patient : balance#e2 [modalite=non_affirme]
28. événement obscure#v3 « obscured » — theme : pan#e3
29. événement render#v4 « rendered » — theme : pan#e3 [portee=oeuvre]
30. événement allow#v5 « allow » — theme : reading#e4 [polarite=neg]
31. événement clarify#v6 « clarifies » — agent : blindfold#e5, purse#e6, attribute#e7; theme : meaning#e8 [modalite=non_affirme]
32. événement personify#v7 « personify » — agent : woman#e1; theme : justice#e10, trade#e11, concept#e13 [modalite=possible]
33. événement associate#v8 « associated » — theme : concept#e13; instrument : weighing#e14 [modalite=possible]
34. événement weigh#v9 « weighing » (nom d'action weighing)
35. événement interpret#v10 « interpret » — theme : work#e15 [modalite=non_affirme, portee=non_ancre]
36. événement determine#v11 « determine » — agent : detail#e21; theme : sense#e22 [modalite=non_affirme]
37. événement respect#v12 « respect » — agent : interpretation#e24; theme : limit#e25 [portee=non_ancre]
38. relation pan#e3 —of→ balance#e2
39. relation meaning#e8 —of→ figure#e9
40. relation trade#e11 —of→ merchant#e12 [modalite=possible]
41. relation work#e15 —as→ image#e16 [modalite=non_affirme, portee=non_ancre]
42. relation image#e16 —of→ judgement#e17 [modalite=non_affirme, portee=non_ancre]
43. relation handling#e19 —of→ painter#e18
44. relation handling#e19 —of→ figure#e20
45. relation sense#e22 —of→ allegory#e23
46. coréférence woman#e1 = figure#e9
47. coréférence woman#e1 = figure#e20
48. alternative v3 | v4
49. alternative justice#e10 | trade#e11 | concept#e13

## validation — k 81, indetermine (en) — annoté deux fois

> In the foreground, a bearded man holding a book hands veils to a group of women who kneel before him. The women's heads are lowered, and they reach up to receive the cloth. The man is not named, and no inscription or attribute identifies him or the women. The meaning of the scene therefore remains uncertain, though the gesture of giving is clear. Behind the figures, the background is plain and unspecific, giving no indication of the place. The composition is simple, centred on the exchange of the veils between the standing man and the kneeling group.

1. entité foreground#e1 « the foreground »
2. entité man#e2 « a bearded man » ; propriétés : bearded
3. entité book#e3 « a book »
4. entité veil#e4 « veils »
5. entité group#e5 « a group »
6. entité woman#e6 « women »
7. entité woman#e7 « The women »
8. entité head#e8 « heads »
9. entité cloth#e9 « the cloth »
10. entité man#e10 « The man »
11. entité inscription#e11 « no inscription » [polarite=neg]
12. entité attribute#e12 « attribute » [polarite=neg]
13. entité woman#e13 « the women »
14. entité meaning#e14 « The meaning » ; propriétés : uncertain [portee=non_ancre]
15. entité scene#e15 « the scene »
16. entité gesture#e16 « the gesture » ; propriétés : clear
17. entité figure#e17 « the figures »
18. entité background#e18 « the background » ; propriétés : plain, unspecific
19. entité indication#e19 « no indication » [polarite=neg]
20. entité place#e20 « the place » [modalite=non_affirme]
21. entité composition#e21 « The composition » ; propriétés : simple [portee=oeuvre]
22. entité exchange#e22 « the exchange »
23. entité veil#e23 « the veils »
24. entité man#e24 « the standing man »
25. entité group#e25 « the kneeling group »
26. événement hold#v1 « holding » — agent : man#e2; theme : book#e3
27. événement hand#v2 « hands » — agent : man#e2; theme : veil#e4; destinataire : group#e5; lieu : foreground#e1
28. événement kneel#v3 « kneel » — agent : woman#e6; lieu : man#e2
29. événement lower#v4 « are lowered » — agent : head#e8
30. événement reach up#v5 « reach up » — agent : woman#e7
31. événement receive#v6 « receive » — agent : woman#e7; theme : cloth#e9
32. événement name#v7 « named » — theme : man#e10 [polarite=neg]
33. événement identify#v8 « identifies » — agent : inscription#e11, attribute#e12; theme : man#e10, woman#e13 [modalite=non_affirme]
34. événement give#v9 « giving »
35. événement give#v10 « giving » — agent : background#e18; theme : indication#e19 [modalite=non_affirme]
36. événement centre#v11 « centred » — theme : composition#e21; instrument : exchange#e22 [portee=oeuvre]
37. événement exchange#v12 « exchange » (nom d'action exchange) — agent : man#e24; theme : veil#e23; destinataire : group#e25
38. événement stand#v13 « standing » — agent : man#e24
39. événement kneel#v14 « kneeling » — agent : group#e25
40. relation group#e5 —of→ woman#e6
41. relation head#e8 —of→ woman#e7
42. relation meaning#e14 —of→ scene#e15
43. relation background#e18 —behind→ figure#e17
44. relation indication#e19 —of→ place#e20
45. coréférence man#e2 = man#e10 = man#e24
46. coréférence woman#e6 = woman#e7 = woman#e13
47. coréférence veil#e4 = cloth#e9 = veil#e23
48. coréférence group#e5 = group#e25

## validation — k 31, negatif (en)

> Here a cabinetmaker is at work on the same chair, but his task concerns its wooden frame: he carves the members and glues the joints together. The scene is devoted to woodwork, not to covering, and no fabric or stuffing comes into play. The painter observes the precision of the tools and the attention the craftsman brings to each joint, so that the bare structure of the seat becomes the true subject of the picture. Such images of the furniture trades belong to a broader interest in workshop practice that ran through genre painting, valuing technique and patient labour as worthy themes.

1. entité cabinetmaker#e1 « a cabinetmaker »
2. entité chair#e2 « the same chair » ; propriétés : same
3. entité task#e3 « his task »
4. entité frame#e4 « its wooden frame » ; propriétés : wooden
5. entité member#e5 « the members »
6. entité joint#e6 « the joints »
7. entité scene#e7 « The scene »
8. entité woodwork#e8 « woodwork »
9. entité covering#e9 « covering » [polarite=neg]
10. entité fabric#e10 « no fabric » [polarite=neg]
11. entité stuffing#e11 « stuffing » [polarite=neg]
12. entité painter#e12 « The painter » [portee=histoire]
13. entité precision#e13 « the precision »
14. entité tool#e14 « the tools »
15. entité attention#e15 « the attention »
16. entité craftsman#e16 « the craftsman »
17. entité joint#e17 « each joint »
18. entité structure#e18 « the bare structure » ; propriétés : bare
19. entité seat#e19 « the seat »
20. entité subject#e20 « the true subject » ; propriétés : true
21. entité picture#e21 « the picture » [portee=oeuvre]
22. entité image#e22 « Such images » [portee=non_ancre]
23. entité trade#e23 « the furniture trades » ; propriétés : furniture [portee=non_ancre]
24. entité interest#e24 « a broader interest » ; propriétés : broad [portee=non_ancre]
25. entité practice#e25 « workshop practice » ; propriétés : workshop [portee=non_ancre]
26. entité genre painting#e26 « genre painting » [portee=non_ancre]
27. entité technique#e27 « technique » [portee=non_ancre]
28. entité labour#e28 « patient labour » ; propriétés : patient [portee=non_ancre]
29. entité theme#e29 « worthy themes » ; propriétés : worthy [portee=non_ancre]
30. événement work#v1 « work » — agent : cabinetmaker#e1; theme : chair#e2
31. événement concern#v2 « concerns » — agent : task#e3; theme : frame#e4
32. événement carve#v3 « carves » — agent : cabinetmaker#e1; patient : member#e5
33. événement glue#v4 « glues » — agent : cabinetmaker#e1; patient : joint#e6
34. événement devote#v5 « devoted » — theme : scene#e7; destinataire : woodwork#e8, covering#e9
35. événement cover#v6 « covering » (nom d'action covering) [polarite=neg]
36. événement come into play#v7 « comes into play » — agent : fabric#e10, stuffing#e11 [modalite=non_affirme]
37. événement observe#v8 « observes » — agent : painter#e12; theme : precision#e13, attention#e15 [portee=oeuvre]
38. événement bring#v9 « brings » — agent : craftsman#e16; theme : attention#e15; destinataire : joint#e17
39. événement belong#v10 « belong » — theme : image#e22; lieu : interest#e24 [portee=non_ancre]
40. événement run#v11 « ran » — agent : interest#e24; lieu : genre painting#e26 [portee=non_ancre]
41. événement value#v12 « valuing » — agent : interest#e24; theme : technique#e27, labour#e28 [portee=non_ancre]
42. relation task#e3 —of→ cabinetmaker#e1
43. relation frame#e4 —of→ chair#e2
44. relation precision#e13 —of→ tool#e14
45. relation structure#e18 —of→ seat#e19
46. relation subject#e20 —of→ picture#e21
47. relation image#e22 —of→ trade#e23
48. relation interest#e24 —in→ practice#e25
49. relation technique#e27 —as→ theme#e29
50. relation labour#e28 —as→ theme#e29
51. coréférence cabinetmaker#e1 = craftsman#e16
52. coréférence chair#e2 = seat#e19
53. coréférence joint#e6 = joint#e17
54. coréférence structure#e18 = subject#e20

## validation — k 51, negatif (en) — annoté deux fois

> The photograph shows the same boy walking with crutches only. Nothing is fitted to his leg: no splint, strap or brace can be seen. The image focuses on his gait and on the support the crutches provide under his arms. Its plain, frontal framing places it within the conventions of clinical documentation, where the patient's posture and movement were the main concern of the photographer.

1. entité photograph#e1 « The photograph » [portee=oeuvre]
2. entité boy#e2 « the same boy » ; propriétés : same
3. entité crutch#e3 « crutches »
4. entité leg#e4 « his leg »
5. entité splint#e5 « no splint » [polarite=neg]
6. entité strap#e6 « strap » [polarite=neg]
7. entité brace#e7 « brace » [polarite=neg]
8. entité image#e8 « The image » [portee=oeuvre]
9. entité gait#e9 « his gait »
10. entité support#e10 « the support »
11. entité crutch#e11 « the crutches »
12. entité arm#e12 « his arms »
13. entité framing#e13 « Its plain, frontal framing » ; propriétés : plain, frontal [portee=oeuvre]
14. entité convention#e14 « the conventions » [portee=non_ancre]
15. entité documentation#e15 « clinical documentation » ; propriétés : clinical [portee=non_ancre]
16. entité patient#e16 « the patient » [portee=non_ancre]
17. entité posture#e17 « posture » [portee=non_ancre]
18. entité movement#e18 « movement » [portee=non_ancre]
19. entité concern#e19 « the main concern » ; propriétés : main [portee=non_ancre]
20. entité photographer#e20 « the photographer » [portee=non_ancre]
21. événement walk#v1 « walking » — agent : boy#e2; instrument : crutch#e3
22. événement fit#v2 « is fitted » — lieu : leg#e4 [polarite=neg]
23. événement focus#v3 « focuses » — agent : image#e8; theme : gait#e9, support#e10 [portee=oeuvre]
24. événement provide#v4 « provide » — agent : crutch#e11; theme : support#e10; lieu : arm#e12
25. événement place#v5 « places » — agent : framing#e13; theme : image#e8; lieu : convention#e14 [portee=non_ancre]
26. événement document#v6 « documentation » (nom d'action documentation) [portee=non_ancre]
27. événement move#v7 « movement » (nom d'action movement) — agent : patient#e16 [portee=non_ancre]
28. relation leg#e4 —of→ boy#e2
29. relation gait#e9 —of→ boy#e2
30. relation arm#e12 —of→ boy#e2
31. relation framing#e13 —of→ image#e8
32. relation convention#e14 —of→ documentation#e15
33. relation posture#e17 —of→ patient#e16
34. relation movement#e18 —of→ patient#e16
35. relation concern#e19 —of→ photographer#e20
36. coréférence photograph#e1 = image#e8
37. coréférence crutch#e3 = crutch#e11

## validation — k 171, positif (en)

> An allegorical woman occupies the foreground, leaning forward with keen eyes, her gaze fixed ahead. In one hand she holds a leash, at the end of which a hunting hound sniffs the ground, its nose lowered to follow a trail. The pair moves together across the picture. The figure is an emblem of searching out hidden things, and every element of the composition, from her forward posture to the dog's attentive muzzle, expresses inquiry. Behind them, the background is kept simple, a plain landscape that leaves the allegory clearly legible.

1. entité woman#e1 « An allegorical woman » ; propriétés : allegorical
2. entité foreground#e2 « the foreground »
3. entité eye#e3 « keen eyes » ; propriétés : keen
4. entité gaze#e4 « her gaze » ; propriétés : fixed
5. entité hand#e5 « one hand » ; nombre 1
6. entité leash#e6 « a leash »
7. entité end#e7 « the end »
8. entité hound#e8 « a hunting hound » ; propriétés : hunting
9. entité ground#e9 « the ground »
10. entité nose#e10 « its nose » ; propriétés : lowered
11. entité trail#e11 « a trail »
12. entité pair#e12 « The pair »
13. entité picture#e13 « the picture » [portee=oeuvre]
14. entité figure#e14 « The figure »
15. entité emblem#e15 « an emblem »
16. entité searching#e16 « searching »
17. entité thing#e17 « hidden things » ; propriétés : hidden
18. entité element#e18 « every element »
19. entité composition#e19 « the composition » [portee=oeuvre]
20. entité posture#e20 « her forward posture » ; propriétés : forward
21. entité muzzle#e21 « attentive muzzle » ; propriétés : attentive
22. entité dog#e22 « the dog »
23. entité inquiry#e23 « inquiry »
24. entité background#e24 « the background » ; propriétés : simple
25. entité landscape#e25 « a plain landscape » ; propriétés : plain
26. entité allegory#e26 « the allegory » ; propriétés : legible
27. événement occupy#v1 « occupies » — agent : woman#e1; lieu : foreground#e2
28. événement lean#v2 « leaning » — agent : woman#e1
29. événement hold#v3 « holds » — agent : woman#e1; theme : leash#e6; lieu : hand#e5
30. événement sniff#v4 « sniffs » — agent : hound#e8; theme : ground#e9; lieu : end#e7
31. événement follow#v5 « follow » — agent : hound#e8; theme : trail#e11
32. événement move#v6 « moves » — agent : pair#e12; lieu : picture#e13
33. événement search out#v7 « searching » (nom d'action searching) — theme : thing#e17
34. événement express#v8 « expresses » — agent : element#e18; theme : inquiry#e23
35. événement inquire#v9 « inquiry » (nom d'action inquiry)
36. événement leave#v10 « leaves » — agent : landscape#e25; theme : allegory#e26
37. relation eye#e3 —of→ woman#e1
38. relation gaze#e4 —of→ woman#e1
39. relation hand#e5 —of→ woman#e1
40. relation end#e7 —of→ leash#e6
41. relation nose#e10 —of→ hound#e8
42. relation emblem#e15 —of→ searching#e16
43. relation element#e18 —of→ composition#e19
44. relation posture#e20 —of→ woman#e1
45. relation muzzle#e21 —of→ dog#e22
46. relation background#e24 —behind→ woman#e1
47. relation background#e24 —behind→ hound#e8
48. coréférence woman#e1 = figure#e14
49. coréférence figure#e14 = emblem#e15
50. coréférence hound#e8 = dog#e22
51. coréférence background#e24 = landscape#e25

## validation — k 181, positif (en) — annoté deux fois

> An allegorical judge lifts her blindfold in order to favour one of the litigants. She lets a purse tip one pan of her balance and turns her back on the poor plaintiff. The artist subverts the familiar iconography of Justice, whose blindfold and level scales normally signify impartiality, by showing each attribute corrupted: the raised blindfold reveals partiality, the purse distorts the balance, and the turned back expresses contempt for the weak. Such satirical inversions of virtue allegories were a powerful vehicle of social criticism, and the clarity of the visual language made the denunciation accessible to a broad public.

1. entité judge#e1 « An allegorical judge » ; propriétés : allegorical
2. entité blindfold#e2 « her blindfold »
3. entité litigant#e3 « one of the litigants » ; nombre 1
4. entité purse#e4 « a purse »
5. entité pan#e5 « one pan » ; nombre 1
6. entité balance#e6 « her balance »
7. entité back#e7 « her back »
8. entité plaintiff#e8 « the poor plaintiff » ; propriétés : poor
9. entité artist#e9 « The artist » [portee=histoire]
10. entité iconography#e10 « the familiar iconography » ; propriétés : familiar [portee=non_ancre]
11. entité justice#e11 « Justice » ; noms : Justice [portee=non_ancre]
12. entité blindfold#e12 « whose blindfold » [portee=non_ancre]
13. entité scale#e13 « level scales » ; propriétés : level [portee=non_ancre]
14. entité impartiality#e14 « impartiality » [portee=non_ancre]
15. entité attribute#e15 « each attribute » ; propriétés : corrupted
16. entité blindfold#e16 « the raised blindfold » ; propriétés : raised
17. entité partiality#e17 « partiality »
18. entité purse#e18 « the purse »
19. entité balance#e19 « the balance »
20. entité back#e20 « the turned back » ; propriétés : turned
21. entité contempt#e21 « contempt »
22. entité weak#e22 « the weak »
23. entité inversion#e23 « Such satirical inversions » ; propriétés : satirical [portee=non_ancre]
24. entité allegory#e24 « virtue allegories » ; propriétés : virtue [portee=non_ancre]
25. entité vehicle#e25 « a powerful vehicle » ; propriétés : powerful [portee=non_ancre]
26. entité criticism#e26 « social criticism » ; propriétés : social [portee=non_ancre]
27. entité clarity#e27 « the clarity » [portee=non_ancre]
28. entité language#e28 « the visual language » ; propriétés : visual [portee=non_ancre]
29. entité denunciation#e29 « the denunciation » ; propriétés : accessible [portee=non_ancre]
30. entité public#e30 « a broad public » ; propriétés : broad [portee=non_ancre]
31. événement lift#v1 « lifts » — agent : judge#e1; theme : blindfold#e2
32. événement favour#v2 « favour » — agent : judge#e1; theme : litigant#e3
33. événement let#v3 « lets » — agent : judge#e1; theme : purse#e4
34. événement tip#v4 « tip » — agent : purse#e4; patient : pan#e5
35. événement turn#v5 « turns » — agent : judge#e1; theme : back#e7; lieu : plaintiff#e8
36. événement subvert#v6 « subverts » — agent : artist#e9; patient : iconography#e10 [portee=oeuvre]
37. événement signify#v7 « signify » — agent : blindfold#e12, scale#e13; theme : impartiality#e14 [portee=non_ancre]
38. événement reveal#v8 « reveals » — agent : blindfold#e16; theme : partiality#e17
39. événement distort#v9 « distorts » — agent : purse#e18; patient : balance#e19
40. événement express#v10 « expresses » — agent : back#e20; theme : contempt#e21
41. événement invert#v11 « inversions » (nom d'action inversion) — patient : allegory#e24 [portee=non_ancre]
42. événement criticize#v12 « criticism » (nom d'action criticism) [portee=non_ancre]
43. événement make#v13 « made » — agent : clarity#e27; theme : denunciation#e29 [portee=non_ancre]
44. événement denounce#v14 « denunciation » (nom d'action denunciation) [portee=non_ancre]
45. relation blindfold#e2 —of→ judge#e1
46. relation pan#e5 —of→ balance#e6
47. relation balance#e6 —of→ judge#e1
48. relation back#e7 —of→ judge#e1
49. relation iconography#e10 —of→ justice#e11 [portee=non_ancre]
50. relation blindfold#e12 —of→ justice#e11 [portee=non_ancre]
51. relation scale#e13 —of→ justice#e11 [portee=non_ancre]
52. relation contempt#e21 —for→ weak#e22
53. relation inversion#e23 —of→ allegory#e24 [portee=non_ancre]
54. relation vehicle#e25 —of→ criticism#e26 [portee=non_ancre]
55. relation clarity#e27 —of→ language#e28 [portee=non_ancre]
56. relation denunciation#e29 —to→ public#e30 [portee=non_ancre]
57. coréférence blindfold#e2 = blindfold#e16
58. coréférence purse#e4 = purse#e18
59. coréférence balance#e6 = balance#e19
60. coréférence back#e7 = back#e20
61. coréférence inversion#e23 = vehicle#e25

## validation — k 151, variante_roles_inverses (en)

> In the foreground, Pharaoh's magician lifts his staff, and the ice storm strikes the Hebrews. The balls of ice and the lightning fall upon their tents and their flocks, while the magician stands triumphant. The usual direction of the calamity is reversed, turned against those who are elsewhere spared. The sky is black with cloud, and the light of the lightning picks out the fleeing figures. In the background, the Egyptian buildings stand untouched, emphasising the reversal of fortune. The storm is rendered vividly.

1. entité foreground#e1 « the foreground » [portee=oeuvre]
2. entité magician#e2 « Pharaoh's magician »
3. entité pharaoh#e3 « Pharaoh » ; noms : Pharaoh
4. entité staff#e4 « his staff »
5. entité storm#e5 « the ice storm » ; propriétés : ice
6. entité hebrew#e6 « the Hebrews »
7. entité ball#e7 « The balls »
8. entité ice#e8 « ice »
9. entité lightning#e9 « the lightning »
10. entité tent#e10 « their tents »
11. entité flock#e11 « their flocks »
12. entité magician#e12 « the magician » ; propriétés : triumphant
13. entité direction#e13 « The usual direction » ; propriétés : usual, reversed
14. entité calamity#e14 « the calamity »
15. entité sky#e15 « The sky » ; propriétés : black
16. entité cloud#e16 « cloud »
17. entité light#e17 « the light »
18. entité lightning#e18 « the lightning »
19. entité figure#e19 « the fleeing figures »
20. entité background#e20 « the background » [portee=oeuvre]
21. entité building#e21 « the Egyptian buildings » ; propriétés : egyptian, untouched
22. entité reversal#e22 « the reversal »
23. entité fortune#e23 « fortune »
24. entité storm#e24 « The storm »
25. événement lift#v1 « lifts » — agent : magician#e2; theme : staff#e4; lieu : foreground#e1
26. événement strike#v2 « strikes » — agent : storm#e5; patient : hebrew#e6
27. événement fall#v3 « fall » — agent : ball#e7, lightning#e9; lieu : tent#e10, flock#e11
28. événement stand#v4 « stands » — agent : magician#e12
29. événement turn#v5 « turned » — patient : direction#e13
30. événement spare#v6 « spared » — patient : hebrew#e6 [portee=source]
31. événement pick out#v7 « picks out » — agent : light#e17; theme : figure#e19
32. événement flee#v8 « fleeing » — agent : figure#e19
33. événement emphasise#v10 « emphasising » — agent : building#e21; theme : reversal#e22
34. événement reverse#v11 « reversal » (nom d'action reversal) — theme : fortune#e23
35. relation magician#e2 —of→ pharaoh#e3
36. relation staff#e4 —of→ magician#e2
37. relation ball#e7 —of→ ice#e8
38. relation tent#e10 —of→ hebrew#e6
39. relation flock#e11 —of→ hebrew#e6
40. relation direction#e13 —of→ calamity#e14
41. relation direction#e13 —against→ hebrew#e6
42. relation sky#e15 —with→ cloud#e16
43. relation light#e17 —of→ lightning#e18
44. relation building#e21 —in→ background#e20
45. coréférence magician#e2 = magician#e12
46. coréférence lightning#e9 = lightning#e18
47. coréférence storm#e5 = storm#e24

## validation — k 161, variante_autre_relation (en) — annoté deux fois

> Jeremiah weeps with the people of Judah. No rebuke and no mockery appear: the relation between prophet and people is one of shared grief. The figures are gathered together, heads bowed and faces covered, in a common expression of sorrow. The painter dissolves the usual opposition between the prophet and his audience into a scene of collective mourning. Such an approach emphasises compassion over denunciation, and the composition, compact and subdued, gives visual form to a community united in lamentation.

1. entité jeremiah#e1 « Jeremiah » ; noms : Jeremiah
2. entité people#e2 « the people »
3. entité judah#e3 « Judah » ; noms : Judah
4. entité rebuke#e4 « No rebuke » [polarite=neg]
5. entité mockery#e5 « no mockery » [polarite=neg]
6. entité relation#e6 « the relation »
7. entité prophet#e7 « prophet »
8. entité people#e8 « people »
9. entité grief#e9 « shared grief » ; propriétés : shared
10. entité figure#e10 « The figures »
11. entité head#e11 « heads » ; propriétés : bowed
12. entité face#e12 « faces » ; propriétés : covered
13. entité expression#e13 « a common expression » ; propriétés : common
14. entité sorrow#e14 « sorrow »
15. entité painter#e15 « The painter » [portee=histoire]
16. entité opposition#e16 « the usual opposition » ; propriétés : usual
17. entité prophet#e17 « the prophet »
18. entité audience#e18 « his audience »
19. entité scene#e19 « a scene »
20. entité mourning#e20 « collective mourning » ; propriétés : collective
21. entité approach#e21 « Such an approach » [portee=non_ancre]
22. entité compassion#e22 « compassion » [portee=non_ancre]
23. entité denunciation#e23 « denunciation » [portee=non_ancre]
24. entité composition#e24 « the composition » ; propriétés : compact, subdued [portee=oeuvre]
25. entité form#e25 « visual form » ; propriétés : visual
26. entité community#e26 « a community »
27. entité lamentation#e27 « lamentation »
28. événement weep#v1 « weeps » — agent : jeremiah#e1, people#e2
29. événement rebuke#v2 « rebuke » (nom d'action rebuke) [polarite=neg]
30. événement mock#v3 « mockery » (nom d'action mockery) [polarite=neg]
31. événement grieve#v4 « grief » (nom d'action grief) — agent : prophet#e7, people#e8
32. événement gather#v5 « gathered » — theme : figure#e10
33. événement express#v6 « expression » (nom d'action expression) — agent : figure#e10; theme : sorrow#e14
34. événement dissolve#v7 « dissolves » — agent : painter#e15; patient : opposition#e16 [portee=oeuvre]
35. événement mourn#v8 « mourning » (nom d'action mourning)
36. événement emphasise#v9 « emphasises » — agent : approach#e21; theme : compassion#e22 [portee=non_ancre]
37. événement denounce#v10 « denunciation » (nom d'action denunciation) [portee=non_ancre]
38. événement give#v11 « gives » — agent : composition#e24; theme : form#e25; destinataire : community#e26 [portee=oeuvre]
39. événement unite#v12 « united » — patient : community#e26; instrument : lamentation#e27
40. événement lament#v13 « lamentation » (nom d'action lamentation)
41. relation people#e2 —of→ judah#e3
42. relation relation#e6 —between→ prophet#e7
43. relation relation#e6 —between→ people#e8
44. relation relation#e6 —of→ grief#e9
45. relation head#e11 —of→ figure#e10
46. relation face#e12 —of→ figure#e10
47. relation figure#e10 —in→ expression#e13
48. relation expression#e13 —of→ sorrow#e14
49. relation opposition#e16 —between→ prophet#e17
50. relation opposition#e16 —between→ audience#e18
51. relation audience#e18 —of→ prophet#e17
52. relation opposition#e16 —into→ scene#e19
53. relation scene#e19 —of→ mourning#e20
54. relation compassion#e22 —over→ denunciation#e23 [portee=non_ancre]
55. coréférence jeremiah#e1 = prophet#e7
56. coréférence people#e2 = people#e8
57. coréférence jeremiah#e1 = prophet#e17
58. coréférence people#e2 = audience#e18

## validation — k 16, indetermine (fr)

> Accroché au mur, un objet à long manche et à caisse de bois occupe le centre de la composition. Sa nature exacte reste difficile à préciser : on ne voit ni combien de fils il porte, ni de quelle manière on en joue, et aucune figure ne vient le manipuler. L'œuvre se présente ainsi comme une étude d'objet dont l'identification demeure incertaine. Le traitement du bois et de l'ombre portée sur la paroi témoigne d'une observation attentive, sans lever pour autant l'ambiguïté.

1. entité mur#e1 « mur »
2. entité objet#e2 « objet »
3. entité manche#e3 « long manche » ; propriétés : long
4. entité caisse#e4 « caisse »
5. entité bois#e5 « bois »
6. entité centre#e6 « le centre »
7. entité composition#e7 « la composition » [portee=oeuvre]
8. entité nature#e8 « Sa nature exacte » ; propriétés : exact
9. entité fil#e9 « fils » [modalite=non_affirme]
10. entité figure#e10 « aucune figure » [polarite=neg]
11. entité œuvre#e11 « L'œuvre » [portee=oeuvre]
12. entité étude#e12 « une étude » [portee=oeuvre]
13. entité objet#e13 « objet »
14. entité identification#e14 « l'identification » ; propriétés : incertain
15. entité traitement#e15 « Le traitement » [portee=oeuvre]
16. entité bois#e16 « bois »
17. entité ombre portée#e17 « l'ombre portée »
18. entité paroi#e18 « la paroi »
19. entité observation#e19 « une observation attentive » ; propriétés : attentif [portee=oeuvre]
20. entité ambiguïté#e20 « l'ambiguïté »
21. événement accrocher#v1 « Accroché » — theme : objet#e2; lieu : mur#e1
22. événement occuper#v2 « occupe » — agent : objet#e2; lieu : centre#e6
23. événement préciser#v3 « préciser » — theme : nature#e8 [modalite=non_affirme]
24. événement porter#v5 « porte » — agent : objet#e2; theme : fil#e9 [modalite=non_affirme]
25. événement jouer#v6 « joue » — theme : objet#e2 [modalite=non_affirme]
26. événement manipuler#v7 « manipuler » — agent : figure#e10; theme : objet#e2 [modalite=non_affirme]
27. événement identifier#v8 « identification » (nom d'action identification) — theme : objet#e13
28. événement traiter#v9 « traitement » (nom d'action traitement) — theme : bois#e16, ombre portée#e17 [portee=oeuvre]
29. événement témoigner#v10 « témoigne » — agent : traitement#e15; theme : observation#e19 [portee=oeuvre]
30. événement observer#v11 « observation » (nom d'action observation) [portee=oeuvre]
31. événement lever#v12 « lever » — agent : traitement#e15; theme : ambiguïté#e20 [polarite=neg]
32. relation manche#e3 —de→ objet#e2
33. relation caisse#e4 —de→ objet#e2
34. relation caisse#e4 —de→ bois#e5
35. relation centre#e6 —de→ composition#e7
36. relation nature#e8 —de→ objet#e2
37. relation étude#e12 —de→ objet#e13
38. relation ombre portée#e17 —sur→ paroi#e18
39. coréférence mur#e1 = paroi#e18
40. coréférence objet#e2 = objet#e13
41. coréférence bois#e5 = bois#e16
42. coréférence œuvre#e11 = étude#e12

## validation — k 66, indetermine (fr) — annoté deux fois

> Le tableau représente une religieuse dont la tête est entièrement couverte d'un voile. On ignore tout de la coupe de ses cheveux, totalement dissimulés par l'étoffe. Le peintre s'attache à l'ovale du visage, encadré par les plis du voile, et à l'expression calme du modèle. La notice ne peut rien affirmer quant à un éventuel crâne rasé en couronne, que l'image ne laisse pas voir.

1. entité tableau#e1 « Le tableau » [portee=oeuvre]
2. entité religieuse#e2 « une religieuse »
3. entité tête#e3 « la tête »
4. entité voile#e4 « un voile »
5. entité coupe#e5 « la coupe » [modalite=non_affirme]
6. entité cheveu#e6 « ses cheveux »
7. entité étoffe#e7 « l'étoffe »
8. entité peintre#e8 « Le peintre » [portee=histoire]
9. entité ovale#e9 « l'ovale »
10. entité visage#e10 « du visage »
11. entité pli#e11 « les plis »
12. entité voile#e12 « du voile »
13. entité expression#e13 « l'expression calme » ; propriétés : calme
14. entité modèle#e14 « du modèle »
15. entité notice#e15 « La notice » [portee=non_ancre]
16. entité crâne#e16 « un éventuel crâne » ; propriétés : éventuel [modalite=non_affirme]
17. entité couronne#e17 « couronne » [modalite=non_affirme]
18. entité image#e18 « l'image » [portee=oeuvre]
19. événement couvrir#v1 « couverte » — theme : tête#e3; instrument : voile#e4
20. événement ignorer#v2 « ignore » — theme : coupe#e5 [portee=non_ancre]
21. événement couper#v3 « la coupe » (nom d'action coupe) — theme : cheveu#e6 [modalite=non_affirme]
22. événement dissimuler#v4 « dissimulés » — agent : étoffe#e7; theme : cheveu#e6
23. événement s'attacher#v5 « s'attache » — agent : peintre#e8; theme : ovale#e9, expression#e13 [portee=oeuvre]
24. événement encadrer#v6 « encadré » — agent : pli#e11; theme : ovale#e9
25. événement affirmer#v7 « affirmer » — agent : notice#e15; theme : crâne#e16 [polarite=neg, portee=non_ancre]
26. événement raser#v8 « rasé » — patient : crâne#e16 [modalite=non_affirme]
27. relation tête#e3 —de→ religieuse#e2
28. relation cheveu#e6 —de→ religieuse#e2
29. relation coupe#e5 —de→ cheveu#e6
30. relation ovale#e9 —de→ visage#e10
31. relation visage#e10 —de→ religieuse#e2
32. relation pli#e11 —de→ voile#e12
33. relation expression#e13 —de→ modèle#e14
34. relation crâne#e16 —en→ couronne#e17 [modalite=non_affirme]
35. coréférence voile#e4 = étoffe#e7 = voile#e12
36. coréférence religieuse#e2 = modèle#e14

## validation — k 66, negatif (fr)

> L'œuvre montre un moine dont le crâne est rasé en couronne. Le cercle de cheveux qui subsiste autour de la tête encadre un sommet dégagé, selon l'usage monastique. Le peintre s'attache au visage du religieux et à la simplicité de son habit, dans une composition dépouillée qui convient à la figure. Aucun autre personnage ne vient perturber cette image de recueillement monastique.

1. entité œuvre#e1 « L'œuvre » [portee=oeuvre]
2. entité moine#e2 « un moine »
3. entité crâne#e3 « le crâne »
4. entité couronne#e4 « couronne »
5. entité cercle#e5 « Le cercle »
6. entité cheveu#e6 « cheveux »
7. entité tête#e7 « la tête »
8. entité sommet#e8 « un sommet dégagé » ; propriétés : dégagé
9. entité usage#e9 « l'usage monastique » ; propriétés : monastique [portee=non_ancre]
10. entité peintre#e10 « Le peintre » [portee=histoire]
11. entité visage#e11 « visage »
12. entité religieux#e12 « du religieux »
13. entité simplicité#e13 « la simplicité »
14. entité habit#e14 « son habit »
15. entité composition#e15 « une composition dépouillée » ; propriétés : dépouillé [portee=oeuvre]
16. entité figure#e16 « la figure »
17. entité personnage#e17 « Aucun autre personnage » ; propriétés : autre [polarite=neg]
18. entité image#e18 « cette image » [portee=oeuvre]
19. entité recueillement#e19 « recueillement monastique » ; propriétés : monastique
20. événement raser#v1 « est rasé » — patient : crâne#e3
21. événement encadrer#v3 « encadre » — agent : cercle#e5; theme : sommet#e8
22. événement s'attacher#v4 « s'attache » — agent : peintre#e10; theme : visage#e11, simplicité#e13; lieu : composition#e15 [portee=oeuvre]
23. événement convenir#v5 « convient » — agent : composition#e15; destinataire : figure#e16 [portee=non_ancre]
24. événement perturber#v6 « perturber » — agent : personnage#e17; theme : image#e18 [modalite=non_affirme]
25. événement se recueillir#v7 « recueillement » (nom d'action recueillement)
26. relation crâne#e3 —de→ moine#e2
27. relation crâne#e3 —en→ couronne#e4
28. relation cercle#e5 —de→ cheveu#e6
29. relation tête#e7 —de→ moine#e2
30. relation cercle#e5 —selon→ usage#e9
31. relation visage#e11 —de→ religieux#e12
32. relation habit#e14 —de→ religieux#e12
33. relation simplicité#e13 —de→ habit#e14
34. relation image#e18 —de→ recueillement#e19
35. relation cercle#e5 —autour de→ tête#e7
36. coréférence moine#e2 = religieux#e12 = figure#e16
37. coréférence œuvre#e1 = image#e18
38. distincts moine#e2 ≠ personnage#e17

## validation — k 196, negatif (fr) — annoté deux fois

> Une grande cathédrale occupe toute l'image, vue du dehors. Son bras transversal, du même type, dépasse de la nef de part et d'autre, mais à une tout autre échelle : les murs s'élèvent très haut, percés de vastes fenêtres, et le volume se perd dans la masse de l'édifice. Au premier plan, le pavement d'une place s'étend jusqu'aux portails. Au fond, les tours et les toitures se détachent sur le ciel. L'artiste insiste sur la monumentalité de la construction, dont les dimensions écrasent les passants.

1. entité cathédrale#e1 « Une grande cathédrale » ; propriétés : grand
2. entité image#e2 « l'image » [portee=oeuvre]
3. entité bras#e4 « Son bras transversal » ; propriétés : transversal
4. entité type#e5 « même type » ; propriétés : même
5. entité nef#e6 « la nef »
6. entité échelle#e7 « une tout autre échelle » ; propriétés : autre
7. entité mur#e8 « les murs »
8. entité fenêtre#e9 « vastes fenêtres » ; propriétés : vaste
9. entité volume#e10 « le volume »
10. entité masse#e11 « la masse »
11. entité édifice#e12 « l'édifice »
12. entité premier plan#e13 « premier plan »
13. entité pavement#e14 « le pavement »
14. entité place#e15 « une place »
15. entité portail#e16 « portails »
16. entité fond#e17 « fond »
17. entité tour#e18 « les tours »
18. entité toiture#e19 « les toitures »
19. entité ciel#e20 « le ciel »
20. entité artiste#e21 « L'artiste » [portee=histoire]
21. entité monumentalité#e22 « la monumentalité »
22. entité construction#e23 « la construction »
23. entité dimension#e24 « les dimensions »
24. entité passant#e25 « les passants »
25. événement occuper#v1 « occupe » — agent : cathédrale#e1; lieu : image#e2
26. événement dépasser#v3 « dépasse » — agent : bras#e4
27. événement percer#v5 « percés » — patient : mur#e8; instrument : fenêtre#e9
28. événement se perdre#v6 « se perd » — agent : volume#e10; lieu : masse#e11
29. événement insister#v9 « insiste » — agent : artiste#e21; theme : monumentalité#e22 [portee=oeuvre]
30. événement écraser#v10 « écrasent » — agent : dimension#e24; theme : passant#e25
31. relation bras#e4 —de→ cathédrale#e1
32. relation bras#e4 —de→ type#e5
33. relation bras#e4 —à→ échelle#e7
34. relation masse#e11 —de→ édifice#e12
35. relation pavement#e14 —de→ place#e15
36. relation monumentalité#e22 —de→ construction#e23
37. relation dimension#e24 —de→ construction#e23
38. relation bras#e4 —de→ nef#e6
39. relation pavement#e14 —à→ premier plan#e13
40. relation pavement#e14 —jusqu'à→ portail#e16
41. relation tour#e18 —sur→ ciel#e20
42. relation toiture#e19 —sur→ ciel#e20
43. relation tour#e18 —à→ fond#e17
44. relation toiture#e19 —à→ fond#e17
45. coréférence cathédrale#e1 = édifice#e12
46. coréférence cathédrale#e1 = construction#e23

## validation — k 26, positif (fr)

> La planche, extraite d'un bestiaire, figure une créature imaginaire qui surgit des vagues. Son corps est couvert d'écailles, pourvu de nageoires et terminé par une queue fourchue, mais il porte une tête de lion. Cet assemblage hybride illustre bien la logique des bestiaires, où l'on composait des êtres fabuleux en associant des parties empruntées à des animaux connus. L'enlumineur exploite le contraste entre la crinière du fauve et la souplesse aquatique du corps, et le mouvement de la bête jaillissant hors de l'eau confère à l'image une vivacité remarquable. La mer, réduite à des ondulations stylisées, sert de simple cadre à l'apparition.

1. entité planche#e1 « La planche » [portee=oeuvre]
2. entité bestiaire#e2 « un bestiaire » [portee=oeuvre]
3. entité créature#e3 « une créature imaginaire » ; propriétés : imaginaire
4. entité vague#e4 « vagues »
5. entité corps#e5 « corps »
6. entité écaille#e6 « écailles »
7. entité nageoire#e7 « nageoires »
8. entité queue#e8 « une queue fourchue » ; propriétés : fourchu
9. entité tête#e9 « une tête »
10. entité lion#e10 « lion »
11. entité assemblage#e11 « Cet assemblage hybride » ; propriétés : hybride
12. entité logique#e12 « la logique » [portee=non_ancre]
13. entité bestiaire#e13 « bestiaires » [portee=non_ancre]
14. entité être#e14 « des êtres fabuleux » ; propriétés : fabuleux [portee=non_ancre]
15. entité partie#e15 « des parties » [portee=non_ancre]
16. entité animal#e16 « des animaux connus » ; propriétés : connu [portee=non_ancre]
17. entité enlumineur#e17 « L'enlumineur » [portee=histoire]
18. entité contraste#e18 « le contraste » [portee=oeuvre]
19. entité crinière#e19 « la crinière »
20. entité fauve#e20 « fauve »
21. entité souplesse#e21 « la souplesse aquatique » ; propriétés : aquatique
22. entité corps#e22 « corps »
23. entité mouvement#e23 « le mouvement »
24. entité bête#e24 « la bête »
25. entité eau#e25 « l'eau »
26. entité vivacité#e26 « une vivacité remarquable » ; propriétés : remarquable
27. entité image#e27 « l'image » [portee=oeuvre]
28. entité mer#e28 « La mer »
29. entité ondulation#e29 « des ondulations stylisées » ; propriétés : stylisé
30. entité cadre#e30 « simple cadre » ; propriétés : simple
31. entité apparition#e31 « l'apparition »
32. événement extraire#v1 « extraite » — theme : planche#e1 [portee=histoire]
33. événement surgir#v2 « surgit » — agent : créature#e3
34. événement couvrir#v3 « couvert » — patient : corps#e5; instrument : écaille#e6
35. événement pourvoir#v4 « pourvu » — patient : corps#e5; instrument : nageoire#e7
36. événement terminer#v5 « terminé » — patient : corps#e5; agent : queue#e8
37. événement porter#v6 « porte » — agent : corps#e5; theme : tête#e9
38. événement illustrer#v7 « illustre » — agent : assemblage#e11; theme : logique#e12
39. événement composer#v8 « composait » — theme : être#e14; lieu : bestiaire#e13 [portee=non_ancre]
40. événement associer#v9 « associant » — theme : partie#e15 [portee=non_ancre]
41. événement emprunter#v10 « empruntées » — theme : partie#e15 [portee=non_ancre]
42. événement exploiter#v11 « exploite » — agent : enlumineur#e17; theme : contraste#e18 [portee=oeuvre]
43. événement mouvoir#v12 « mouvement » (nom d'action mouvement) — agent : bête#e24
44. événement jaillir#v13 « jaillissant » — agent : bête#e24; lieu : eau#e25
45. événement conférer#v14 « confère » — agent : mouvement#e23; theme : vivacité#e26; destinataire : image#e27
46. événement réduire#v15 « réduite » — patient : mer#e28
47. événement servir#v16 « sert » — agent : mer#e28; destinataire : apparition#e31
48. événement apparaître#v17 « apparition » (nom d'action apparition)
49. relation planche#e1 —de→ bestiaire#e2 [portee=histoire]
50. relation créature#e3 —de→ vague#e4
51. relation corps#e5 —de→ créature#e3
52. relation tête#e9 —de→ lion#e10
53. relation logique#e12 —de→ bestiaire#e13
54. relation partie#e15 —à→ animal#e16
55. relation contraste#e18 —entre→ crinière#e19
56. relation contraste#e18 —entre→ souplesse#e21
57. relation crinière#e19 —de→ fauve#e20
58. relation souplesse#e21 —de→ corps#e22
59. relation mer#e28 —à→ ondulation#e29
60. coréférence créature#e3 = assemblage#e11 = fauve#e20 = bête#e24
61. coréférence corps#e5 = corps#e22
62. coréférence eau#e25 = mer#e28 = cadre#e30

## validation — k 166, positif (fr) — annoté deux fois

> Penuel
Huile sur toile, vers 1650
À l'aube, après la lutte, Jacob boitant se retourne et proclame que ce lieu s'appellera Penuel, « j'ai vu Dieu face à face » ; il grave une pierre.

1. entité penuel#e1 « Penuel » ; noms : Penuel [modalite=titre]
2. entité huile#e2 « Huile » [portee=oeuvre]
3. entité toile#e3 « toile » [portee=oeuvre]
4. entité aube#e4 « l'aube »
5. entité jacob#e6 « Jacob » ; noms : Jacob
6. entité lieu#e7 « ce lieu » ; noms : Penuel
7. entité dieu#e8 « Dieu » ; noms : Dieu [portee=source, enonciateur=cité : Jacob]
8. entité pierre#e9 « une pierre »
9. événement lutter#v1 « lutte » (nom d'action lutte)
10. événement boiter#v2 « boitant » — agent : jacob#e6
11. événement se retourner#v3 « se retourne » — agent : jacob#e6
12. événement proclamer#v4 « proclame » — agent : jacob#e6
13. événement s'appeler#v5 « s'appellera » — theme : lieu#e7
14. événement voir#v6 « vu » — agent : jacob#e6; theme : dieu#e8 [portee=source, enonciateur=cité : Jacob]
15. événement graver#v7 « grave » — agent : jacob#e6; patient : pierre#e9
16. relation huile#e2 —sur→ toile#e3 [portee=oeuvre]
17. coréférence penuel#e1 = lieu#e7

## validation — k 76, variante_roles_inverses (fr)

> Dans cette composition, la hiérarchie habituelle se trouve renversée : c'est Ignatius qui, assis, remet le parchemin scellé à un fondateur agenouillé devant lui. Le prélat d'Antioche occupe ainsi la place de l'autorité qui confirme, tandis que l'autre figure reçoit humblement le document. Le peintre organise la scène autour de ce geste de transmission, que la position assise d'Ignatius rend souverain. Une telle mise en scène relève de l'imagerie de légitimation, où une figure vénérée est chargée de garantir l'origine d'une institution. La sobriété de la composition concentre l'intérêt sur le seul échange du parchemin.

1. entité composition#e1 « cette composition » [portee=oeuvre]
2. entité hiérarchie#e2 « la hiérarchie habituelle » ; propriétés : habituel, renversé
3. entité ignatius#e3 « Ignatius » ; noms : Ignatius
4. entité parchemin#e4 « le parchemin scellé » ; propriétés : scellé
5. entité fondateur#e5 « un fondateur »
6. entité prélat#e6 « Le prélat »
7. entité antioche#e7 « Antioche » ; noms : Antioche
8. entité place#e8 « la place »
9. entité autorité#e9 « l'autorité »
10. entité figure#e10 « l'autre figure » ; propriétés : autre
11. entité document#e11 « le document »
12. entité peintre#e12 « Le peintre » [portee=histoire]
13. entité scène#e13 « la scène »
14. entité geste#e14 « ce geste » ; propriétés : souverain
15. entité transmission#e15 « transmission »
16. entité position#e16 « la position assise » ; propriétés : assis
17. entité ignatius#e17 « Ignatius » ; noms : Ignatius
18. entité mise en scène#e18 « Une telle mise en scène » ; propriétés : tel [portee=oeuvre]
19. entité imagerie#e19 « l'imagerie » [portee=non_ancre]
20. entité légitimation#e20 « légitimation » [portee=non_ancre]
21. entité figure#e21 « une figure vénérée » ; propriétés : vénéré [portee=non_ancre]
22. entité origine#e22 « l'origine » [portee=non_ancre]
23. entité institution#e23 « une institution » [portee=non_ancre]
24. entité sobriété#e24 « La sobriété » [portee=oeuvre]
25. entité composition#e25 « la composition » [portee=oeuvre]
26. entité intérêt#e26 « l'intérêt » [portee=non_ancre]
27. entité échange#e27 « le seul échange » ; propriétés : seul
28. entité parchemin#e28 « parchemin »
29. événement s'asseoir#v1 « assis » — agent : ignatius#e3
30. événement remettre#v2 « remet » — agent : ignatius#e3; theme : parchemin#e4; destinataire : fondateur#e5
31. événement s'agenouiller#v3 « agenouillé » — agent : fondateur#e5; lieu : ignatius#e3
32. événement occuper#v4 « occupe » — agent : prélat#e6; theme : place#e8
33. événement confirmer#v5 « confirme » — agent : autorité#e9
34. événement recevoir#v6 « reçoit » — agent : figure#e10; theme : document#e11
35. événement organiser#v7 « organise » — agent : peintre#e12; theme : scène#e13; lieu : geste#e14 [portee=oeuvre]
36. événement transmettre#v8 « transmission » (nom d'action transmission)
37. événement rendre#v9 « rend » — agent : position#e16; theme : geste#e14 [portee=non_ancre]
38. événement relever#v10 « relève » — agent : mise en scène#e18; theme : imagerie#e19 [portee=non_ancre]
39. événement légitimer#v11 « légitimation » (nom d'action légitimation) [portee=non_ancre]
40. événement charger#v12 « est chargée » — theme : figure#e21 [portee=non_ancre]
41. événement garantir#v13 « garantir » — agent : figure#e21; theme : origine#e22 [portee=non_ancre]
42. événement concentrer#v14 « concentre » — agent : sobriété#e24; theme : intérêt#e26; lieu : échange#e27 [portee=non_ancre]
43. événement échanger#v15 « échange » (nom d'action échange) — theme : parchemin#e28
44. relation hiérarchie#e2 —dans→ composition#e1
45. relation prélat#e6 —de→ antioche#e7
46. relation place#e8 —de→ autorité#e9
47. relation geste#e14 —de→ transmission#e15
48. relation position#e16 —de→ ignatius#e17
49. relation imagerie#e19 —de→ légitimation#e20
50. relation origine#e22 —de→ institution#e23
51. relation sobriété#e24 —de→ composition#e25
52. relation échange#e27 —de→ parchemin#e28
53. coréférence ignatius#e3 = prélat#e6 = ignatius#e17
54. coréférence fondateur#e5 = figure#e10
55. coréférence parchemin#e4 = document#e11 = parchemin#e28
56. coréférence composition#e1 = composition#e25
57. distincts prélat#e6 ≠ figure#e10

## validation — k 156, variante_roles_inverses (fr) — annoté deux fois

> La scène inverse les rôles attendus : c'est le reptile qui tient la pomme et la croque, tandis qu'Adam et Ève le regardent. L'animal devient l'acteur du geste, et le couple en est le spectateur. L'artiste place la créature au centre, enroulée autour de l'arbre, et dispose les deux figures humaines de part et d'autre, immobiles. La composition reste sobre et lisible, et la lumière égale n'accentue aucun détail particulier.

1. entité scène#e1 « La scène »
2. entité rôle#e2 « les rôles attendus » ; propriétés : attendu
3. entité reptile#e3 « le reptile »
4. entité pomme#e4 « la pomme »
5. entité adam#e5 « Adam » ; noms : Adam
6. entité ève#e6 « Ève » ; noms : Ève
7. entité animal#e7 « L'animal »
8. entité acteur#e8 « l'acteur »
9. entité geste#e9 « geste »
10. entité couple#e10 « le couple »
11. entité spectateur#e11 « le spectateur »
12. entité artiste#e12 « L'artiste » [portee=histoire]
13. entité créature#e13 « la créature »
14. entité centre#e14 « centre »
15. entité arbre#e15 « l'arbre »
16. entité figure#e16 « les deux figures humaines » ; propriétés : humain, immobile ; nombre 2
17. entité composition#e17 « La composition » ; propriétés : sobre, lisible [portee=oeuvre]
18. entité lumière#e18 « la lumière égale » ; propriétés : égal
19. entité détail#e19 « aucun détail particulier » ; propriétés : particulier [polarite=neg]
20. événement inverser#v1 « inverse » — agent : scène#e1; theme : rôle#e2
21. événement tenir#v2 « tient » — agent : reptile#e3; theme : pomme#e4
22. événement croquer#v3 « croque » — agent : reptile#e3; patient : pomme#e4
23. événement regarder#v4 « regardent » — agent : adam#e5, ève#e6; theme : reptile#e3
24. événement placer#v5 « place » — agent : artiste#e12; theme : créature#e13; lieu : centre#e14 [portee=oeuvre]
25. événement enrouler#v6 « enroulée » — theme : créature#e13; lieu : arbre#e15
26. événement disposer#v7 « dispose » — agent : artiste#e12; theme : figure#e16 [portee=oeuvre]
27. événement accentuer#v8 « accentue » — agent : lumière#e18; theme : détail#e19 [modalite=non_affirme]
28. relation acteur#e8 —de→ geste#e9
29. relation spectateur#e11 —de→ geste#e9
30. coréférence reptile#e3 = animal#e7 = acteur#e8 = créature#e13
31. coréférence couple#e10 = spectateur#e11 = figure#e16

## validation — k 121, indetermine (en)

> A workman bends over a bench, holding a tool. Neither the tool nor the action it performs is visible, as the man's body and the angle of view conceal them. The catalogue therefore cannot say what work is being carried out. The painting records a posture of concentration and the setting of the bench, but leaves the nature of the task undetermined. The subdued light of the workshop adds to the obscurity of the scene.

1. entité workman#e1 « A workman »
2. entité bench#e2 « a bench »
3. entité tool#e3 « a tool »
4. entité tool#e4 « the tool » [polarite=neg]
5. entité action#e5 « the action » [polarite=neg]
6. entité body#e6 « body »
7. entité man#e7 « the man »
8. entité angle#e8 « the angle »
9. entité view#e9 « view »
10. entité catalogue#e10 « The catalogue » [portee=non_ancre]
11. entité work#e11 « what work » [modalite=non_affirme]
12. entité painting#e12 « The painting » [portee=oeuvre]
13. entité posture#e13 « a posture »
14. entité concentration#e14 « concentration »
15. entité setting#e15 « the setting »
16. entité bench#e16 « the bench »
17. entité nature#e17 « the nature » ; propriétés : undetermined
18. entité task#e18 « the task »
19. entité light#e19 « The subdued light » ; propriétés : subdued
20. entité workshop#e20 « the workshop »
21. entité obscurity#e21 « the obscurity »
22. entité scene#e22 « the scene »
23. événement bend#v1 « bends » — agent : workman#e1; lieu : bench#e2
24. événement hold#v2 « holding » — agent : workman#e1; theme : tool#e3
25. événement perform#v3 « performs » — agent : tool#e4; theme : action#e5 [modalite=non_affirme]
26. événement conceal#v4 « conceal » — agent : body#e6, angle#e8; theme : tool#e4, action#e5
27. événement say#v5 « cannot say » — agent : catalogue#e10 [polarite=neg, portee=non_ancre]
28. événement carry out#v6 « is being carried out » — theme : work#e11 [modalite=non_affirme]
29. événement leave#v7 « leaves » — agent : painting#e12; theme : nature#e17 [portee=oeuvre]
30. événement add#v8 « adds » — agent : light#e19; patient : obscurity#e21
31. relation body#e6 —of→ man#e7
32. relation angle#e8 —of→ view#e9
33. relation posture#e13 —of→ concentration#e14
34. relation setting#e15 —of→ bench#e16
35. relation nature#e17 —of→ task#e18
36. relation light#e19 —of→ workshop#e20
37. relation obscurity#e21 —of→ scene#e22
38. coréférence workman#e1 = man#e7
39. coréférence tool#e3 = tool#e4
40. coréférence bench#e2 = bench#e16
41. coréférence work#e11 = task#e18

## validation — k 41, indetermine (en) — annoté deux fois

> A figure stands among dense foliage, which hides the whole of its lower body. Only the upper part emerges from the leaves, and on one arm a few scales can be made out. These scales are the only unusual sign, and they are not enough to tell what kind of being is meant. Its nature therefore remains unclear: the image does not reveal whether the figure is human, animal or something in between. The foliage fills the foreground and the space behind the figure is left dark, so that no other detail helps the viewer.

1. entité figure#e1 « A figure »
2. entité foliage#e2 « dense foliage » ; propriétés : dense
3. entité body#e3 « its lower body » ; propriétés : lower
4. entité part#e4 « the upper part » ; propriétés : upper
5. entité leaf#e5 « the leaves »
6. entité arm#e6 « one arm » ; nombre 1
7. entité scale#e7 « a few scales »
8. entité scale#e8 « These scales »
9. entité sign#e9 « the only unusual sign » ; propriétés : only, unusual
10. entité kind#e10 « kind » [modalite=non_affirme]
11. entité being#e11 « being » [modalite=non_affirme]
12. entité nature#e12 « Its nature » ; propriétés : unclear
13. entité image#e13 « the image » [portee=oeuvre]
14. entité figure#e14 « the figure » ; propriétés : human [modalite=possible], animal [modalite=possible]
15. entité foliage#e15 « The foliage »
16. entité foreground#e16 « the foreground »
17. entité space#e17 « the space » ; propriétés : dark
18. entité figure#e18 « the figure »
19. entité detail#e19 « no other detail » ; propriétés : other [polarite=neg]
20. entité viewer#e20 « the viewer » [portee=non_ancre]
21. événement stand#v1 « stands » — agent : figure#e1; lieu : foliage#e2
22. événement hide#v2 « hides » — agent : foliage#e2; theme : body#e3
23. événement emerge#v3 « emerges » — agent : part#e4
24. événement tell#v4 « tell » — agent : scale#e8 [polarite=neg]
25. événement reveal#v5 « reveal » — agent : image#e13 [polarite=neg]
26. événement fill#v6 « fills » — agent : foliage#e15; theme : foreground#e16
27. événement leave#v7 « left » — theme : space#e17
28. événement help#v8 « helps » — agent : detail#e19; destinataire : viewer#e20 [modalite=non_affirme]
29. relation body#e3 —of→ figure#e1
30. relation part#e4 —from→ leaf#e5
31. relation scale#e7 —on→ arm#e6
32. relation kind#e10 —of→ being#e11
33. relation nature#e12 —of→ figure#e1
34. relation space#e17 —behind→ figure#e18
35. coréférence figure#e1 = figure#e14 = figure#e18
36. coréférence foliage#e2 = leaf#e5 = foliage#e15
37. coréférence scale#e7 = scale#e8 = sign#e9

## validation — k 161, negatif (en)

> Jeremiah laments over the ruins of Jerusalem. The prophet sits or kneels amid fallen stones, his head bowed in grief, while the destroyed city stretches behind him. No crowd is addressed and no rebuke is uttered: the image is one of mourning rather than of preaching. Such representations of the lamenting prophet enjoyed considerable popularity, offering painters an occasion to combine an expressive figure with a landscape of desolation. The muted palette and the slumped posture convey a sense of irrevocable loss, in keeping with the elegiac tradition associated with the prophet.

1. entité jeremiah#e1 « Jeremiah » ; noms : Jeremiah
2. entité ruin#e2 « the ruins »
3. entité jerusalem#e3 « Jerusalem » ; noms : Jerusalem
4. entité prophet#e4 « The prophet »
5. entité stone#e5 « fallen stones » ; propriétés : fallen
6. entité head#e6 « his head »
7. entité grief#e7 « grief »
8. entité city#e8 « the destroyed city » ; propriétés : destroyed
9. entité crowd#e9 « No crowd » [polarite=neg]
10. entité rebuke#e10 « no rebuke » [polarite=neg]
11. entité image#e11 « the image » [portee=oeuvre]
12. entité mourning#e12 « mourning »
13. entité preaching#e13 « preaching » [polarite=neg]
14. entité representation#e14 « Such representations » [portee=autre_oeuvre]
15. entité prophet#e15 « the lamenting prophet » [portee=autre_oeuvre]
16. entité popularity#e16 « considerable popularity » ; propriétés : considerable [portee=non_ancre]
17. entité painter#e17 « painters » [portee=non_ancre]
18. entité occasion#e18 « an occasion » [portee=non_ancre]
19. entité figure#e19 « an expressive figure » ; propriétés : expressive [portee=autre_oeuvre]
20. entité landscape#e20 « a landscape » [portee=autre_oeuvre]
21. entité desolation#e21 « desolation » [portee=autre_oeuvre]
22. entité palette#e22 « The muted palette » ; propriétés : muted [portee=oeuvre]
23. entité posture#e23 « the slumped posture » ; propriétés : slumped
24. entité sense#e24 « a sense »
25. entité loss#e25 « irrevocable loss » ; propriétés : irrevocable
26. entité tradition#e26 « the elegiac tradition » ; propriétés : elegiac [portee=non_ancre]
27. entité prophet#e27 « the prophet » [portee=non_ancre]
28. événement lament#v1 « laments » — agent : jeremiah#e1; theme : ruin#e2
29. événement sit#v2 « sits » — agent : prophet#e4; lieu : stone#e5
30. événement kneel#v3 « kneels » — agent : prophet#e4; lieu : stone#e5
31. événement bow#v4 « bowed » — theme : head#e6
32. événement address#v6 « addressed » — destinataire : crowd#e9 [modalite=non_affirme]
33. événement utter#v7 « uttered » — theme : rebuke#e10 [modalite=non_affirme]
34. événement mourn#v8 « mourning » (nom d'action mourning)
35. événement preach#v9 « preaching » (nom d'action preaching) [polarite=neg]
36. événement lament#v10 « lamenting » — agent : prophet#e15 [portee=autre_oeuvre]
37. événement enjoy#v11 « enjoyed » — agent : representation#e14; theme : popularity#e16 [portee=non_ancre]
38. événement offer#v12 « offering » — agent : representation#e14; destinataire : painter#e17; theme : occasion#e18 [portee=non_ancre]
39. événement combine#v13 « combine » — agent : painter#e17; theme : figure#e19, landscape#e20 [portee=autre_oeuvre]
40. événement convey#v14 « convey » — agent : palette#e22, posture#e23; theme : sense#e24
41. événement associate#v15 « associated » — theme : tradition#e26; instrument : prophet#e27 [portee=non_ancre]
42. relation ruin#e2 —of→ jerusalem#e3
43. relation head#e6 —of→ prophet#e4
44. relation head#e6 —in→ grief#e7
45. relation image#e11 —of→ mourning#e12
46. relation image#e11 —of→ preaching#e13 [polarite=neg]
47. relation representation#e14 —of→ prophet#e15
48. relation landscape#e20 —of→ desolation#e21
49. relation sense#e24 —of→ loss#e25
50. relation sense#e24 —in keeping with→ tradition#e26
51. relation city#e8 —behind→ prophet#e4
52. coréférence jeremiah#e1 = prophet#e4
53. coréférence jerusalem#e3 = city#e8
54. coréférence jeremiah#e1 = prophet#e27
55. alternative v2 | v3

## validation — k 91, negatif (en) — annoté deux fois

> Quentin is shown alone as iron spikes are driven into his shoulders. The image is one of torment, concentrated on the suffering of the young man and the brutal gesture of his tormentors. The painter places the action in the foreground and accentuates the violence of the scene, in keeping with the conventions of martyrdom imagery. No other holy figure accompanies him.

1. entité quentin#e1 « Quentin » ; noms : Quentin ; propriétés : alone
2. entité spike#e2 « iron spikes » ; propriétés : iron
3. entité shoulder#e3 « his shoulders »
4. entité image#e4 « The image » [portee=oeuvre]
5. entité torment#e5 « torment »
6. entité suffering#e6 « the suffering »
7. entité man#e7 « the young man » ; propriétés : young
8. entité gesture#e8 « the brutal gesture » ; propriétés : brutal
9. entité tormentor#e9 « his tormentors »
10. entité painter#e10 « The painter » [portee=histoire]
11. entité action#e11 « the action »
12. entité foreground#e12 « the foreground »
13. entité violence#e13 « the violence »
14. entité scene#e14 « the scene »
15. entité convention#e15 « the conventions » [portee=non_ancre]
16. entité imagery#e16 « martyrdom imagery » ; propriétés : martyrdom [portee=non_ancre]
17. entité figure#e17 « No other holy figure » ; propriétés : other, holy [polarite=neg]
18. événement drive#v1 « are driven » — theme : spike#e2; lieu : shoulder#e3
19. événement torment#v2 « torment » (nom d'action torment)
20. événement concentrate#v3 « concentrated » — theme : image#e4; instrument : suffering#e6, gesture#e8 [portee=oeuvre]
21. événement suffer#v4 « suffering » (nom d'action suffering) — agent : man#e7
22. événement place#v5 « places » — agent : painter#e10; theme : action#e11; lieu : foreground#e12 [portee=oeuvre]
23. événement accentuate#v6 « accentuates » — agent : painter#e10; theme : violence#e13 [portee=oeuvre]
24. événement accompany#v7 « accompanies » — agent : figure#e17; theme : quentin#e1 [modalite=non_affirme]
25. relation shoulder#e3 —of→ quentin#e1
26. relation image#e4 —of→ torment#e5
27. relation suffering#e6 —of→ man#e7
28. relation gesture#e8 —of→ tormentor#e9
29. relation tormentor#e9 —of→ man#e7
30. relation violence#e13 —of→ scene#e14
31. relation convention#e15 —of→ imagery#e16
32. coréférence quentin#e1 = man#e7
33. distincts quentin#e1 ≠ figure#e17

