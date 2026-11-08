#!/usr/bin/env bash
# Curso de Bash · Prof. Daniel Santos · github.com/dsantos-docencia/bash · © 2026 (PolyForm-NC · não comercial)
# Solução 07.01
if (( $# != 1 )); then
    echo "uso: $(basename "$0") <nome>" >&2
    exit 2
fi
echo "Olá, $1"
