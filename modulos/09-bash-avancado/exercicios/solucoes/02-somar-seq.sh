#!/usr/bin/env bash
# Curso de Bash · Prof. Daniel Santos · github.com/dsantos-docencia/bash · © 2026 (MIT)
# Solução 09.02 — process substitution evita o subshell do pipe.
total=0
while read -r n; do
    total=$(( total + n ))
done < <(seq 1 "$1")
echo "$total"
