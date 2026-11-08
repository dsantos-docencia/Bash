#!/usr/bin/env bash
# ============================================================================
#  Curso de Bash · Módulo 07 · Exemplo 03 — Logging e depuração
#  Prof. Daniel Santos · github.com/dsantos-docencia/bash · © 2026 (MIT)
# ----------------------------------------------------------------------------
#  OBJETIVO  Uma função de log com timestamp (no stderr) e depuração que só
#            aparece quando DEBUG=1.
#  EXECUTE   bash 03-logging-e-debug.sh
#            DEBUG=1 bash 03-logging-e-debug.sh     (para ver as linhas DEBUG)
# ============================================================================
set -uo pipefail

# %(...)T formata data/hora direto no printf (sem chamar 'date'). -1 = agora.
log() {
    local nivel="$1"; shift
    printf '%(%Y-%m-%d %H:%M:%S)T [%-5s] %s\n' -1 "$nivel" "$*" >&2
}

# Só imprime se a variável de ambiente DEBUG for 1.
depurar() {
    [[ "${DEBUG:-0}" == 1 ]] && log DEBUG "$*"
    return 0
}

log INFO "iniciando processamento"
depurar "esta linha só aparece com DEBUG=1"

total=0
for item in alfa beta gama; do
    depurar "processando item=$item"
    (( ++total ))
done

log INFO "processei $total itens"
log WARN "exemplo de aviso"
log ERRO "exemplo de erro (ainda assim vai para o stderr, não o stdout)"

echo
echo "Observações:"
echo "  • Todos os logs foram para o STDERR (>&2). Assim o STDOUT fica livre"
echo "    para o resultado 'de verdade' do script, que pode ir para um pipe."
echo "  • Rode com 'DEBUG=1 bash $0' para ver as linhas DEBUG aparecerem."
echo "  • %(...)T formata a hora sem chamar o programa 'date' (mais rápido)."
