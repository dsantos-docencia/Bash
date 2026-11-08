#!/usr/bin/env bash
# ============================================================================
#  Curso de Bash · Projeto 2 · monitor.sh — Monitor de recursos do sistema
#  Prof. Daniel Santos · github.com/dsantos-docencia/bash · © 2026 (PolyForm-NC · não comercial)
# ----------------------------------------------------------------------------
#  Coleta uso de disco, memória e carga, compara com limites e alerta.
#  Sai com código 1 se QUALQUER limite for ultrapassado (útil para cron/CI).
#
#  Uso:  monitor.sh [-d LIM_DISCO] [-m LIM_MEM] [-p PONTO_MONTAGEM]
#        -d LIM_DISCO   % máximo de uso de disco (padrão 90)
#        -m LIM_MEM     % máximo de uso de memória (padrão 90)
#        -p PONTO       ponto de montagem a checar (padrão /)
#        -h             ajuda
#
#  Conceitos: ler /proc e df, awk para extrair números, limites, alertas.
# ============================================================================
set -euo pipefail

lim_disco=90
lim_mem=90
ponto="/"

uso() { sed -n '6,15p' "${BASH_SOURCE[0]}" | sed 's/^#  \{0,1\}//'; }

while getopts "d:m:p:h" opt; do
    case "$opt" in
        d) lim_disco="$OPTARG" ;;
        m) lim_mem="$OPTARG" ;;
        p) ponto="$OPTARG" ;;
        h) uso; exit 0 ;;
        *) uso >&2; exit 2 ;;
    esac
done

alertas=0
alerta() { echo "ALERTA: $*"; alertas=$(( alertas + 1 )); }
ok()     { echo "ok: $*"; }

# --- Disco: df do ponto de montagem, pega a coluna de uso (%) ---------------
# tail -1 pula o cabeçalho; tr remove o '%'; é a 5ª coluna do df.
uso_disco=$(df "$ponto" | awk 'NR==2 {gsub(/%/,"",$5); print $5}')
if (( uso_disco > lim_disco )); then
    alerta "disco em ${uso_disco}% (limite ${lim_disco}%) em $ponto"
else
    ok "disco ${uso_disco}% em $ponto"
fi

# --- Memória: lê /proc/meminfo (universal no Linux) -------------------------
if [[ -r /proc/meminfo ]]; then
    # awk calcula (1 - disponível/total) * 100 diretamente do /proc/meminfo.
    uso_mem=$(awk '
        /^MemTotal:/     {total=$2}
        /^MemAvailable:/ {disp=$2}
        END { if (total>0) printf "%d", (1 - disp/total)*100; else print 0 }
    ' /proc/meminfo)
    if (( uso_mem > lim_mem )); then
        alerta "memória em ${uso_mem}% (limite ${lim_mem}%)"
    else
        ok "memória ${uso_mem}%"
    fi
else
    echo "aviso: /proc/meminfo indisponível (não é Linux?)"
fi

# --- Carga: 1º número de /proc/loadavg (média de 1 min) ---------------------
if [[ -r /proc/loadavg ]]; then
    carga=$(cut -d' ' -f1 /proc/loadavg)
    ok "carga (1min) ${carga}"
fi

echo "---"
if (( alertas > 0 )); then
    echo "resultado: $alertas alerta(s)"
    exit 1          # status != 0 para o cron mandar e-mail / o CI falhar
fi
echo "resultado: tudo dentro dos limites"
