#!/usr/bin/env bash
# ============================================================================
#  Curso de Bash · Projeto 1 · backup.sh — Backup inteligente com rotação
#  Prof. Daniel Santos · github.com/dsantos-docencia/bash · © 2026 (PolyForm-NC · não comercial)
# ----------------------------------------------------------------------------
#  Compacta um diretório em .tar.gz com data no nome, mantém apenas as N
#  cópias mais recentes (rotação) e registra tudo num log.
#
#  Uso:  backup.sh [-o DESTINO] [-k MANTER] [-q] <diretório>
#        -o DESTINO   onde salvar os backups (padrão: ./backups)
#        -k MANTER    quantas cópias manter (padrão: 5)
#        -q           silencioso (só erros)
#        -h           ajuda
#
#  Conceitos: tar/gzip, data no nome, rotação, logging, trap, set -euo pipefail.
# ============================================================================
set -euo pipefail

destino="./backups"
manter=5
quieto=0

erro() { echo "backup: erro: $*" >&2; exit 1; }
log()  { (( quieto )) || printf '%(%Y-%m-%d %H:%M:%S)T [backup] %s\n' -1 "$*"; }

uso() { sed -n '6,16p' "${BASH_SOURCE[0]}" | sed 's/^#  \{0,1\}//'; }

while getopts "o:k:qh" opt; do
    case "$opt" in
        o) destino="$OPTARG" ;;
        k) manter="$OPTARG" ;;
        q) quieto=1 ;;
        h) uso; exit 0 ;;
        *) uso >&2; exit 2 ;;
    esac
done
shift $(( OPTIND - 1 ))

# --- Validação de entrada ---------------------------------------------------
(( $# == 1 )) || { uso >&2; exit 2; }
origem="$1"
[[ -d "$origem" ]] || erro "diretório de origem não existe: $origem"
[[ "$manter" =~ ^[0-9]+$ && "$manter" -ge 1 ]] || erro "-k deve ser inteiro >= 1"

mkdir -p "$destino" || erro "não consegui criar o destino: $destino"

# --- Criação do backup ------------------------------------------------------
# Nome com data e hora: backup_<basename>_AAAA-MM-DD_HHMMSS.tar.gz
carimbo="$(date +%Y-%m-%d_%H%M%S)"
base="$(basename -- "$origem")"
arquivo="$destino/backup_${base}_${carimbo}.tar.gz"

log "compactando '$origem' → '$arquivo'"
# -C entra no diretório pai para o tar não guardar o caminho absoluto inteiro.
if tar -czf "$arquivo" -C "$(dirname -- "$origem")" "$base" 2>/dev/null; then
    tamanho="$(du -h "$arquivo" | cut -f1)"
    log "backup criado ($tamanho)"
else
    rm -f "$arquivo"
    erro "falha ao compactar"
fi

# --- Rotação: manter só as N cópias mais recentes ---------------------------
# Lista os backups deste 'base', do mais novo para o mais velho, e apaga o excesso.
mapfile -t copias < <(find "$destino" -maxdepth 1 -name "backup_${base}_*.tar.gz" -printf '%T@ %p\n' \
                        | sort -rn | cut -d' ' -f2-)
total=${#copias[@]}
if (( total > manter )); then
    log "rotação: $total cópias, mantendo $manter"
    for (( i=manter; i<total; i++ )); do
        rm -f -- "${copias[i]}"
        log "removida cópia antiga: $(basename -- "${copias[i]}")"
    done
fi

log "concluído. Cópias atuais: $(( total > manter ? manter : total ))"
echo "$arquivo"      # imprime o caminho do backup no stdout (para uso em pipes)
