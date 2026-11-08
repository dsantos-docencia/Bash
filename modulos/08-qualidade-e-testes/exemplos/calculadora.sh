#!/usr/bin/env bash
# ============================================================================
#  Curso de Bash · Módulo 08 · calculadora.sh
#  Prof. Daniel Santos · github.com/dsantos-docencia/bash · © 2026 (PolyForm-NC · não comercial)
# ----------------------------------------------------------------------------
#  calculadora.sh — soma, subtrai, multiplica ou divide dois inteiros.
#  Uso: calculadora.sh [-v] -o SOMAR|SUBTRAIR|MULTIPLICAR|DIVIDIR A B
#  Serve de alvo para os testes Bats (calculadora.bats).
# ============================================================================
set -euo pipefail

verboso=0
operacao="SOMAR"

uso() {
    cat <<FIM
uso: $(basename "$0") [-v] [-o OPERACAO] A B
  -o OPERACAO   SOMAR (padrão), SUBTRAIR, MULTIPLICAR, DIVIDIR
  -v            modo verboso (mostra a conta)
  -h            esta ajuda
FIM
}

erro() { echo "erro: $*" >&2; exit 1; }

while getopts "vo:h" opt; do
    case "$opt" in
        v) verboso=1 ;;
        o) operacao="$OPTARG" ;;
        h) uso; exit 0 ;;
        *) uso >&2; exit 2 ;;
    esac
done
shift $(( OPTIND - 1 ))

(( $# == 2 )) || { uso >&2; exit 2; }
a="$1"; b="$2"

# Validação: só aceitamos inteiros (com sinal opcional).
[[ "$a" =~ ^-?[0-9]+$ && "$b" =~ ^-?[0-9]+$ ]] || erro "A e B devem ser inteiros"

case "$operacao" in
    SOMAR)       r=$(( a + b )); sinal="+" ;;
    SUBTRAIR)    r=$(( a - b )); sinal="-" ;;
    MULTIPLICAR) r=$(( a * b )); sinal="x" ;;
    DIVIDIR)     (( b == 0 )) && erro "divisão por zero"; r=$(( a / b )); sinal="/" ;;
    *)           erro "operação desconhecida: $operacao" ;;
esac

if (( verboso )); then
    echo "$a $sinal $b = $r"
else
    echo "$r"
fi
