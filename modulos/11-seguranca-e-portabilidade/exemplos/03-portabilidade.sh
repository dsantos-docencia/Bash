#!/usr/bin/env bash
# ============================================================================
#  Curso de Bash · Módulo 11 · Exemplo 03 — Portabilidade Bash vs POSIX sh
#  Prof. Daniel Santos · github.com/dsantos-docencia/bash · © 2026 (PolyForm-NC · não comercial)
# ----------------------------------------------------------------------------
#  OBJETIVO  Resolver o MESMO problema em Bash (com recursos ricos) e em
#            POSIX sh (portável), mostrando o que muda.
#  EXECUTE   bash 03-portabilidade.sh
# ============================================================================
set -uo pipefail
LAB="$(mktemp -d)"; trap 'rm -rf -- "$LAB"' EXIT

echo "Problema: dizer se uma palavra está numa lista."
echo

echo "== Versão BASH (usa array e [[ ]]) =="
cat > "$LAB/bash_ver.sh" <<'FIM'
#!/usr/bin/env bash
frutas=(maçã banana uva)          # array (não existe em POSIX sh)
procurar="$1"
for f in "${frutas[@]}"; do
    [[ "$f" == "$procurar" ]] && { echo "achei: $procurar"; exit 0; }
done
echo "não achei: $procurar"
FIM
echo "   bash_ver.sh banana → $(bash "$LAB/bash_ver.sh" banana)"

echo
echo "== Versão POSIX sh (sem array, sem [[ ]]) =="
cat > "$LAB/posix_ver.sh" <<'FIM'
#!/bin/sh
# Portável: lista nos parâmetros posicionais, [ ] citado, 'case' para comparar
procurar="$1"
set -- maçã banana uva            # a "lista" vira $@
for f in "$@"; do
    if [ "$f" = "$procurar" ]; then
        echo "achei: $procurar"
        exit 0
    fi
done
echo "não achei: $procurar"
FIM
echo "   posix_ver.sh uva → $(sh "$LAB/posix_ver.sh" uva)"

echo
echo "Diferenças que quebram portabilidade (evite em #!/bin/sh):"
cat <<'TBL' | sed 's/^/   /'
Recurso Bash          Alternativa POSIX
--------------------  -----------------------------------
arr=(a b c)           set -- a b c   (ou lista separada por espaço)
[[ x == y ]]          [ "$x" = "$y" ]   (sempre com aspas!)
${var^^}              tr '[:lower:]' '[:upper:]'
<<< "texto"           here-doc (<<EOF ... EOF) ou printf |
local v               (não existe; cuidado com variáveis globais)
source arq            . arq
TBL

echo
echo "Dica: valide o shell alvo com 'shellcheck --shell=sh script.sh'."
