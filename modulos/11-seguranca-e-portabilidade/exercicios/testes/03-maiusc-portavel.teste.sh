# shellcheck shell=bash
teste_up()   { executar bash;  afirmar_igual "BASH" "$SAIDA"; }
teste_mix()  { executar PoSiX; afirmar_igual "POSIX" "$SAIDA"; }
