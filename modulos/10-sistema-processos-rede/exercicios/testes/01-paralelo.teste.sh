# shellcheck shell=bash
teste_conta() {
    executar 0 0 0
    afirmar_igual "concluido: 3" "$SAIDA"
}
