#!/usr/bin/env bash
# ============================================================================
#  Curso de Bash · Projeto 4 · tarefas.sh — CLI profissional de tarefas
#  Prof. Daniel Santos · github.com/dsantos-docencia/bash · © 2026 (MIT)
# ----------------------------------------------------------------------------
#  Um gerenciador de tarefas de linha de comando, com SUBCOMANDOS (como git),
#  cores, --help e persistência num arquivo de texto.
#
#  Uso:  tarefas.sh [-f ARQUIVO] <subcomando> [args]
#    add <texto>     adiciona uma tarefa
#    list            lista as tarefas (numeradas)
#    done <n>        marca a tarefa n como concluída
#    rm <n>          remove a tarefa n
#    help            esta ajuda
#
#  Conceitos: subcomandos, getopts, cores ANSI, arquivo de estado, funções.
# ============================================================================
set -euo pipefail

arquivo="${TAREFAS_ARQUIVO:-$HOME/.tarefas.txt}"

# Cores só quando a saída é um terminal (em pipe/CI, texto puro).
if [[ -t 1 ]]; then
    VERDE=$'\e[32m'; AMARELO=$'\e[33m'; CINZA=$'\e[90m'; NEGRITO=$'\e[1m'; RESET=$'\e[0m'
else
    VERDE=''; AMARELO=''; CINZA=''; NEGRITO=''; RESET=''
fi

erro() { echo "tarefas: $*" >&2; exit 1; }

ajuda() { sed -n '6,17p' "${BASH_SOURCE[0]}" | sed 's/^#  \{0,1\}//'; }

# Cada linha do arquivo é: "ESTADO|texto"  (ESTADO = aberta|feita)
garantir_arquivo() { [[ -f "$arquivo" ]] || : > "$arquivo"; }

cmd_add() {
    (( $# >= 1 )) || erro "uso: add <texto>"
    garantir_arquivo
    printf 'aberta|%s\n' "$*" >> "$arquivo"
    echo "${VERDE}+ adicionada:${RESET} $*"
}

cmd_list() {
    garantir_arquivo
    local n=0 estado texto abertas=0
    if [[ ! -s "$arquivo" ]]; then
        echo "${CINZA}(nenhuma tarefa)${RESET}"; return 0
    fi
    echo "${NEGRITO}Suas tarefas:${RESET}"
    while IFS='|' read -r estado texto; do
        n=$(( n + 1 ))
        if [[ "$estado" == feita ]]; then
            printf '  %s%2d. [x] %s%s\n' "$CINZA" "$n" "$texto" "$RESET"
        else
            printf '  %2d. [ ] %s\n' "$n" "$texto"
            abertas=$(( abertas + 1 ))
        fi
    done < "$arquivo"
    printf '%s%d aberta(s) de %d%s\n' "$AMARELO" "$abertas" "$n" "$RESET"
}

# Edita a linha N trocando seu estado ou removendo-a. $1=ação(done|rm) $2=n
cmd_editar() {
    local acao="$1" alvo="${2:-}"
    [[ "$alvo" =~ ^[0-9]+$ ]] || erro "informe um número de tarefa"
    garantir_arquivo
    local total; total=$(wc -l < "$arquivo")
    (( alvo >= 1 && alvo <= total )) || erro "tarefa $alvo não existe (há $total)"

    local tmp; tmp="$(mktemp)"
    trap 'rm -f "$tmp"' RETURN
    local n=0 estado texto
    while IFS='|' read -r estado texto; do
        n=$(( n + 1 ))
        if (( n == alvo )); then
            case "$acao" in
                done) printf 'feita|%s\n' "$texto" >> "$tmp" ;;
                rm)   : ;;   # pular = remover
            esac
        else
            printf '%s|%s\n' "$estado" "$texto" >> "$tmp"
        fi
    done < "$arquivo"
    mv -- "$tmp" "$arquivo"
    case "$acao" in
        done) echo "${VERDE}✓ tarefa $alvo concluída${RESET}" ;;
        rm)   echo "${AMARELO}− tarefa $alvo removida${RESET}" ;;
    esac
}

# --- Opções globais antes do subcomando -------------------------------------
while getopts "f:h" opt; do
    case "$opt" in
        f) arquivo="$OPTARG" ;;
        h) ajuda; exit 0 ;;
        *) ajuda >&2; exit 2 ;;
    esac
done
shift $(( OPTIND - 1 ))

sub="${1:-help}"; shift || true

case "$sub" in
    add)  cmd_add "$@" ;;
    list) cmd_list ;;
    "done") cmd_editar "done" "${1:-}" ;;
    rm)   cmd_editar rm   "${1:-}" ;;
    help|-h|--help) ajuda ;;
    *)    erro "subcomando desconhecido: $sub (tente 'help')" ;;
esac
