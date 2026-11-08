# shellcheck shell=bash
teste_ok()      { executar Daniel; afirmar_igual "Olá, Daniel" "$SAIDA"; afirmar_status 0; }
teste_zero()    { executar;        afirmar_status 2; afirmar_contem "uso:" "$ERRO"; }
teste_demais()  { executar a b;    afirmar_status 2; }
