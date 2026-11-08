#!/usr/bin/env bash
# ============================================================================
#  Curso de Bash · Módulo 04 · Exemplo 01 — if e testes
#  Prof. Daniel Santos · github.com/dsantos-docencia/bash · © 2026 (PolyForm-NC · não comercial)
# ----------------------------------------------------------------------------
#  OBJETIVO  Ver que o if testa CÓDIGO DE SAÍDA, e praticar testes comuns.
#  EXECUTE   bash 01-if-e-testes.sh
# ============================================================================
set -uo pipefail
LAB="$(mktemp -d)"; trap 'rm -rf -- "$LAB"' EXIT
cd "$LAB" || exit 1

echo "1) O if testa o CÓDIGO DE SAÍDA de um comando:"
if true;  then echo "   'true'  saiu 0 → bloco then";  fi
if false; then :; else echo "   'false' saiu 1 → bloco else"; fi
grep -q raiz <<< "tem raiz aqui" && echo "   grep -q achou → sucesso (0)"

echo
echo "2) Testes de ARQUIVO:"
echo "conteudo" > existe.txt
[[ -f existe.txt ]]   && echo "   -f existe.txt  → é arquivo"
[[ -s existe.txt ]]   && echo "   -s existe.txt  → não está vazio"
[[ -d existe.txt ]]   || echo "   -d existe.txt  → NÃO é diretório (correto)"

echo
echo "3) Testes de STRING:"
nome="Daniel"; vazio=""
[[ -n "$nome" ]]  && echo "   -n \"\$nome\"  → tem conteúdo"
[[ -z "$vazio" ]] && echo "   -z \"\$vazio\" → está vazia"
[[ "$nome" == Dan* ]] && echo "   == com glob: \$nome começa com 'Dan'"

echo
echo "4) Testes NUMÉRICOS — use (( )) para números:"
idade=20
if (( idade >= 18 )); then echo "   (( idade >= 18 )) → maior de idade"; fi

echo
echo "5) Armadilha clássica: < no [[ ]] é ordem ALFABÉTICA, não numérica!"
# shellcheck disable=SC2071,SC2050  # demonstracao PROPOSITAL do erro de comparar numeros com <
if [[ "9" < "100" ]]; then echo '   [[ 9 < 100 ]] → VERDADE? NÃO esperado...'; else echo '   [[ "9" < "100" ]] → FALSO! ("9" vem depois de "1" no dicionário)'; fi
if (( 9 < 100 )); then echo "   (( 9 < 100 ))    → VERDADE (comparação numérica correta)"; fi

echo
echo "6) && e || encadeando comandos:"
mkdir -p novo && echo "   pasta criada com sucesso"
cd inexistente 2>/dev/null || echo "   cd falhou → tratei com ||"
