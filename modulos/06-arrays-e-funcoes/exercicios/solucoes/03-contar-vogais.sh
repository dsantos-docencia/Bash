#!/usr/bin/env bash
# Curso de Bash · Prof. Daniel Santos · github.com/dsantos-docencia/bash · © 2026 (MIT)
# Solução 06.03 — percorre cada caractere e conta se for vogal.
palavra="$1"; total=0
for (( i=0; i<${#palavra}; i++ )); do
    c="${palavra:i:1}"
    case "$c" in a|e|i|o|u) (( total++ )) ;; esac
done
echo "$total"
