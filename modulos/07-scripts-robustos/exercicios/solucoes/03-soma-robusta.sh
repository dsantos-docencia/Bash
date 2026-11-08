#!/usr/bin/env bash
# Curso de Bash · Prof. Daniel Santos · github.com/dsantos-docencia/bash · © 2026 (MIT)
# Solução 07.03
set -euo pipefail
total=0
for n in "$@"; do
    # 'total=$((...))' NÃO retorna status 1 quando o resultado é 0,
    # ao contrário de '(( total+=n ))'. Por isso é seguro sob set -e.
    total=$(( total + n ))
done
echo "$total"
