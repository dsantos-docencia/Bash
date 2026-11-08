# shellcheck shell=bash
teste_tres_mais_frequentes() {
    printf 'sol sol sol mar mar vento praia praia praia praia\n' > texto.txt
    executar texto.txt
    # praia(4) sol(3) mar(2) — nessa ordem
    afirmar_igual $'praia\nsol\nmar' "$SAIDA"
}
