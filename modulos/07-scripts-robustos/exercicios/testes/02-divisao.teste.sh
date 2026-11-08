# shellcheck shell=bash
teste_divide() { executar 10 2; afirmar_igual "5" "$SAIDA"; }
teste_zero()   { executar 10 0; afirmar_status 1; afirmar_contem "divisao por zero" "$ERRO"; }
