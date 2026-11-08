# shellcheck shell=bash
teste_prog() { executar programacao; afirmar_igual "5" "$SAIDA"; }
teste_sem()  { executar xyz;         afirmar_igual "0" "$SAIDA"; }
