#!/usr/bin/env bash
# ============================================================================
#  Curso de Bash · Módulo 06 · Exemplo 02 — Funções
#  Prof. Daniel Santos · github.com/dsantos-docencia/bash · © 2026 (MIT)
# ----------------------------------------------------------------------------
#  OBJETIVO  Parâmetros, return (código) vs echo (valor), local, nameref.
#  EXECUTE   bash 02-funcoes.sh
# ============================================================================
set -uo pipefail

echo "1) Função que RETORNA UM VALOR (via echo + captura):"
dobro() { echo $(( $1 * 2 )); }
r=$(dobro 21)
echo "   dobro(21) = $r"

echo
echo "2) Função que RETORNA SUCESSO/FRACASSO (via return / código de saída):"
eh_par() { (( $1 % 2 == 0 )); }          # a expressão define o status
for n in 4 7; do
    if eh_par "$n"; then echo "   $n é par"; else echo "   $n é ímpar"; fi
done

echo
echo "3) 'local' impede vazamento de variáveis:"
i="valor-de-fora"
conta_ate() {
    local i                               # sem este 'local', a de fora seria destruída
    for (( i=1; i<="$1"; i++ )); do printf '%d ' "$i"; done
    echo
}
printf '   contando: '; conta_ate 3
echo "   e lá fora, i ainda vale: [$i]"

echo
echo "4) Vários argumentos com \"\$@\":"
somar() {
    local total=0 n
    for n in "$@"; do (( total += n )); done
    echo "$total"
}
echo "   soma(10 20 30 5) = $(somar 10 20 30 5)"

echo
echo "5) Nameref (local -n): 'retornar' sem subshell (Bash 4.3+):"
primeiro_e_ultimo() {
    local -n _saida=$1    # _saida é um APELIDO para a variável cujo nome veio em $1
    shift
    _saida="$1 ... ${!#}" # ${!#} = o último argumento
}
primeiro_e_ultimo resultado alfa beta gama delta
echo "   resultado = $resultado"
