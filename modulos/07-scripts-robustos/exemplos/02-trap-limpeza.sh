#!/usr/bin/env bash
# ============================================================================
#  Curso de Bash · Módulo 07 · Exemplo 02 — trap para limpeza garantida
#  Prof. Daniel Santos · github.com/dsantos-docencia/bash · © 2026 (MIT)
# ----------------------------------------------------------------------------
#  OBJETIVO  Ver que 'trap ... EXIT' limpa recursos mesmo quando o script
#            falha no meio — a diferença entre lixo acumulado e sistema limpo.
#  EXECUTE   bash 02-trap-limpeza.sh
# ============================================================================
set -uo pipefail

echo "1) SEM trap: se o script falha no meio, o temporário fica para trás."
sem_trap="$(mktemp -d)"
bash -c '
    tmp="'"$sem_trap"'"
    echo "   criei $tmp e vou falhar antes de apagar..."
    false || exit 1
    rm -rf "$tmp"          # esta linha NUNCA roda
' || true
if [[ -d "$sem_trap" ]]; then
    echo "   → o diretório $sem_trap SOBROU (lixo!)."
    rm -rf "$sem_trap"     # limpamos nós, para a demo não deixar sujeira
fi

echo
echo "2) COM trap EXIT: a limpeza acontece mesmo com falha."
marcador="$(mktemp -d)/com_trap_dir"
bash -c '
    tmp="'"$marcador"'"
    mkdir -p "$tmp"
    trap "rm -rf \"$tmp\"; echo \"   [trap] limpei $tmp\"" EXIT
    echo "   criei $tmp e vou falhar de novo..."
    false || exit 1
    echo "   (trabalho que não terminou)"
' || true
if [[ -d "$marcador" ]]; then
    echo "   → ainda existe? (não deveria)"
else
    echo "   → o diretório foi removido pelo trap, apesar da falha. ✔"
fi

echo
echo "Padrão profissional: registre o trap LOGO após criar o recurso:"
echo '   tmp="$(mktemp -d)"'
echo '   trap '"'"'rm -rf "$tmp"'"'"' EXIT'
