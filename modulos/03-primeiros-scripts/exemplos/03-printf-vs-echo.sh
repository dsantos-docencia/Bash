#!/usr/bin/env bash
# ============================================================================
#  Curso de Bash · Módulo 03 · Exemplo 03 — printf vs echo
#  Prof. Daniel Santos · github.com/dsantos-docencia/bash · © 2026 (MIT)
# ----------------------------------------------------------------------------
#  OBJETIVO  Ver onde o printf ganha do echo: formato, alinhamento, repetição.
#  EXECUTE   bash 03-printf-vs-echo.sh
# ============================================================================
set -euo pipefail

echo "1) Tabela alinhada — impossível de fazer bem com echo:"
printf '   %-12s %8s\n' "PRODUTO" "PREÇO"
printf '   %-12s %8.2f\n' "Café"     4.5
printf '   %-12s %8.2f\n' "Pão"      0.75
printf '   %-12s %8.2f\n' "Chocolate" 12.9

echo
echo "2) printf REPETE o formato para cada grupo de argumentos:"
printf '   - %s\n' maçã banana abacaxi    # um formato, três linhas

echo
echo "3) Preenchimento e bases numéricas:"
printf '   zero à esquerda: %03d\n' 7      # 007
printf '   hexadecimal:     %x\n'   255    # ff
printf '   percentual:      %d%%\n' 80     # 80% (%% imprime um % literal)

echo
echo "4) Por que evitar 'echo -e' em scripts portáveis:"
echo "   Em alguns sistemas, echo -e imprime literalmente o -e."
echo "   Já o printf interpreta escapes de forma confiável:"
printf '   a\tb (tab de verdade entre a e b)\n'

echo
echo "Regra: para interação rápida, echo. Para saída séria/formatada, printf."
