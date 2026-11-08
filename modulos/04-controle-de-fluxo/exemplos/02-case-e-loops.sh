#!/usr/bin/env bash
# ============================================================================
#  Curso de Bash · Módulo 04 · Exemplo 02 — case e laços
#  Prof. Daniel Santos · github.com/dsantos-docencia/bash · © 2026 (PolyForm-NC · não comercial)
# ----------------------------------------------------------------------------
#  OBJETIVO  case com padrões; for (lista/glob/C); while; break/continue.
#  EXECUTE   bash 02-case-e-loops.sh
# ============================================================================
set -uo pipefail

echo "1) case classifica uma entrada contra vários padrões:"
classificar() {
    case "$1" in
        *.jpg|*.png|*.gif) echo "   $1 → imagem" ;;
        *.txt|*.md)        echo "   $1 → texto" ;;
        *.sh)              echo "   $1 → script" ;;
        *)                 echo "   $1 → desconhecido" ;;
    esac
}
classificar foto.png
classificar leiame.md
classificar backup.sh
classificar dados.xyz

echo
echo "2) for sobre uma LISTA:"
for cor in vermelho verde azul; do printf '   %s\n' "$cor"; done

echo
echo "3) for estilo C (contador):"
for (( i=1; i<=3; i++ )); do printf '   iteração %d\n' "$i"; done

echo
echo "4) for sobre uma SEQUÊNCIA {1..5} e {a..e}:"
echo "   números: $(for n in {1..5}; do printf '%s ' "$n"; done)"
echo "   letras:  $(for l in {a..e}; do printf '%s ' "$l"; done)"

echo
echo "5) while com contador:"
c=0
while (( c < 3 )); do printf '   c=%d\n' "$c"; (( c++ )); done

echo
echo "6) break e continue:"
echo -n "   "
for i in {1..10}; do
    (( i % 2 == 0 )) && continue     # pula pares
    (( i > 7 )) && break             # para depois do 7
    printf '%d ' "$i"
done
echo "(ímpares até 7)"
