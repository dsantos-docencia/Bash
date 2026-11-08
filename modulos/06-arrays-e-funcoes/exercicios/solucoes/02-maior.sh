#!/usr/bin/env bash
# Curso de Bash · Prof. Daniel Santos · github.com/dsantos-docencia/bash · © 2026 (MIT)
# Solução 06.02 — começa com o 1º e compara com os demais.
maior="$1"; shift
for n in "$@"; do (( n > maior )) && maior="$n"; done
echo "$maior"
