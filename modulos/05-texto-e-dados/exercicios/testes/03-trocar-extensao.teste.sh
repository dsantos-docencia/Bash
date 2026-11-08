# shellcheck shell=bash
teste_troca() { executar /a/b/c.txt; afirmar_igual "/a/b/c.bak" "$SAIDA"; }
teste_outra() { executar relatorio.md; afirmar_igual "relatorio.bak" "$SAIDA"; }
