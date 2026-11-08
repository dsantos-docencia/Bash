# shellcheck shell=bash
teste_tres()  { executar a b c; afirmar_igual "Você passou 3 argumento(s)." "$SAIDA"; }
teste_zero()  { executar;       afirmar_igual "Você passou 0 argumento(s)." "$SAIDA"; }
