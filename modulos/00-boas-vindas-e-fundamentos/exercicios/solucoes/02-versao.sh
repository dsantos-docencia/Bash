#!/usr/bin/env bash
# Curso de Bash · Prof. Daniel Santos · github.com/dsantos-docencia/bash · © 2026 (PolyForm-NC · não comercial)
# Solução 00.02 — BASH_VERSINFO é um array preenchido pelo próprio Bash.
# Índice 0 = versão maior, 1 = menor, 2 = patch. Chaves são obrigatórias
# para acessar elementos de array: $BASH_VERSINFO[1] estaria ERRADO.
echo "Bash ${BASH_VERSINFO[0]}.${BASH_VERSINFO[1]}"
