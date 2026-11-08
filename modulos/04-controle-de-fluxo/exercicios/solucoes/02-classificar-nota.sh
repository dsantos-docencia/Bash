#!/usr/bin/env bash
# Curso de Bash · Prof. Daniel Santos · github.com/dsantos-docencia/bash · © 2026 (PolyForm-NC · não comercial)
# Solução 04.02 — a ordem importa: testamos do maior para o menor.
nota=$1
if   (( nota >= 9 )); then echo "A"
elif (( nota >= 7 )); then echo "B"
elif (( nota >= 5 )); then echo "C"
else                      echo "D"
fi
