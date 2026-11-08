#!/usr/bin/env bash
# ============================================================================
#  Curso de Bash · Projeto 6 · deploy.sh — Deploy simples com rollback
#  Prof. Daniel Santos · github.com/dsantos-docencia/bash · © 2026 (MIT)
# ----------------------------------------------------------------------------
#  Publica uma nova versão (de um diretório de origem) num diretório "atual"
#  usando troca atômica por symlink + versões datadas, com ROLLBACK automático
#  se os testes pós-deploy falharem. Mantém só as N versões mais recentes.
#
#  Uso:  deploy.sh [-k MANTER] [-t CMD_TESTE] <origem> <área>
#        origem     diretório com a nova versão (o "build")
#        área       diretório-alvo (conterá releases/ e o symlink 'atual')
#        -t CMD     comando de smoke test; se falhar, faz rollback (padrão: true)
#        -k MANTER  versões a manter (padrão 3)
#        -h         ajuda
#
#  Conceitos: symlink atômico, trap para rollback, idempotência, etapas, rotação.
# ============================================================================
set -euo pipefail

manter=3
cmd_teste="true"       # por padrão, o smoke test "passa"

uso() { sed -n '6,17p' "${BASH_SOURCE[0]}" | sed 's/^#  \{0,1\}//'; }
log() { printf '[deploy] %s\n' "$*"; }
erro() { echo "deploy: erro: $*" >&2; exit 1; }

while getopts "k:t:h" opt; do
    case "$opt" in
        k) manter="$OPTARG" ;;
        t) cmd_teste="$OPTARG" ;;
        h) uso; exit 0 ;;
        *) uso >&2; exit 2 ;;
    esac
done
shift $(( OPTIND - 1 ))

(( $# == 2 )) || { uso >&2; exit 2; }
origem="$1"; area="$2"
[[ -d "$origem" ]] || erro "origem não existe: $origem"

# Trabalhamos com caminhos ABSOLUTOS: o alvo de um symlink precisa resolver
# corretamente a partir da pasta onde o link vive. Caminhos relativos quebrariam.
mkdir -p "$area"
area="$(cd "$area" && pwd)"
origem="$(cd "$origem" && pwd)"

releases="$area/releases"
link="$area/atual"
mkdir -p "$releases"

# Guarda para onde o 'atual' aponta hoje, para poder voltar em caso de falha.
link_anterior=""
[[ -L "$link" ]] && link_anterior="$(readlink "$link")"

# Sufixo aleatório garante unicidade mesmo em dois deploys no MESMO segundo
# (a granularidade da data é de 1s; sem isto, releases colidiriam).
nova="$releases/$(date +%Y%m%d_%H%M%S)_$RANDOM"
while [[ -e "$nova" ]]; do nova="$releases/$(date +%Y%m%d_%H%M%S)_$RANDOM"; done

# --- Rollback: registrado ANTES de qualquer mudança -------------------------
sucesso=0
rollback() {
    (( sucesso )) && return 0          # deu tudo certo: nada a desfazer
    log "FALHA detectada — executando rollback"
    if [[ -n "$link_anterior" ]]; then
        ln -sfn "$link_anterior" "$link"
        log "restaurado 'atual' → $link_anterior"
    else
        rm -f "$link"
        log "removido symlink (não havia versão anterior)"
    fi
    rm -rf -- "$nova"
    log "versão nova descartada"
}
trap rollback EXIT

# --- Etapa 1: copiar o build para uma release datada ------------------------
log "publicando nova versão em $(basename "$nova")"
cp -a "$origem" "$nova"

# --- Etapa 2: troca ATÔMICA do symlink 'atual' ------------------------------
# 'ln -sfn' troca o alvo do link de forma atômica: ninguém vê um estado parcial.
ln -sfn "$nova" "$link"
log "'atual' agora aponta para $(basename "$nova")"

# --- Etapa 3: smoke test; se falhar, o trap faz rollback --------------------
log "rodando smoke test: $cmd_teste"
if ( cd "$link" && eval "$cmd_teste" ); then
    log "smoke test passou ✓"
else
    erro "smoke test falhou"          # dispara o trap (rollback) via exit != 0
fi

# --- Etapa 4: rotação das versões antigas -----------------------------------
mapfile -t versoes < <(find "$releases" -maxdepth 1 -mindepth 1 -type d -printf '%T@ %p\n' \
                        | sort -rn | cut -d' ' -f2-)
if (( ${#versoes[@]} > manter )); then
    for (( i=manter; i<${#versoes[@]}; i++ )); do
        # nunca remova a versão atualmente ativa
        [[ "${versoes[i]}" == "$(readlink "$link")" ]] && continue
        rm -rf -- "${versoes[i]}"
        log "removida versão antiga: $(basename "${versoes[i]}")"
    done
fi

sucesso=1       # a partir daqui o trap não desfaz nada
log "deploy concluído com sucesso"
