#!/usr/bin/env bash
# ============================================================================
#  Curso de Bash · Módulo 03 · Exemplo 01 — Argumentos de linha de comando
#  Prof. Daniel Santos · github.com/dsantos-docencia/bash · © 2026 (MIT)
# ----------------------------------------------------------------------------
#  OBJETIVO  Ver $0, $1, $#, "$@" e "$*" com argumentos reais.
#  EXECUTE   bash 01-argumentos.sh um "dois com espaço" três
#            (o próprio script se chama com exemplos se você não passar nada)
# ============================================================================
set -euo pipefail

# Se o script foi chamado SEM argumentos, ele se re-executa com exemplos,
# para que o aluno veja o resultado mesmo rodando "bash 01-argumentos.sh".
if (( $# == 0 )); then
    echo "(nenhum argumento informado — rodando uma demonstração)"
    echo
    exec bash "$0" laranja "maçã verde" 42
fi

printf 'Nome do script ($0): %s\n' "$0"
printf 'Quantidade ($#):     %s\n' "$#"
printf 'Primeiro ($1):       %s\n' "$1"
printf 'Segundo ($2):        %s\n' "$2"
echo

echo 'Percorrendo "$@" (cada argumento preservado, com espaços e tudo):'
i=1
for arg in "$@"; do
    printf '   arg %d = [%s]\n' "$i" "$arg"
    (( i++ ))
done

echo
echo 'Diferença entre "$@" e "$*":'
contar() { echo "   recebi $# pedaço(s)"; }
echo '   com "$@":'; contar "$@"     # preserva 3 argumentos
echo '   com "$*":'; contar "$*"     # vira 1 texto só
echo
echo 'Regra: para repassar argumentos adiante, use SEMPRE "$@".'
