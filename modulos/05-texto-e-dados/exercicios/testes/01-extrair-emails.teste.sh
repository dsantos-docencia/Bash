# shellcheck shell=bash
teste_extrai() {
    cat > texto.txt <<'FIM'
Fale com ana@exemplo.com ou suporte@grupoiconne.net.
Sem email nesta linha.
Outro: bia.lima%teste@mail.co
FIM
    executar texto.txt
    afirmar_contem "ana@exemplo.com" "$SAIDA"
    afirmar_contem "suporte@grupoiconne.net" "$SAIDA"
    afirmar_nao_contem "Sem email" "$SAIDA"
}
