#!/usr/bin/env bash
# ============================================================================
#  Curso de Bash · Módulo 11 · Exemplo 01 — Armadilhas clássicas
#  Prof. Daniel Santos · github.com/dsantos-docencia/bash · © 2026 (PolyForm-NC · não comercial)
# ----------------------------------------------------------------------------
#  OBJETIVO  Ver o erro e a versão segura lado a lado — SEM destruir nada
#            (tudo acontece num laboratório temporário).
#  EXECUTE   bash 01-armadilhas.sh
# ============================================================================
set -uo pipefail
LAB="$(mktemp -d)"; trap 'rm -rf -- "$LAB"' EXIT
cd "$LAB" || exit 1

echo "1) Espaços em nomes de arquivo"
touch "meu arquivo.txt" "outro.txt"
echo "   ❌ 'for f in \$(ls *.txt)' quebraria 'meu arquivo.txt' em dois."
echo "   ✔ glob + aspas trata cada nome inteiro:"
for f in *.txt; do echo "      [$f]"; done

echo
echo "2) rm -rf com variável vazia (a mais perigosa)"
DIR=""          # imagine um bug que esvaziou a variável
echo "   Com 'rm -rf \"\$DIR/\"' e DIR vazia, viraria 'rm -rf /' 🔥"
echo "   ✔ proteção em camadas impede o desastre:"
alvo="${DIR:-}"
if [[ -z "$alvo" || ! -d "$alvo" ]]; then
    echo "      → abortei: DIR vazia ou inválida (nada foi apagado)"
else
    echo "      rm -rf -- \"$alvo\""
fi

echo
echo "3) cd que falha silenciosamente"
echo "   ❌ 'cd /nao/existe; rm -rf *' apagaria a pasta ERRADA."
if cd /nao/existe/mesmo 2>/dev/null; then
    echo "      (entrou?!)"
else
    echo "   ✔ 'cd ... || exit' parou antes de qualquer rm. Pasta atual intacta."
fi

echo
echo "4) O '--' protege contra nomes que começam com '-'"
touch -- "-rf"            # um arquivo chamado literalmente "-rf"
echo "   criei um arquivo chamado '-rf'. Sem '--', 'rm \"-rf\"' viraria opção."
rm -- "-rf" && echo "   ✔ 'rm -- \"-rf\"' removeu o arquivo (e não interpretou como flag)"

echo
echo "Todas essas armadilhas são detectadas automaticamente pelo ShellCheck."
