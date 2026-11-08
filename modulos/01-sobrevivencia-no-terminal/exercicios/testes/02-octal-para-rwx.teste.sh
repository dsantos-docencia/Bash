teste_640_vira_rw_r() {
    : > alvo.txt
    executar alvo.txt
    afirmar_igual "-rw-r-----" "$SAIDA"
}
