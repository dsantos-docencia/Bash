#!/usr/bin/env bash
# ============================================================================
#  Curso de Bash · Projeto 3 · renomear.sh — Renomeação em lote
#  Prof. Daniel Santos · github.com/dsantos-docencia/bash · © 2026 (PolyForm-NC · não comercial)
# ----------------------------------------------------------------------------
#  Renomeia em massa os arquivos de um diretório aplicando transformações:
#  minúsculas, troca de espaços por "_", e prefixo opcional. Mostra um
#  relatório e é SEGURO por padrão (modo simulação; só age com -x).
#
#  Uso:  renomear.sh [-x] [-p PREFIXO] <diretório>
#        (sem -x)   SIMULA — mostra o que faria, sem renomear nada
#        -x         EXECUTA de verdade
#        -p PREFIXO acrescenta PREFIXO ao início de cada nome
#        -h         ajuda
#
#  Conceitos: glob, expansão de parâmetros, laço, idempotência, dry-run.
# ============================================================================
set -euo pipefail

executar=0
prefixo=""

uso() { sed -n '6,15p' "${BASH_SOURCE[0]}" | sed 's/^#  \{0,1\}//'; }

while getopts "xp:h" opt; do
    case "$opt" in
        x) executar=1 ;;
        p) prefixo="$OPTARG" ;;
        h) uso; exit 0 ;;
        *) uso >&2; exit 2 ;;
    esac
done
shift $(( OPTIND - 1 ))

(( $# == 1 )) || { uso >&2; exit 2; }
dir="$1"
[[ -d "$dir" ]] || { echo "erro: diretório não existe: $dir" >&2; exit 1; }

(( executar )) || echo "== MODO SIMULAÇÃO (use -x para aplicar) =="

renomeados=0
inalterados=0

shopt -s nullglob     # se a pasta estiver vazia, o glob não vira literal
for caminho in "$dir"/*; do
    [[ -f "$caminho" ]] || continue          # só arquivos comuns
    nome="${caminho##*/}"                     # basename por expansão
    novo="$nome"
    novo="${novo,,}"                          # minúsculas
    novo="${novo// /_}"                       # espaços → _
    novo="${prefixo}${novo}"                  # prefixo opcional

    if [[ "$novo" == "$nome" ]]; then
        (( ++inalterados ))
        continue
    fi

    destino="$dir/$novo"
    if [[ -e "$destino" ]]; then
        echo "  [pulado] '$nome' → '$novo' (destino já existe)"
        continue
    fi

    if (( executar )); then
        mv -- "$caminho" "$destino"
        echo "  [ok] '$nome' → '$novo'"
    else
        echo "  [simul] '$nome' → '$novo'"
    fi
    (( ++renomeados ))
done

echo "---"
echo "renomeados: $renomeados | inalterados: $inalterados"
