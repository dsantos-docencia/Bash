# shellcheck shell=bash
teste_valido()   { executar "0 2 * * *";   afirmar_igual "ok" "$SAIDA"; afirmar_status 0; }
teste_curto()    { executar "0 2 * *";     afirmar_igual "invalido" "$SAIDA"; afirmar_status 1; }
teste_longo()    { executar "0 2 * * * x"; afirmar_igual "invalido" "$SAIDA"; }
