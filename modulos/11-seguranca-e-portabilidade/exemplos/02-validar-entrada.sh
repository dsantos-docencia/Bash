#!/usr/bin/env bash
# ============================================================================
#  Curso de Bash · Módulo 11 · Exemplo 02 — Validar entrada (dado ≠ código)
#  Prof. Daniel Santos · github.com/dsantos-docencia/bash · © 2026 (MIT)
# ----------------------------------------------------------------------------
#  OBJETIVO  Mostrar validação de entrada e por que NÃO se usa eval com dados
#            externos — de forma segura, sem executar nada perigoso.
#  EXECUTE   bash 02-validar-entrada.sh
# ============================================================================
set -uo pipefail

echo "1) Validando formatos ANTES de usar:"
validar_id()    { [[ "$1" =~ ^[0-9]+$ ]]; }
validar_email() { [[ "$1" =~ ^[^@[:space:]]+@[^@[:space:]]+\.[^@[:space:]]+$ ]]; }
checar() {
    local tipo="$1" valor="$2"
    if "validar_$tipo" "$valor"; then
        printf '   ✔ %-6s %-25s válido\n' "$tipo" "[$valor]"
    else
        printf '   ✘ %-6s %-25s INVÁLIDO (rejeitado)\n' "$tipo" "[$valor]"
    fi
}
checar id    "12345"
checar id    "12; rm -rf /"          # tentativa de injeção → rejeitada pelo formato
checar email "ana@exemplo.com"
checar email "nao-eh-email"

echo
echo "2) Por que NÃO usar eval com entrada do usuário:"
entrada_maliciosa='; echo "COMANDO INJETADO EXECUTOU"'
echo "   Entrada hostil: [$entrada_maliciosa]"
echo "   ❌ 'eval \"echo Olá \$entrada\"' executaria o que vem depois do ';'."
echo "   ✔ tratando como DADO (só texto), nada é executado:"
echo "      Olá $entrada_maliciosa"       # aspas → é só uma string impressa

echo
echo "3) Indireção em vez de eval para 'variável dinâmica':"
# shellcheck disable=SC2034  # usada via indireção ${!nome_var} logo abaixo
config_porta=8080
nome_var="config_porta"
echo "   valor via \${!nome_var}: ${!nome_var}   (seguro, sem eval)"

echo
echo "4) Proteção contra path traversal:"
caminho_suspeito="../../etc/passwd"
if [[ "$caminho_suspeito" == *..* ]]; then
    echo "   ✘ [$caminho_suspeito] contém '..' → rejeitado (tentativa de sair da pasta)"
fi

echo
echo "Regra de ouro: entrada do usuário é DADO, nunca CÓDIGO."
