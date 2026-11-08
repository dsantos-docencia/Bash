# shellcheck shell=bash
teste_config() {
    executar web 8080
    afirmar_igual $'[servico]\nnome=web\nporta=8080' "$SAIDA"
}
