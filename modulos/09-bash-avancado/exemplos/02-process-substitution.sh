#!/usr/bin/env bash
# ============================================================================
#  Curso de Bash · Módulo 09 · Exemplo 02 — Process substitution
#  Prof. Daniel Santos · github.com/dsantos-docencia/bash · © 2026 (MIT)
# ----------------------------------------------------------------------------
#  OBJETIVO  Usar <(...) para comparar saídas e para alimentar while read
#            sem o subshell do pipe.
#  EXECUTE   bash 02-process-substitution.sh
# ============================================================================
set -uo pipefail

echo "1) diff <(cmd1) <(cmd2): comparar saídas SEM arquivos temporários"
echo "   (comparando duas listas de números)"
diff <(seq 1 5) <(seq 3 7) && echo "   (iguais)" || echo "   ↑ as diferenças entre as listas"

echo
echo "2) <(...) é visto como um 'arquivo' (um caminho /dev/fd/N):"
echo "   caminho gerado: $(echo <(echo oi))"

echo
echo "3) while read < <(...): soma linhas SEM perder a variável (vs. pipe)"
total=0
while read -r n; do
    total=$(( total + n ))
done < <(seq 1 10)                 # process substitution: roda no shell atual
echo "   soma de 1..10 = $total   (com pipe 'seq | while', total ficaria 0)"

echo
echo "4) >(...): mandar a saída PARA um comando"
# Cria um 'consumidor' que numera as linhas e grava num arquivo.
tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT
echo -e "alfa\nbeta\ngama" > >(nl > "$tmp")
sleep 0.2                          # dá tempo do processo em >( ) terminar
echo "   saída numerada pelo consumidor >(nl):"
sed 's/^/      /' "$tmp"
