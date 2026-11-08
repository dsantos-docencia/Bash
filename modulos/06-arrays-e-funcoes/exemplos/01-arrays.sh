#!/usr/bin/env bash
# ============================================================================
#  Curso de Bash · Módulo 06 · Exemplo 01 — Arrays
#  Prof. Daniel Santos · github.com/dsantos-docencia/bash · © 2026 (MIT)
# ----------------------------------------------------------------------------
#  OBJETIVO  Arrays indexados e associativos: criar, iterar, contar, fatiar.
#  EXECUTE   bash 01-arrays.sh
# ============================================================================
set -uo pipefail

echo "== Arrays indexados =="
frutas=(maçã banana "fruta do conde")   # o 3º tem espaço: por isso as aspas
frutas+=(uva)                           # acrescenta

echo "   todos:      ${frutas[*]}"
echo "   quantidade: ${#frutas[@]}"
echo "   índices:    ${!frutas[@]}"
echo "   elemento 2: ${frutas[2]}"
echo "   fatia 1..2: ${frutas[*]:1:2}"

echo "   iterando (cada elemento preservado):"
for f in "${frutas[@]}"; do
    echo "      - $f"
done

echo
echo "== Array associativo (dicionário) =="
declare -A estoque                      # OBRIGATÓRIO para associativo
estoque[teclado]=12
estoque[mouse]=30
estoque["monitor 24pol"]=5

echo "   chaves:  ${!estoque[*]}"
echo "   valores: ${estoque[*]}"
echo "   mouse:   ${estoque[mouse]}"

echo "   inventário:"
for item in "${!estoque[@]}"; do
    printf '      %-15s %3d un\n' "$item" "${estoque[$item]}"
done

echo
echo "== Caso de uso: contar palavras (histograma) =="
declare -A contagem
for palavra in sol mar sol praia mar sol; do
    (( contagem[$palavra]++ ))          # chave nova começa em 0 automaticamente
done
for p in "${!contagem[@]}"; do
    printf '      %-6s %d\n' "$p" "${contagem[$p]}"
done | sort
