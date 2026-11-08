#!/usr/bin/env bash
# Curso de Bash · Prof. Daniel Santos · github.com/dsantos-docencia/bash · © 2026 (MIT)
# Solução 09.03 — compara as versões ORDENADAS, sem arquivos temporários.
if diff <(sort "$1") <(sort "$2") >/dev/null; then
    echo "iguais"
else
    echo "diferentes"; exit 1
fi
