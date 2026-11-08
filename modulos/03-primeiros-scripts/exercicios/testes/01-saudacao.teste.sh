# shellcheck shell=bash
teste_com_nome()  { executar Daniel; afirmar_igual "Olá, Daniel!" "$SAIDA"; }
teste_sem_nome()  { executar;        afirmar_igual "Olá, visitante!" "$SAIDA"; afirmar_status 0; }
