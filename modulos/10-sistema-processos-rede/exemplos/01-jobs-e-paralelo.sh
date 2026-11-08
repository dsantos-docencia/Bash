#!/usr/bin/env bash
# ============================================================================
#  Curso de Bash · Módulo 10 · Exemplo 01 — Jobs e paralelismo
#  Prof. Daniel Santos · github.com/dsantos-docencia/bash · © 2026 (PolyForm-NC · não comercial)
# ----------------------------------------------------------------------------
#  OBJETIVO  Ver background (&) + wait acelerando tarefas independentes.
#  EXECUTE   bash 01-jobs-e-paralelo.sh
# ============================================================================
set -uo pipefail

# Simula uma "tarefa que demora" (ex.: consultar um servidor).
tarefa() {
    local nome="$1" segundos="$2"
    sleep "$segundos"
    echo "   [$nome] concluída (levou ${segundos}s)"
}

echo "1) SEQUENCIAL: uma tarefa após a outra"
ini=$SECONDS
tarefa A 1
tarefa B 1
tarefa C 1
echo "   total sequencial: $(( SECONDS - ini ))s"

echo
echo "2) PARALELO: todas ao mesmo tempo com & e depois wait"
ini=$SECONDS
tarefa A 1 &          # & joga para background
tarefa B 1 &
tarefa C 1 &
echo "   (3 tarefas disparadas; PIDs em background: $(jobs -p | tr '\n' ' '))"
wait                  # espera todas terminarem
echo "   total paralelo: $(( SECONDS - ini ))s  ← ~1/3 do tempo"

echo
echo "3) Capturar o resultado de um job específico pelo PID:"
tarefa D 1 &
pid=$!
echo "   esperando só o PID $pid..."
wait "$pid"
echo "   job D terminou com status $?"
