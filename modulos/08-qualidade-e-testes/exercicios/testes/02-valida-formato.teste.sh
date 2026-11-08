# shellcheck shell=bash
teste_valido()   { executar "123.456.789-00"; afirmar_igual "valido" "$SAIDA"; afirmar_status 0; }
teste_invalido() { executar "12345678900";    afirmar_igual "invalido" "$SAIDA"; afirmar_status 1; }
