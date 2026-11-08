#!/usr/bin/env bash
# ============================================================================
#  Curso de Bash · Módulo 08 · Exemplo 01 — getopts passo a passo
#  Prof. Daniel Santos · github.com/dsantos-docencia/bash · © 2026 (PolyForm-NC · não comercial)
# ----------------------------------------------------------------------------
#  OBJETIVO  Entender getopts processando um conjunto fixo de opções e vendo
#            o papel de OPTARG e OPTIND.
#  EXECUTE   bash 01-getopts.sh
# ============================================================================
set -uo pipefail

# Função que "simula" um script com opções, para demonstrarmos várias chamadas.
processar() {
    local verboso=0 saida="(padrão)" opt OPTIND=1
    # "vo:h" → -v e -h são flags; -o EXIGE argumento (por causa do :).
    while getopts "vo:h" opt; do
        case "$opt" in
            v) verboso=1 ;;
            o) saida="$OPTARG" ;;
            h) echo "   uso: comando [-v] [-o arquivo] args..."; return 0 ;;
            *) echo "   opção inválida"; return 2 ;;
        esac
    done
    shift $(( OPTIND - 1 ))     # remove as opções já consumidas
    echo "   → verboso=$verboso | saida=$saida | argumentos restantes: [$*]"
}

echo "Chamada: -v -o log.txt entrada1 entrada2"
processar -v -o log.txt entrada1 entrada2

echo
echo "Chamada: só argumentos, sem opções"
processar arquivoA arquivoB

echo
echo "Chamada: -h (ajuda)"
processar -h

echo
echo "Como funciona:"
echo "  • getopts lê uma opção por vez e põe a letra em \$opt"
echo "  • para -o, o valor fica em \$OPTARG"
echo "  • OPTIND aponta o próximo argumento; 'shift \$((OPTIND-1))'"
echo "    descarta as opções, deixando só os argumentos de verdade em \$@"
