#!/usr/bin/env bash
# ============================================================================
#  Curso de Bash · Projeto 5 · checar-links.sh — Verificador de links Markdown
#  Prof. Daniel Santos · github.com/dsantos-docencia/bash · © 2026 (PolyForm-NC · não comercial)
# ----------------------------------------------------------------------------
#  Lê um arquivo Markdown, extrai os links [texto](destino) e verifica se os
#  links LOCAIS (arquivos relativos) existem. Reporta os quebrados e sai com
#  status 1 se houver algum. Links http(s) e âncoras (#) são ignorados.
#
#  Uso:  checar-links.sh <arquivo.md> [arquivo2.md ...]
#        -v   verboso (mostra também os links OK)
#        -h   ajuda
#
#  Conceitos: grep -oE, laço, caminhos relativos, código de saída, relatório.
#  (Serve para manter a documentação deste próprio repositório sem links mortos.)
# ============================================================================
set -euo pipefail

verboso=0
uso() { sed -n '6,14p' "${BASH_SOURCE[0]}" | sed 's/^#  \{0,1\}//'; }

while getopts "vh" opt; do
    case "$opt" in
        v) verboso=1 ;;
        h) uso; exit 0 ;;
        *) uso >&2; exit 2 ;;
    esac
done
shift $(( OPTIND - 1 ))

(( $# >= 1 )) || { uso >&2; exit 2; }

quebrados=0
verificados=0

# Remove blocos <!-- ... --> (inclusive multilinha) de um arquivo, imprimindo
# o resto. Feito com awk (sem dependências externas), percorrendo caractere a
# caractere com um estado "dentro/fora de comentário".
sem_comentarios_html() {
    awk '
    {
        linha = $0; saida = ""; i = 1; n = length(linha)
        while (i <= n) {
            if (!dentro && substr(linha, i, 4) == "<!--") { dentro = 1; i += 4; continue }
            if (dentro && substr(linha, i, 3) == "-->")   { dentro = 0; i += 3; continue }
            if (!dentro) saida = saida substr(linha, i, 1)
            i++
        }
        print saida
    }' "$1"
}

checar_arquivo() {
    local md="$1"
    [[ -f "$md" ]] || { echo "erro: não achei $md" >&2; return 1; }
    local base; base="$(dirname -- "$md")"

    # grep extrai o "destino" de cada [texto](destino). O -oP pega só o grupo;
    # como nem todo grep tem -P, usamos -oE e limpamos com sed.
    local destino
    while IFS= read -r destino; do
        [[ -n "$destino" ]] || continue
        verificados=$(( verificados + 1 ))

        # Ignora links externos e âncoras internas.
        case "$destino" in
            http://*|https://*|mailto:*|\#*)
                (( verboso )) && echo "  [extern] $destino"
                continue ;;
        esac

        # Remove uma âncora (#secao) ao fim, se houver, antes de testar o arquivo.
        local caminho="${destino%%#*}"
        [[ -n "$caminho" ]] || continue

        if [[ -e "$base/$caminho" ]]; then
            (( verboso )) && echo "  [ok]     $destino"
        else
            echo "  [QUEBRADO] $md → $destino"
            quebrados=$(( quebrados + 1 ))
        fi
    # Antes de extrair, removemos o que NÃO é link de verdade, para não acusar
    # exemplos de sintaxe: (1) comentários HTML <!-- ... --> (podem ser multilinha)
    # e (2) trechos de código inline `...`. Só então pegamos os [texto](destino).
    done < <(sem_comentarios_html "$md" | sed 's/`[^`]*`//g' | grep -oE '\]\([^)]+\)' | sed -E 's/^\]\(//; s/\)$//')
}

for md in "$@"; do
    echo "verificando: $md"
    checar_arquivo "$md" || true
done

echo "---"
echo "links verificados: $verificados | quebrados: $quebrados"
(( quebrados == 0 ))      # vira o código de saída: 0 se nenhum quebrado
