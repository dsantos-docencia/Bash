#!/usr/bin/env bash
# Curso de Bash · Prof. Daniel Santos · github.com/dsantos-docencia/bash · © 2026 (MIT)
# Solução 06.01
somar() { local t=0 n; for n in "$@"; do (( t += n )); done; echo "$t"; }
total=$(somar "$@")
echo $(( total / $# ))
