#!/usr/bin/env bash
# ============================================================================
#  Curso de Bash — Do Zero à Automação Profissional
#  ferramentas/verificar-tudo.sh — Garantia de qualidade do repositório
#
#  Autor: Prof. Daniel Santos · https://github.com/dsantos-docencia/bash
#  © 2026 Daniel Santos — Código sob licença MIT (veja LICENSE)
# ============================================================================
#
#  Este script é a promessa do repositório: TODO exemplo aqui funciona.
#  Ele roda localmente e também no GitHub Actions a cada push/PR.
#
#  Etapas:
#    1. Sintaxe   — bash -n em todos os .sh (exceto acervo/)
#    2. Lint      — shellcheck (se instalado)
#    3. Exemplos  — executa cada modulos/*/exemplos/*.sh e exige status 0
#    4. Soluções  — roda o corretor contra as soluções oficiais
#    5. Projetos  — roda os testes de cada projeto
#
#  USO:  ./ferramentas/verificar-tudo.sh [--rapido]   (--rapido pula etapa 3)
# ============================================================================
set -uo pipefail

RAIZ="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd -- "$RAIZ" || exit 1

rapido=0
[[ "${1:-}" == "--rapido" ]] && rapido=1

if [[ -t 1 ]]; then V=$'\e[32m' R=$'\e[31m' A=$'\e[33m' N=$'\e[1m' Z=$'\e[0m'
else V='' R='' A='' N='' Z=''; fi

erros=0
titulo() { printf '\n%s== %s ==%s\n' "$N" "$1" "$Z"; }
ok()     { printf '  %s✔%s %s\n' "$V" "$Z" "$1"; }
falha()  { printf '  %s✘%s %s\n' "$R" "$Z" "$1"; (( erros++ )); }

# Lista de scripts, robusta a espaços no nome (-print0 + read -d '').
scripts=()
while IFS= read -r -d '' f; do
    scripts+=("$f")
done < <(find . -path ./scripts -prune -o -path ./.git -prune -o -name '*.sh' -type f -print0 | sort -z)

titulo "1. Sintaxe (bash -n) — ${#scripts[@]} arquivos"
n=0
for f in "${scripts[@]}"; do
    if bash -n "$f" 2>/dev/null; then (( n++ )); else falha "$f"; bash -n "$f"; fi
done
ok "$n arquivos com sintaxe válida"

titulo "2. ShellCheck"
if command -v shellcheck >/dev/null; then
    if shellcheck --severity=warning -x "${scripts[@]}"; then ok "nenhum aviso"; else falha "shellcheck encontrou problemas (acima)"; fi
else
    printf '  %s!%s shellcheck não instalado — etapa pulada (apt install shellcheck)\n' "$A" "$Z"
fi

if (( ! rapido )); then
    titulo "3. Execução dos exemplos"
    for f in modulos/*/exemplos/*.sh; do
        tmp="$(mktemp -d)"
        # Cada exemplo roda num diretório vazio, sem teclado (stdin=/dev/null)
        # e com tempo limitado. Um exemplo didático não pode travar nem falhar.
        if saida="$(cd "$tmp" && timeout 60 bash "$RAIZ/$f" </dev/null 2>&1)"; then
            ok "$f"
        else
            falha "$f"; printf '%s\n' "$saida" | tail -n 15 | sed 's/^/      /'
        fi
        rm -rf -- "$tmp"
    done
fi

titulo "4. Soluções oficiais contra os testes"
if ./ferramentas/corrigir.sh --todos --solucao >/tmp/corrigir.log 2>&1; then
    ok "todas as soluções passam ($(grep -c '✔' /tmp/corrigir.log) casos de teste)"
else
    falha "alguma solução falhou"; grep -E '✘|▶' /tmp/corrigir.log | sed 's/^/    /'
fi

titulo "5. Testes dos projetos"
for t in projetos/*/testes/*.teste.sh; do
    [[ -e "$t" ]] || continue
    alvo="$(dirname -- "$(dirname -- "$t")")/$(basename -- "$t" .teste.sh).sh"
    # shellcheck source=lib/teste.sh
    if ( source ferramentas/lib/teste.sh; rodar_testes "$t" "$alvo" ) >/tmp/proj.log 2>&1; then
        ok "$t"
    else
        falha "$t"; sed 's/^/      /' /tmp/proj.log
    fi
done

echo
if (( erros == 0 )); then printf '%s%sRepositório íntegro.%s\n' "$N" "$V" "$Z"
else printf '%s%s%d problema(s) encontrado(s).%s\n' "$N" "$R" "$erros" "$Z"; fi
exit $(( erros > 0 ))
