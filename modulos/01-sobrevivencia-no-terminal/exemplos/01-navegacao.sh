#!/usr/bin/env bash
# ============================================================================
#  Curso de Bash · Módulo 01 · Exemplo 01 — Navegação
#  Prof. Daniel Santos · github.com/dsantos-docencia/bash · © 2026 (MIT)
# ----------------------------------------------------------------------------
#  OBJETIVO  Ver na prática caminhos absolutos/relativos e os atalhos ~ . .. -
#  EXECUTE   bash 01-navegacao.sh
#  SEGURO    Tudo acontece numa pasta temporária, apagada no final.
# ============================================================================
set -euo pipefail

# Monta um lab descartável e garante a limpeza, aconteça o que acontecer.
LAB="$(mktemp -d)"
trap 'rm -rf -- "$LAB"' EXIT

# -p cria a cadeia inteira de uma vez, sem reclamar se já existir.
mkdir -p "$LAB/projetos/curso/modulos" "$LAB/documentos"

echo "1) pwd mostra onde estamos:"
cd "$LAB/projetos/curso"
echo "   $(pwd)"

echo
echo "2) caminho RELATIVO (parte daqui):"
cd modulos
echo "   entrei em 'modulos' → $(pwd)"

echo
echo "3) '..' sobe um nível:"
cd ..
echo "   $(pwd)"

echo
echo "4) '-' volta ao diretório ANTERIOR:"
cd -  >/dev/null         # o cd - imprime o destino; silenciamos e mostramos nós
echo "   voltei para → $(pwd)"

echo
echo "5) caminho ABSOLUTO (vale de qualquer lugar):"
cd "$LAB/documentos"
echo "   $(pwd)"

echo
echo "6) '.' é 'aqui mesmo'. É por isso que rodamos scripts com ./script:"
echo "   ./relatorio.sh  significa  $(pwd)/relatorio.sh"

echo
echo "Resumo dos atalhos:  ~ = sua casa   . = aqui   .. = pai   - = anterior"
