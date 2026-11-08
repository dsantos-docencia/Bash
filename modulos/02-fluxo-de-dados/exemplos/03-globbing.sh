#!/usr/bin/env bash
# ============================================================================
#  Curso de Bash · Módulo 02 · Exemplo 03 — Globbing e expansão de chaves
#  Prof. Daniel Santos · github.com/dsantos-docencia/bash · © 2026 (PolyForm-NC · não comercial)
# ----------------------------------------------------------------------------
#  OBJETIVO  Ver o shell expandir *, ?, [] (que olham o disco) e {} (texto).
#  EXECUTE   bash 03-globbing.sh
# ============================================================================
set -euo pipefail
LAB="$(mktemp -d)"; trap 'rm -rf -- "$LAB"' EXIT
cd "$LAB" || exit 1

echo "1) {} é geração de TEXTO (não precisa existir nada):"
echo "   echo img.{png,jpg,gif}  →  $(echo img.{png,jpg,gif})"
echo "   echo {A..E}             →  $(echo {A..E})"
echo "   echo arq-{01..05}       →  $(echo arq-{01..05})"

echo
echo "   Por isso {} serve para CRIAR arquivos/pastas em lote:"
mkdir -p projeto/{src,test,docs}
touch relatorio-{01..03}.txt
echo "   criados:  $(echo projeto/*/ | xargs -n1 basename | tr '\n' ' ')e relatorio-0{1,2,3}.txt"
ls -1 | sed 's/^/     /'

echo
echo "2) *, ?, [] olham o DISCO (só casam o que existe):"
echo "   *.txt       →  $(echo *.txt)"
echo "   relatorio-??.txt → $(echo relatorio-??.txt)"
echo "   relatorio-0[13].txt → $(echo relatorio-0[13].txt)   (só 01 e 03)"

echo
echo "3) Glob que não casa nada fica LITERAL (armadilha!):"
echo "   *.xyz (nenhum existe) → $(echo *.xyz)"
echo "   → por isso scripts usam 'shopt -s nullglob' (Módulo 05)."

echo
echo "Lembre: no shell * = 'qualquer coisa'. Em regex, * = 'repetição'."
echo "São linguagens diferentes (regex vem no Módulo 05)."
