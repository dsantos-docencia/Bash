#!/usr/bin/env bash
# Curso de Bash · Prof. Daniel Santos · github.com/dsantos-docencia/bash · © 2026 (PolyForm-NC · não comercial)
# Solução 11.02 — ^-?[0-9]+$ : sinal opcional e ao menos um dígito, do início ao fim.
if [[ "${1:-}" =~ ^-?[0-9]+$ ]]; then
    echo "numero"
else
    echo "nao"; exit 1
fi
