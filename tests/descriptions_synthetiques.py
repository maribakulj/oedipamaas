"""Descriptions écrites pour les tests (aucune image réelle)."""

jerome = {"subject": {"title": "Saint Jerome in the wilderness", "source": "Golden Legend", "type": "saint", "confidence": 0.8, "alternatives": ["Saint Jerome penitent"]},
 "persons": [{"who": "Saint Jerome", "recognised_by": ["lion at his feet", "cardinal's hat", "skull"], "confidence": 0.85}],
 "entities": [{"id": "e1", "type": "man", "attributes": ["old", "bearded", "halo", "half naked", "kneeling"]}, {"id": "e2", "type": "lion", "attributes": []}, {"id": "e3", "type": "skull", "attributes": []}, {"id": "e4", "type": "crucifix", "attributes": []}],
 "relations": [["e1", "looks_at", "e4"]], "actions": ["praying", "penance"], "gestures_emotions": ["kneeling"], "concepts": ["penance", "transience: skull"],
 "roles": ["hermit"], "setting": ["wilderness", "rocks"], "texts": [], "genre_function": ["engraving"], "keywords": ["stone", "book"]}
david = {"subject": {"title": "David beheading Goliath", "source": "1 Samuel 17", "type": "biblical narrative", "confidence": 0.9, "alternatives": ["David with the head of Goliath"]},
 "persons": [{"who": "David", "recognised_by": ["youth with sling"], "confidence": 0.9}, {"who": "Goliath", "recognised_by": ["giant in armour"], "confidence": 0.9}],
 "entities": [{"id": "e1", "type": "boy", "attributes": ["sling"]}, {"id": "e2", "type": "giant", "attributes": ["armour", "lying"]}, {"id": "e3", "type": "sword", "attributes": []}],
 "relations": [["e1", "holds", "e3"]], "actions": ["beheading"], "keywords": ["sword", "sling", "stone"]}
