# shellcheck shell=bash
teste_saida_normal() {
    executar
    afirmar_igual $'1\n2\n3' "$SAIDA"
}
