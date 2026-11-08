#!/usr/bin/env bash
# Curso de Bash · Prof. Daniel Santos · github.com/dsantos-docencia/bash · © 2026 (PolyForm-NC · não comercial)
# Solução 07.02
if (( $2 == 0 )); then
    echo "erro: divisao por zero" >&2
    exit 1
fi
echo $(( $1 / $2 ))
