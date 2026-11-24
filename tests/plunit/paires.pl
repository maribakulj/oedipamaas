/*  Paires minimales (cahier des charges, § 12.3) : deux textes qui ne diffèrent que par un phénomène, et ce que
    chacun doit donner. Attentes, sur les assertions d'un texte :
      admis(X)          une entité de tête ou de nom X est admissible (peut fonder un code établi)
      pas_admis(X)      aucune entité de tête ou de nom X n'est admissible
      nie(X)            une entité X est niée, sur ce que l'image représente
      pas_nie(X)        aucune entité X n'est niée
      role(P, R, X)     un événement de prédicat P a X pour rôle R
      pas_role(P, R, X) l'événement P n'a pas X pour rôle R
      prop(X, P)        l'entité X a la propriété P, admissible
      pas_prop(X, P)    l'entité X n'a pas la propriété P
      modal(X, M)       l'entité X a la modalité M
      alt(X, Y)         X et Y sont deux hypothèses d'une même alternative
      portee(X, P)      l'entité X a la portée P
      rel(X, R, Y)      une relation R va de X à Y
    paire(Id, Langue, TexteA, AttentesA, TexteB, AttentesB).
    Un prédicat ou une propriété peut être une liste de lemmes admis (l'analyseur rend « slain » pour « slay »).
    erreur_connue(Id, Raison) : la paire échoue à cause de l'analyseur, pas des règles ; elle est signalée (fixme).
*/

erreur_connue(role_kill_en, 'UDPipe étiquette « kills » comme nom dans « Goliath kills David » (Goliath kills : pluriel)').

% --- Négation -------------------------------------------------------------------------------------------------------
paire(neg_sans, fr, "Saint Jérôme avec son lion.", [admis(lion)], "Saint Jérôme sans son lion.", [nie(lion), admis('Jérôme')]).
paire(neg_without, en, "Saint Jerome with his lion.", [admis(lion)], "Saint Jerome without his lion.", [nie(lion), admis('Jerome')]).
paire(neg_no, en, "A lion is lying in the foreground.", [admis(lion)], "No lion is lying in the foreground.", [nie(lion)]).
paire(neg_aucun, fr, "Un chien est couché au premier plan.", [admis(chien)], "Aucun chien n'est couché au premier plan.", [nie(chien)]).
paire(neg_visible_fr, fr, "Le crâne est visible.", [admis(crâne)], "Le crâne n'est pas visible.", [nie(crâne)]).
paire(neg_visible_en, en, "The skull is visible.", [admis(skull)], "The skull is not visible.", [nie(skull)]).
paire(neg_show_en, en, "The painting shows a dragon.", [admis(dragon)], "The painting does not show a dragon.", [nie(dragon)]).
paire(neg_montre_fr, fr, "Le tableau montre un dragon.", [admis(dragon)], "Le tableau ne montre pas de dragon.", [nie(dragon)]).
paire(neg_ni, fr, "Un ermite avec un lion et un crâne.", [admis(lion), admis(crâne)], "Un ermite, ni lion ni crâne.", [nie(lion), nie(crâne), admis(ermite)]).
paire(neg_neither, en, "A hermit with a lion and a skull.", [admis(lion), admis(skull)], "A hermit with neither lion nor skull.", [nie(lion), nie(skull), admis(hermit)]).
paire(neg_absent_fr, fr, "Un saint, son lion présent.", [admis(lion)], "Un saint, le lion absent.", [nie(lion), admis(saint)]).
paire(neg_missing_en, en, "A saint and his lion.", [admis(lion)], "A saint, the lion missing.", [nie(lion), admis(saint)]).
paire(neg_verbe_fr, fr, "L'ange tient une épée.", [role(tenir, agent, ange)], "L'ange ne tient pas d'épée.", [pas_admis(épée)]).
paire(neg_verbe_en, en, "The angel holds a sword.", [role(hold, agent, angel)], "The angel does not hold a sword.", [pas_admis(sword)]).
paire(neg_objet_fr, fr, "L'ange ne tient pas d'épée.", [nie(épée)], "L'ange ne regarde pas le livre.", [pas_admis(livre), pas_nie(livre), admis(ange)]).
paire(neg_objet_en, en, "The angel holds no sword.", [nie(sword)], "The angel does not look at the book.", [pas_admis(book), pas_nie(book), admis(angel)]).
paire(neg_portee_fr, fr, "Un chien et un chat.", [admis(chien), admis(chat)], "Un chien, sans chat.", [admis(chien), nie(chat)]).
paire(neg_portee_en, en, "A dog and a cat.", [admis(dog), admis(cat)], "A dog without a cat.", [admis(dog), nie(cat)]).
paire(neg_depicted_en, en, "A lion is depicted.", [admis(lion)], "No lion is depicted.", [nie(lion)]).
paire(neg_represente_fr, fr, "Un lion est représenté.", [admis(lion)], "Aucun lion n'est représenté.", [nie(lion)]).

% --- Rôles ----------------------------------------------------------------------------------------------------------
paire(role_tue_fr, fr, "David tue Goliath.", [role(tuer, agent, 'David'), role(tuer, patient, 'Goliath')], "Goliath tue David.", [role(tuer, agent, 'Goliath'), role(tuer, patient, 'David')]).
paire(role_kill_en, en, "David kills Goliath.", [role(kill, agent, 'David'), role(kill, patient, 'Goliath')], "Goliath kills David.", [role(kill, agent, 'Goliath'), role(kill, patient, 'David')]).
paire(role_passif_fr, fr, "David tue Goliath.", [role(tuer, agent, 'David')], "Goliath est tué par David.", [role(tuer, agent, 'David'), role(tuer, patient, 'Goliath')]).
paire(role_passif_en, en, "David kills Goliath.", [role(kill, agent, 'David')], "Goliath is killed by David.", [role(kill, agent, 'David'), role(kill, patient, 'Goliath')]).
paire(role_dragon_fr, fr, "Un homme tue un dragon.", [role(tuer, agent, homme), role(tuer, patient, dragon)], "Un dragon tue un homme.", [role(tuer, agent, dragon), role(tuer, patient, homme)]).
paire(role_dragon_en, en, "A man kills a dragon.", [role(kill, agent, man), role(kill, patient, dragon)], "A dragon kills a man.", [role(kill, agent, dragon), role(kill, patient, man)]).
paire(role_instrument_fr, fr, "David tue Goliath avec une épée.", [role(tuer, instrument, épée)], "David tue Goliath et une épée.", [pas_role(tuer, instrument, épée)]).
paire(role_instrument_en, en, "David kills Goliath with a sword.", [role(kill, instrument, sword)], "David kills Goliath and a sword.", [pas_role(kill, instrument, sword)]).
paire(role_participe_fr, fr, "Un ange tenant une épée.", [role(tenir, agent, ange), role(tenir, patient, épée)], "Une épée tenant un ange.", [role(tenir, agent, épée), role(tenir, patient, ange)]).
paire(role_participe_en, en, "An angel holding a sword.", [role(hold, agent, angel), role(hold, patient, sword)], "A sword holding an angel.", [role(hold, agent, sword), role(hold, patient, angel)]).
paire(role_relative_fr, fr, "Un ange qui tient une épée.", [role(tenir, agent, ange)], "Une épée que tient un ange.", [role(tenir, agent, ange), role(tenir, patient, épée)]).
paire(role_relative_en, en, "An angel who holds a sword.", [role(hold, agent, angel)], "A sword that an angel holds.", [role(hold, agent, angel), role(hold, patient, sword)]).
paire(role_menace_en, en, "An angel threatens a man with a sword.", [role(threaten, agent, angel), role(threaten, patient, man)], "A man threatens an angel with a sword.", [role(threaten, agent, man), role(threaten, patient, angel)]).
paire(role_menace_fr, fr, "Un ange menace un homme avec une épée.", [role(menacer, agent, ange), role(menacer, patient, homme)], "Un homme menace un ange avec une épée.", [role(menacer, agent, homme), role(menacer, patient, ange)]).
paire(role_regarde_fr, fr, "La femme regarde l'enfant.", [role(regarder, agent, femme), role(regarder, patient, enfant)], "L'enfant regarde la femme.", [role(regarder, agent, enfant), role(regarder, patient, femme)]).
paire(role_looks_en, en, "The woman watches the child.", [role(watch, agent, woman), role(watch, patient, child)], "The child watches the woman.", [role(watch, agent, child), role(watch, patient, woman)]).
paire(role_passif_dragon_en, en, "A dragon is slain by a knight.", [role([slay, slain], agent, knight), role([slay, slain], patient, dragon)], "A knight is slain by a dragon.", [role([slay, slain], agent, dragon), role([slay, slain], patient, knight)]).
paire(role_passif_dragon_fr, fr, "Un dragon est terrassé par un chevalier.", [role(terrasser, agent, chevalier), role(terrasser, patient, dragon)], "Un chevalier est terrassé par un dragon.", [role(terrasser, agent, dragon), role(terrasser, patient, chevalier)]).
paire(role_lieu_fr, fr, "Un ermite prie dans une grotte.", [role(prier, lieu, grotte)], "Un ermite prie avec une grotte.", [pas_role(prier, lieu, grotte)]).
paire(role_lieu_en, en, "A hermit prays in a cave.", [role(pray, lieu, cave)], "A hermit prays with a cave.", [pas_role(pray, lieu, cave)]).

% --- Propriétés et leur rattachement ---------------------------------------------------------------------------------
paire(prop_couronne_fr, fr, "Une femme couronnée à côté d'un homme.", [prop(femme, couronner), pas_prop(homme, couronner)], "Une femme à côté d'un homme couronné.", [prop(homme, couronner), pas_prop(femme, couronner)]).
paire(prop_crowned_en, en, "A crowned woman beside a man.", [prop(woman, crown), pas_prop(man, crown)], "A woman beside a crowned man.", [prop(man, crown), pas_prop(woman, crown)]).
paire(prop_vieux_fr, fr, "Un vieil homme et un jeune chien.", [prop(homme, vieux), prop(chien, jeune)], "Un jeune homme et un vieux chien.", [prop(homme, jeune), prop(chien, vieux)]).
paire(prop_old_en, en, "An old man and a young dog.", [prop(man, old), prop(dog, young)], "A young man and an old dog.", [prop(man, young), prop(dog, old)]).
paire(prop_attribut_fr, fr, "Le lion est couché.", [prop(lion, coucher)], "Le chien est couché.", [prop(chien, coucher), pas_admis(lion)]).
paire(prop_attribut_en, en, "The saint is old.", [prop(saint, old)], "The saint is young.", [prop(saint, young), pas_prop(saint, old)]).
paire(prop_genou_fr, fr, "Un saint agenouillé.", [prop(saint, agenouiller)], "Un saint debout.", [pas_prop(saint, agenouiller)]).
paire(prop_kneeling_en, en, "A kneeling saint.", [prop(saint, kneel)], "A standing saint.", [pas_prop(saint, kneel), prop(saint, stand)]).
paire(prop_nu_fr, fr, "Un homme nu tient un livre.", [prop(homme, nu), pas_prop(livre, nu)], "Un homme tient un livre nu.", [pas_prop(homme, nu)]).
paire(prop_red_en, en, "A man in a red cloak.", [prop(cloak, red), pas_prop(man, red)], "A red man in a cloak.", [prop(man, red), pas_prop(cloak, red)]).
paire(prop_ailes_fr, fr, "Un ange aux grandes ailes.", [prop(aile, grand)], "Un grand ange aux ailes.", [prop(ange, grand), pas_prop(aile, grand)]).
paire(prop_winged_en, en, "A winged horse and a man.", [prop(horse, winged), pas_prop(man, winged)], "A horse and a winged man.", [prop(man, winged), pas_prop(horse, winged)]).

% --- Modalité -------------------------------------------------------------------------------------------------------
paire(mod_peut_etre_fr, fr, "La scène représente l'Annonciation.", [admis(annonciation)], "La scène représente peut-être l'Annonciation.", [pas_admis(annonciation), modal(annonciation, possible)]).
paire(mod_may_en, en, "The scene represents the Annunciation.", [admis('Annunciation')], "The scene may represent the Annunciation.", [pas_admis('Annunciation'), modal('Annunciation', possible)]).
paire(mod_probablement_fr, fr, "Le saint est Jérôme.", [admis('Jérôme')], "Le saint est probablement Jérôme.", [pas_admis('Jérôme')]).
paire(mod_probably_en, en, "The saint is Jerome.", [admis('Jerome')], "The saint is probably Jerome.", [pas_admis('Jerome')]).
paire(mod_traditionnel_fr, fr, "Une figure identifiée comme sainte Catherine.", [admis('Catherine')], "Une figure traditionnellement identifiée comme sainte Catherine.", [pas_admis('Catherine'), modal('Catherine', traditionnel)]).
paire(mod_traditionally_en, en, "A figure identified as Saint Catherine.", [admis('Catherine')], "A figure traditionally identified as Saint Catherine.", [pas_admis('Catherine'), modal('Catherine', traditionnel)]).
paire(mod_autrefois_fr, fr, "Le tableau représente sainte Catherine.", [admis('Catherine')], "Le tableau représentait autrefois sainte Catherine.", [pas_admis('Catherine')]).
paire(mod_formerly_en, en, "The painting is identified as Saint Catherine.", [admis('Catherine')], "The painting was formerly identified as Saint Catherine.", [pas_admis('Catherine'), modal('Catherine', ancien)]).
paire(mod_semble_fr, fr, "Le personnage tient un livre.", [admis(livre)], "Le personnage semble tenir un livre.", [pas_admis(livre)]).
paire(mod_seems_en, en, "The figure holds a book.", [admis(book)], "The figure seems to hold a book.", [pas_admis(book)]).
paire(mod_possibly_en, en, "The animal is a lion.", [admis(lion)], "The animal is possibly a lion.", [pas_admis(lion)]).
paire(mod_pourrait_fr, fr, "Le personnage est saint Pierre.", [admis('Pierre')], "Le personnage pourrait être saint Pierre.", [pas_admis('Pierre')]).
paire(mod_might_en, en, "The figure is Saint Peter.", [admis('Peter')], "The figure might be Saint Peter.", [pas_admis('Peter')]).

% --- Alternatives ---------------------------------------------------------------------------------------------------
paire(alt_ou_fr, fr, "L'Annonciation et la Visitation.", [admis(annonciation), admis(visitation)], "L'Annonciation ou la Visitation.", [alt(annonciation, visitation), pas_admis(annonciation), pas_admis(visitation)]).
paire(alt_or_en, en, "The Annunciation and the Visitation.", [admis('Annunciation'), admis('Visitation')], "The Annunciation or the Visitation.", [alt('Annunciation', 'Visitation'), pas_admis('Annunciation')]).
paire(alt_saint_fr, fr, "Saint Pierre et saint Paul.", [admis('Pierre'), admis('Paul')], "Saint Pierre ou saint Paul.", [pas_admis('Pierre'), pas_admis('Paul')]).
paire(alt_saint_en, en, "Saint Peter and Saint Paul.", [admis('Peter'), admis('Paul')], "Saint Peter or Saint Paul.", [pas_admis('Peter'), pas_admis('Paul')]).
paire(alt_animal_fr, fr, "Un chien et un loup.", [admis(chien), admis(loup)], "Un chien ou un loup.", [alt(chien, loup)]).
paire(alt_animal_en, en, "A dog and a wolf.", [admis(dog), admis(wolf)], "A dog or a wolf.", [alt(dog, wolf)]).

% --- Portée : autre œuvre, œuvre ------------------------------------------------------------------------------------
paire(portee_apres_fr, fr, "Une Crucifixion.", [admis(crucifixion)], "D'après une Crucifixion de Rubens.", [portee(crucifixion, autre_oeuvre), pas_admis(crucifixion)]).
paire(portee_after_en, en, "A Crucifixion.", [admis('Crucifixion')], "After a Crucifixion by Rubens.", [portee('Crucifixion', autre_oeuvre), pas_admis('Crucifixion')]).
paire(portee_huile_fr, fr, "Un paysage avec une toile tendue.", [admis(paysage)], "Un paysage, huile sur toile.", [portee(huile, oeuvre), pas_admis(huile), admis(paysage)]).
paire(portee_oil_en, en, "A landscape.", [admis(landscape)], "A landscape, oil on canvas.", [portee(oil, oeuvre), pas_admis(oil), admis(landscape)]).
paire(portee_gravure_fr, fr, "Un berger et son troupeau.", [admis(berger)], "D'après une gravure de Dürer.", [pas_admis(gravure)]).
paire(portee_print_en, en, "A shepherd and his flock.", [admis(shepherd)], "After a print by Dürer.", [pas_admis(print)]).

% --- Noms et titres -------------------------------------------------------------------------------------------------
paire(nom_saint_fr, fr, "Saint Jérôme.", [admis('Jérôme'), admis(saint)], "Jérôme.", [admis('Jérôme')]).
paire(nom_saint_en, en, "Saint Jerome.", [admis('Jerome'), admis(saint)], "Jerome.", [admis('Jerome')]).
paire(nom_compose_fr, fr, "Saint Jean Baptiste.", [admis('Jean Baptiste')], "Saint Jean.", [admis('Jean'), pas_admis('Jean Baptiste')]).
paire(nom_compose_en, en, "Saint John the Baptist.", [admis('John the Baptist')], "Saint John.", [admis('John'), pas_admis('John the Baptist')]).
paire(nom_deux_fr, fr, "David et Goliath.", [admis('David'), admis('Goliath')], "David.", [admis('David'), pas_admis('Goliath')]).
paire(nom_deux_en, en, "David and Goliath.", [admis('David'), admis('Goliath')], "David.", [admis('David'), pas_admis('Goliath')]).

% --- Relations entre référents --------------------------------------------------------------------------------------
paire(rel_avec_fr, fr, "Un homme avec un chien.", [rel(homme, avec, chien)], "Un chien avec un homme.", [rel(chien, avec, homme)]).
paire(rel_with_en, en, "A man with a dog.", [rel(man, with, dog)], "A dog with a man.", [rel(dog, with, man)]).
paire(rel_sur_fr, fr, "Un oiseau sur un arbre.", [rel(oiseau, sur, arbre)], "Un arbre sur un oiseau.", [rel(arbre, sur, oiseau)]).
paire(rel_on_en, en, "A bird on a tree.", [rel(bird, on, tree)], "A tree on a bird.", [rel(tree, on, bird)]).

% --- Titres usuels --------------------------------------------------------------------------------------------------
paire(titre_etude_fr, fr, "Saint Jérôme dans son étude.", [admis('Jérôme'), admis(étude)], "Saint Jérôme sans son étude.", [admis('Jérôme'), nie(étude)]).
paire(titre_study_en, en, "Saint Jerome in his study.", [admis('Jerome'), admis(study)], "Saint Jerome without his study.", [admis('Jerome'), nie(study)]).
paire(titre_nature_morte_fr, fr, "Nature morte au homard.", [admis(homard)], "Nature morte sans homard.", [nie(homard)]).
paire(titre_still_life_en, en, "Still life with a lobster.", [admis(lobster)], "Still life without a lobster.", [nie(lobster)]).
paire(titre_portrait_fr, fr, "Portrait d'homme.", [admis(portrait), admis(homme)], "Portrait de femme.", [admis(femme), pas_admis(homme)]).
paire(titre_portrait_en, en, "Portrait of a man.", [admis(portrait), admis(man)], "Portrait of a woman.", [admis(woman), pas_admis(man)]).
paire(titre_sacrifice_fr, fr, "Le Sacrifice d'Isaac.", [admis(sacrifice), admis('Isaac')], "Le Sacrifice d'Iphigénie.", [admis('Iphigénie'), pas_admis('Isaac')]).
paire(titre_sacrifice_en, en, "The Sacrifice of Isaac.", [admis('Isaac')], "The Sacrifice of Iphigenia.", [admis('Iphigenia'), pas_admis('Isaac')]).
paire(titre_allegorie_fr, fr, "Allégorie de la Vanité.", [admis(allégorie)], "Allégorie de la Prudence.", [admis(allégorie), pas_admis(vanité)]).
paire(titre_allegory_en, en, "Allegory of Vanity.", [admis(allegory)], "Allegory of Prudence.", [admis(allegory), pas_admis('Vanity')]).

% --- Invariants : une phrase sans rapport, une répétition ----------------------------------------------------------
paire(inv_ajout_fr, fr, "Un lion.", [admis(lion)], "Un lion. Le cadre est doré.", [admis(lion)]).
paire(inv_ajout_en, en, "A lion.", [admis(lion)], "A lion. The frame is gilded.", [admis(lion)]).
paire(inv_repetition_fr, fr, "Un lion.", [admis(lion), pas_admis(crâne)], "Un lion, un lion, un lion.", [admis(lion), pas_admis(crâne)]).
paire(inv_repetition_en, en, "A lion.", [admis(lion), pas_admis(skull)], "A lion, a lion, a lion.", [admis(lion), pas_admis(skull)]).
paire(inv_negation_fr, fr, "Un lion, un crâne.", [admis(lion), admis(crâne)], "Un lion, sans crâne.", [admis(lion), nie(crâne)]).
paire(inv_negation_en, en, "A lion, a skull.", [admis(lion), admis(skull)], "A lion, without a skull.", [admis(lion), nie(skull)]).
paire(inv_ordre_fr, fr, "Un lion et un crâne.", [admis(lion), admis(crâne)], "Un crâne et un lion.", [admis(lion), admis(crâne)]).
paire(inv_ordre_en, en, "A lion and a skull.", [admis(lion), admis(skull)], "A skull and a lion.", [admis(lion), admis(skull)]).
paire(inv_modal_ajout_fr, fr, "Un lion. Un crâne.", [admis(lion), admis(crâne)], "Un lion. Peut-être un crâne.", [admis(lion), pas_admis(crâne)]).
paire(inv_modal_ajout_en, en, "A lion. A skull.", [admis(lion), admis(skull)], "A lion. Perhaps a skull.", [admis(lion), pas_admis(skull)]).
