#!/usr/bin/env python3
"""Mesure le temps réel et le pic de mémoire d'une commande (enfants seulement), n fois.

Usage : python3 -I chrono.py ETIQUETTE N SORTIE.tsv -- COMMANDE...
Ajoute une ligne « etiquette, essai, secondes, Ko_max, code » par essai à SORTIE.tsv. Le pic mémoire est celui du plus
gros des enfants lancés jusque-là par ce processus : un processus par essai pour qu'il soit propre à l'essai.
"""
import os, subprocess, sys, time

etiquette, n, sortie = sys.argv[1], int(sys.argv[2]), sys.argv[3]
cmd = sys.argv[sys.argv.index("--") + 1:]
env = {**os.environ, "LANG": "C.UTF-8"}
for essai in range(1, n + 1):
    # un petit interpréteur intermédiaire isole le pic mémoire de chaque essai
    prog = ("import resource,subprocess,sys,time;t=time.perf_counter();"
            "r=subprocess.run(sys.argv[1:],stdout=subprocess.DEVNULL,stderr=subprocess.PIPE);"
            "d=time.perf_counter()-t;"
            "print(f'{d:.3f}\\t{resource.getrusage(resource.RUSAGE_CHILDREN).ru_maxrss}\\t{r.returncode}');"
            "sys.stderr.write(r.stderr.decode()[:300])")
    r = subprocess.run([sys.executable, "-I", "-c", prog, *cmd], capture_output=True, text=True, env=env)
    d, ko, code = r.stdout.strip().split("\t")
    with open(sortie, "a", encoding="utf-8") as f:
        f.write(f"{etiquette}\t{essai}\t{d}\t{ko}\t{code}\n")
    print(etiquette, essai, d, "s", ko, "Ko", "code", code, r.stderr.strip()[:200])
