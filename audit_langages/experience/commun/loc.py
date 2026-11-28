#!/usr/bin/env python3
"""Lignes de code (hors lignes vides, commentaires et docstrings/blocs /* */), par section « # ---- » ou « % ---- ».
Usage : python3 -I loc.py FICHIER..."""
import re, sys

def sections(path):
    py = path.endswith(".py")
    total, cur, out = 0, "(en-tête)", {}
    in_doc = False
    for l in open(path, encoding="utf-8"):
        s = l.strip()
        m = re.match(r"^(#|%) -{5,}\s*(.*?)\s*-*\s*$", s)
        if m:
            cur = m.group(2) or cur
            continue
        if py:
            if s.startswith('"""'):
                if not (len(s) > 3 and s.endswith('"""')):
                    in_doc = not in_doc
                continue
            if in_doc or not s or s.startswith("#"):
                continue
        else:
            if s.startswith("/*"):
                if "*/" not in s:
                    in_doc = True
                continue
            if in_doc:
                if "*/" in s:
                    in_doc = False
                continue
            if not s or s.startswith("%"):
                continue
        out[cur] = out.get(cur, 0) + 1
        total += 1
    return total, out

for p in sys.argv[1:]:
    t, o = sections(p)
    print(p, t)
    for k, v in o.items():
        print("   ", v, k)
