# shellcheck shell=bash
# Usamos um produto sem acento para o alinhamento ser previsível
# (printf conta BYTES; letras acentuadas em UTF-8 ocupam 2 bytes).
teste_formato() {
    executar Mel 4.5
    afirmar_igual "Mel             R\$   4.50" "$SAIDA"
}
teste_outro_valor() {
    executar Pao 0.75
    afirmar_igual "Pao             R\$   0.75" "$SAIDA"
}
