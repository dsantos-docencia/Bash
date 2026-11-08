#!/usr/bin/env bash
# ============================================================================
#  Curso de Bash · Módulo 03 · Exemplo 02 — Aspas duplas, simples e nenhuma
#  Prof. Daniel Santos · github.com/dsantos-docencia/bash · © 2026 (MIT)
# ----------------------------------------------------------------------------
#  OBJETIVO  Ver, de forma concreta, por que "sempre cite suas variáveis".
#  EXECUTE   bash 02-aspas.sh
# ============================================================================
set -uo pipefail
LAB="$(mktemp -d)"; trap 'rm -rf -- "$LAB"' EXIT
cd "$LAB"

nome="Ana Paula"
hoje="$(date +%Y)"

echo "1) Expansão:"
echo "   \"\$nome\"  →  \"$nome\"      (duplas: expande)"
echo '   '\''$nome'\''  →  '"'"'$nome'"'"'      (simples: literal)'
printf '   $(...) dentro de duplas → estamos em %s\n' "$hoje"

echo
echo "2) O perigo real — criar pasta com nome que tem espaço:"
mkdir "$nome"            # certo: UMA pasta
echo "   mkdir \"\$nome\"  criou:"
ls -1d ./*/ | sed 's/^/     /'

# Agora o ERRADO, mas sem quebrar o script: só mostramos o que ACONTECERIA.
echo
echo "   Sem aspas, 'mkdir \$nome' tentaria criar DUAS pastas:"
# 'set -f' desliga o globbing para esta demonstração; printf mostra a divisão.
set -f
printf '     tentaria: mkdir'; for p in $nome; do printf ' [%s]' "$p"; done; printf '\n'
set +f

echo
echo "3) Em números também importa:"
arquivos=$(ls -1 | wc -l)
printf '   há %s item(ns) na pasta de teste\n' "$arquivos"

echo
echo "Conclusão: cite SEMPRE — \"\$var\", \"\${arr[@]}\", \"\$(cmd)\"."
