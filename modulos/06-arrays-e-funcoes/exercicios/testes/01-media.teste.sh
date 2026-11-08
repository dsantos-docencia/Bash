# shellcheck shell=bash
teste_media() { executar 10 20 30; afirmar_igual "20" "$SAIDA"; }
teste_um()    { executar 7;         afirmar_igual "7" "$SAIDA"; }
