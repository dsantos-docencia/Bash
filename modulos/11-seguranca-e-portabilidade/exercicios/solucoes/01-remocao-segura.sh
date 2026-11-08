#!/usr/bin/env bash
# Curso de Bash · Prof. Daniel Santos · github.com/dsantos-docencia/bash · © 2026 (MIT)
# Solução 11.01 — validação em camadas antes de qualquer ação destrutiva.
alvo="${1:-}"
if [[ -z "$alvo" || "$alvo" == "/" || "$alvo" == *..* ]]; then
    echo "recusado" >&2
    exit 1
fi
echo "ok: removeria $alvo"
