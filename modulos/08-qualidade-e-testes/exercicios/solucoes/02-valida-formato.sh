#!/usr/bin/env bash
# Curso de Bash · Prof. Daniel Santos · github.com/dsantos-docencia/bash · © 2026 (MIT)
# Solução 08.02 — \d{3}.\d{3}.\d{3}-\d{2}, com os pontos e o traço literais.
if [[ "$1" =~ ^[0-9]{3}\.[0-9]{3}\.[0-9]{3}-[0-9]{2}$ ]]; then
    echo "valido"
else
    echo "invalido"; exit 1
fi
