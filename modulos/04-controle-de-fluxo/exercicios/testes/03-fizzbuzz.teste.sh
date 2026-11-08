# shellcheck shell=bash
teste_ate_5() {
    executar 5
    afirmar_igual $'1\n2\nFizz\n4\nBuzz' "$SAIDA"
}
teste_fizzbuzz_no_15() {
    executar 15
    afirmar_contem "FizzBuzz" "$SAIDA"
}
