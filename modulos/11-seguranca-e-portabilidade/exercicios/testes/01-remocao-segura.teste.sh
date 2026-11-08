# shellcheck shell=bash
teste_ok()        { executar /tmp/x; afirmar_igual "ok: removeria /tmp/x" "$SAIDA"; afirmar_status 0; }
teste_vazio()     { executar "";     afirmar_status 1; afirmar_contem "recusado" "$ERRO"; }
teste_raiz()      { executar /;      afirmar_status 1; }
teste_traversal() { executar ../etc; afirmar_status 1; }
