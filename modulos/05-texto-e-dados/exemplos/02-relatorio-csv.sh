#!/usr/bin/env bash
# ============================================================================
#  Curso de Bash · Módulo 05 · Exemplo 02 — Relatório a partir de um CSV
#  Prof. Daniel Santos · github.com/dsantos-docencia/bash · © 2026 (MIT)
# ----------------------------------------------------------------------------
#  OBJETIVO  Usar awk para ler um CSV e gerar um relatório com totais —
#            a tarefa que o Bash faz melhor que planilha para automação.
#  EXECUTE   bash 02-relatorio-csv.sh
# ============================================================================
set -uo pipefail
LAB="$(mktemp -d)"; trap 'rm -rf -- "$LAB"' EXIT
cd "$LAB" || exit 1

cat > vendas.csv <<'EOF'
data,vendedor,produto,valor
2026-11-01,Ana,Notebook,3500
2026-11-01,Bia,Mouse,80
2026-11-02,Ana,Teclado,250
2026-11-02,Caio,Notebook,3500
2026-11-03,Bia,Monitor,1200
2026-11-03,Ana,Mouse,80
EOF

echo "CSV de vendas:"; column -t -s, vendas.csv | sed 's/^/   /'

echo
echo "1) Total por vendedor (awk somando numa array associativa):"
awk -F, 'NR>1 {total[$2]+=$4}
         END  {for (v in total) printf "   %-6s R$ %8.2f\n", v, total[v]}' vendas.csv | sort

echo
echo "2) Faturamento total e ticket médio:"
awk -F, 'NR>1 {soma+=$4; n++}
         END  {printf "   total   = R$ %.2f\n   vendas  = %d\n   médio   = R$ %.2f\n", soma, n, soma/n}' vendas.csv

echo
echo "3) Produto mais vendido (contagem):"
awk -F, 'NR>1 {c[$3]++} END{for (p in c) print c[p], p}' vendas.csv | sort -rn | head -1 | awk '{printf "   %s (%d vendas)\n", $2, $1}'

echo
echo "Tudo isso sem abrir planilha — e automatizável num cron."
