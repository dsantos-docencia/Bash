# shellcheck shell=bash
# Testes do exercício 00.01
teste_imprime_ola_mundo() {
    executar
    afirmar_status 0
    afirmar_igual "Olá, mundo!" "$SAIDA" "a saída deve ser exatamente 'Olá, mundo!' (confira acento e vírgula)"
}
