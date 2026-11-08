#!/usr/bin/env bash
# ============================================================================
#  Curso de Bash · Módulo 05 · Exemplo 03 — Strings nativas (sem sed/cut)
#  Prof. Daniel Santos · github.com/dsantos-docencia/bash · © 2026 (MIT)
# ----------------------------------------------------------------------------
#  OBJETIVO  Resolver com expansão de parâmetros o que muita gente resolve
#            (mais devagar) chamando sed/cut/basename.
#  EXECUTE   bash 03-strings-nativas.sh
# ============================================================================
set -uo pipefail

arq="/var/log/app/relatorio.final.txt"
echo "Caminho de exemplo: $arq"
echo
echo "Operações de caminho, SEM chamar nenhum programa externo:"
printf '   basename  (${arq##*/})      → %s\n' "${arq##*/}"
printf '   dirname   (${arq%%/*} parc) → %s\n' "${arq%/*}"
printf '   sem ext   (${arq%%.*} max)  → %s\n' "${arq%%.*}"
printf '   só a ext  (${arq##*.})      → %s\n' "${arq##*.}"
printf '   trocar ext (.txt→.pdf)      → %s\n' "${arq%.txt}.pdf"
printf '   comprimento (${#arq})       → %s\n' "${#arq}"

echo
nome="  Daniel SANTOS  "
echo "Transformações de texto em [$nome]:"
printf '   maiúsculas (^^)  → [%s]\n' "${nome^^}"
printf '   minúsculas (,,)  → [%s]\n' "${nome,,}"
sem_espaco="${nome#"${nome%%[![:space:]]*}"}"   # remove espaços à esquerda
sem_espaco="${sem_espaco%"${sem_espaco##*[![:space:]]}"}"  # e à direita
printf '   sem espaços nas pontas → [%s]\n' "$sem_espaco"
printf '   trocar SANTOS→Silva     → [%s]\n' "${nome/SANTOS/Silva}"

echo
echo "Comparação de velocidade (10000 extrações de basename):"
inicio=$SECONDS
for ((i=0; i<10000; i++)); do base="${arq##*/}"; done
fim=$SECONDS
echo "   última extração: $base"
echo "   10000 extrações nativas levaram $(( fim - inicio ))s (nenhum processo criado)."
echo "   Chamar 'basename' 10000x criaria 10000 processos — muito mais lento."
