# shellcheck shell=bash
teste_soma() {
    printf 'cafe 4\npao 2\nleite 6\n' > dados.txt
    executar dados.txt
    afirmar_igual "12" "$SAIDA"
}
teste_vazio() {
    : > vazio.txt
    executar vazio.txt
    afirmar_igual "0" "$SAIDA"
}
