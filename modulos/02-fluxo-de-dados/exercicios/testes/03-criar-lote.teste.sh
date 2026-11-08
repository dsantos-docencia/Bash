# shellcheck shell=bash
teste_cria_cinco_md() {
    executar
    afirmar_igual "5" "$SAIDA"
    afirmar_arquivo "nota-03.md"
}
