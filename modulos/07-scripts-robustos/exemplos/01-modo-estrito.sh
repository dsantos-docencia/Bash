#!/usr/bin/env bash
# ============================================================================
#  Curso de Bash · Módulo 07 · Exemplo 01 — O modo estrito
#  Prof. Daniel Santos · github.com/dsantos-docencia/bash · © 2026 (MIT)
# ----------------------------------------------------------------------------
#  OBJETIVO  Ver o efeito de set -e, set -u e pipefail — inclusive a armadilha
#            famosa do (( contador++ )).
#  EXECUTE   bash 01-modo-estrito.sh
#  NOTA      Rodamos cada demonstração num SUBSHELL (bash -c) para que uma
#            falha proposital não derrube o exemplo inteiro.
# ============================================================================
set -uo pipefail

demo() { echo; echo "── $1"; }

demo "set -u: usar variável indefinida ABORTA (ótimo contra rm -rf \$VAZIA/)"
if bash -c 'set -u; echo "valor: $NAO_DEFINIDA"' 2>/dev/null; then
    echo "   (rodou — não deveria)"
else
    echo "   ✔ abortou ao referenciar NAO_DEFINIDA (sem set -u, imprimiria vazio)"
fi

demo "set -e: um comando que falha interrompe o script"
bash -c '
    set -e
    echo "   passo 1 ok"
    false                 # retorna 1
    echo "   passo 2 (NÃO deve aparecer)"
' || echo "   ✔ parou no 'false', nunca chegou ao passo 2"

demo "pipefail: o pipe falha se QUALQUER parte falhar"
if bash -c 'set -o pipefail; false | cat' ; then
    echo "   (sem efeito)"
else
    echo "   ✔ 'false | cat' foi considerado falha (sem pipefail, seria sucesso)"
fi
echo -n "   sem pipefail, 'false | cat' dá status: "
bash -c 'false | cat'; echo "$?  (o status é o do 'cat', mascarando o erro)"

demo "ARMADILHA: (( contador++ )) sob set -e pode ABORTAR o script"
bash -c '
    set -e
    contador=0
    (( contador++ ))      # retorna o valor ANTES (0) → status 1 → aborta!
    echo "   cheguei aqui? (NÃO, com set -e)"
' 2>/dev/null || echo "   ✔ (( contador++ )) com valor 0 retornou status 1 e abortou"
echo "   Solução: use (( ++contador )) (pré-incremento) ou 'contador=\$((contador+1))'"
