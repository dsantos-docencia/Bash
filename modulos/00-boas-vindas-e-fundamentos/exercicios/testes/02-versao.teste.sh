# shellcheck shell=bash
# Testes do exercício 00.02
teste_formato_da_versao() {
    executar
    afirmar_igual "Bash ${BASH_VERSINFO[0]}.${BASH_VERSINFO[1]}" "$SAIDA"
}
teste_nao_usa_bash_version_completo() {
    executar
    afirmar_casa '^Bash [0-9]+\.[0-9]+$' "$SAIDA" "só maior.menor, sem patch nem (1)-release"
}
