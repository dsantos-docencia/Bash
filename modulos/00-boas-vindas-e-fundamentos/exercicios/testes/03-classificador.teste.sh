# Testes do exercício 00.03
teste_builtin()  { executar cd;   afirmar_igual "builtin" "$SAIDA"; afirmar_status 0; }
teste_keyword()  { executar if;   afirmar_igual "keyword" "$SAIDA"; }
teste_arquivo()  { executar ls;   afirmar_igual "file" "$SAIDA"; }
teste_inexistente() {
    executar comando_inexistente_xyz
    afirmar_igual "desconhecido" "$SAIDA"
    afirmar_status 1 "comando inexistente deve terminar com exit 1"
}
