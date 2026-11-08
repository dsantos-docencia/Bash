teste_acha_o_maior() {
    head -c 100  /dev/zero > pequeno.bin
    head -c 5000 /dev/zero > grande.bin
    head -c 10   /dev/zero > minusculo.bin
    executar "$PWD"
    afirmar_contem "grande.bin" "$SAIDA"
    afirmar_nao_contem "pequeno.bin" "$SAIDA"
}
