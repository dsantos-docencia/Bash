# shellcheck shell=bash
teste_a() { executar 10; afirmar_igual "A" "$SAIDA"; }
teste_b() { executar 8;  afirmar_igual "B" "$SAIDA"; }
teste_c() { executar 5;  afirmar_igual "C" "$SAIDA"; }
teste_d() { executar 3;  afirmar_igual "D" "$SAIDA"; }
