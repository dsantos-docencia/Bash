# shellcheck shell=bash
teste_padrao() { executar;            afirmar_igual "Oi, mundo" "$SAIDA"; }
teste_nome()   { executar -n Ana;     afirmar_igual "Oi, Ana" "$SAIDA"; }
teste_maiusc() { executar -u -n Ana;  afirmar_igual "OI, ANA" "$SAIDA"; }
teste_ajuda()  { executar -h;         afirmar_status 0; afirmar_contem "uso:" "$SAIDA"; }
