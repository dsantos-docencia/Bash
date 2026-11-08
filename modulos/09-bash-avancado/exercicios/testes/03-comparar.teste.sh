# shellcheck shell=bash
teste_iguais() {
    printf 'b\na\nc\n' > x.txt; printf 'a\nb\nc\n' > y.txt
    executar x.txt y.txt
    afirmar_igual "iguais" "$SAIDA"
}
teste_diferentes() {
    printf 'a\nb\n' > x.txt; printf 'a\nz\n' > y.txt
    executar x.txt y.txt
    afirmar_igual "diferentes" "$SAIDA"; afirmar_status 1
}
