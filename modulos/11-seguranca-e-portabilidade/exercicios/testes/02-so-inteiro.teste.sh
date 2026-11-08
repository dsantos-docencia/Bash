# shellcheck shell=bash
teste_pos()  { executar 42;    afirmar_igual "numero" "$SAIDA"; }
teste_neg()  { executar -7;    afirmar_igual "numero" "$SAIDA"; }
teste_nao()  { executar 3.14;  afirmar_igual "nao" "$SAIDA"; afirmar_status 1; }
teste_texto(){ executar abc;   afirmar_igual "nao" "$SAIDA"; }
