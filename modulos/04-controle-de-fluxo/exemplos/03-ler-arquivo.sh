#!/usr/bin/env bash
# ============================================================================
#  Curso de Bash · Módulo 04 · Exemplo 03 — Lendo arquivo linha a linha
#  Prof. Daniel Santos · github.com/dsantos-docencia/bash · © 2026 (PolyForm-NC · não comercial)
# ----------------------------------------------------------------------------
#  OBJETIVO  Mostrar por que 'while IFS= read -r' é certo e 'for ... $(cat)'
#            é a armadilha nº 1 do Bash.
#  EXECUTE   bash 03-ler-arquivo.sh
# ============================================================================
set -uo pipefail
LAB="$(mktemp -d)"; trap 'rm -rf -- "$LAB"' EXIT
cd "$LAB" || exit 1

# Arquivo com casos que QUEBRAM o jeito errado: espaços e um asterisco.
cat > dados.txt <<'EOF'
primeira linha
linha   com   espaços   múltiplos
item com * asterisco
EOF

echo "Arquivo de teste:"
sed 's/^/   | /' dados.txt

echo
echo "❌ JEITO ERRADO: for linha in \$(cat dados.txt)"
echo "   (divide em PALAVRAS, não em linhas, e expande o *):"
n=0
# set -f desliga o glob só para o * não virar lista de arquivos nesta demo.
set -f
# shellcheck disable=SC2013  # anti-exemplo PROPOSITAL (jeito errado de ler arquivo)
for palavra in $(cat dados.txt); do
    (( ++n )); printf '   pedaço %d: [%s]\n' "$n" "$palavra"
done
set +f
echo "   → virou $n pedaços, não 3 linhas. Bagunça."

echo
echo "✔ JEITO CERTO: while IFS= read -r linha"
echo "   (uma linha por vez, espaços e * preservados):"
n=0
while IFS= read -r linha; do
    (( ++n )); printf '   linha %d: [%s]\n' "$n" "$linha"
done < dados.txt
echo "   → exatamente $n linhas, intactas."
