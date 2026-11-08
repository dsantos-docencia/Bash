# shellcheck shell=bash
teste_soma()  { executar 3 4 5; afirmar_igual "12" "$SAIDA"; afirmar_status 0; }
teste_vazio() { executar;       afirmar_igual "0" "$SAIDA"; afirmar_status 0; }
teste_um()    { executar 7;     afirmar_igual "7" "$SAIDA"; }
