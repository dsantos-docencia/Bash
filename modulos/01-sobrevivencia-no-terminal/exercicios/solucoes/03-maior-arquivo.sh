#!/usr/bin/env bash
# Curso de Bash · Prof. Daniel Santos · github.com/dsantos-docencia/bash · © 2026 (PolyForm-NC · não comercial)
# Solução 01.03
# -printf '%s %p\n' imprime 'tamanho caminho'; ordenamos numericamente e
# pegamos a última linha (a maior). cut remove a coluna do tamanho.
find "$1" -type f -printf '%s %p\n' | sort -n | tail -1 | cut -d' ' -f2-
