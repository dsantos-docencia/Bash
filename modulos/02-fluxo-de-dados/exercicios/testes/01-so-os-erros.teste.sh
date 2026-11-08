teste_so_stderr() {
    executar
    afirmar_igual "deu ruim" "$SAIDA" "deve sobrar só a mensagem de erro"
}
