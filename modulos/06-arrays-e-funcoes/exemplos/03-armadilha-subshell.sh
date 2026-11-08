#!/usr/bin/env bash
# ============================================================================
#  Curso de Bash · Módulo 06 · Exemplo 03 — A armadilha do subshell
#  Prof. Daniel Santos · github.com/dsantos-docencia/bash · © 2026 (MIT)
# ----------------------------------------------------------------------------
#  OBJETIVO  Ver, ao vivo, por que 'cmd | while read' perde as alterações,
#            e as duas formas corretas.
#  EXECUTE   bash 03-armadilha-subshell.sh
# ============================================================================
set -uo pipefail

dados=$'linha 1\nlinha 2\nlinha 3'

echo "❌ ERRADO: pipe cria um subshell; a variável alterada some com ele:"
contador=0
echo "$dados" | while read -r _; do
    (( contador++ ))        # isto roda no subshell do lado direito do |
done
echo "   depois do pipe, contador = $contador   (esperávamos 3!)"

echo
echo "✔ CERTO 1: redirecionar com process substitution < <( ... ):"
contador=0
while read -r _; do
    (( contador++ ))
done < <(echo "$dados")
echo "   contador = $contador"

echo
echo "✔ CERTO 2: here-string <<< (quando os dados já estão numa variável):"
contador=0
while read -r _; do
    (( contador++ ))
done <<< "$dados"
echo "   contador = $contador"

echo
echo "Regra: se precisa ALTERAR variáveis dentro de um while read,"
echo "não alimente o while por pipe — use < arquivo, < <(cmd) ou <<< \"\$var\"."
