# shellcheck shell=bash
teste_dez()  { executar 10; afirmar_igual "55" "$SAIDA"; }
teste_um()   { executar 1;  afirmar_igual "1" "$SAIDA"; }
