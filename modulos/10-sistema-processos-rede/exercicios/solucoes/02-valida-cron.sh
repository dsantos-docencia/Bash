#!/usr/bin/env bash
# Curso de Bash · Prof. Daniel Santos · github.com/dsantos-docencia/bash · © 2026 (PolyForm-NC · não comercial)
# Solução 10.02 — read -ra divide a string em campos pelo IFS (espaço).
read -ra campos <<< "$1"
if (( ${#campos[@]} == 5 )); then
    echo "ok"
else
    echo "invalido"; exit 1
fi
