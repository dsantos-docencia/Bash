# shellcheck shell=bash
teste_maior()  { executar 3 9 2 7; afirmar_igual "9" "$SAIDA"; }
teste_unico()  { executar 42;      afirmar_igual "42" "$SAIDA"; }
teste_ultimo() { executar 1 2 3 99; afirmar_igual "99" "$SAIDA"; }
