# shellcheck shell=bash
teste_todos_ok() {
    mkdir -p d
    echo "existe" > d/alvo.md
    printf 'veja [alvo](alvo.md) e [site](https://x.com)\n' > d/doc.md
    executar d/doc.md
    afirmar_status 0
    afirmar_contem "quebrados: 0" "$SAIDA"
}

teste_detecta_quebrado() {
    mkdir -p d
    printf 'link [morto](nao-existe.md)\n' > d/doc.md
    executar d/doc.md
    afirmar_status 1
    afirmar_contem "QUEBRADO" "$SAIDA"
    afirmar_contem "quebrados: 1" "$SAIDA"
}

teste_ignora_externos_e_ancoras() {
    mkdir -p d
    printf '[ext](https://x.com) [anc](#secao)\n' > d/doc.md
    executar d/doc.md
    afirmar_status 0
}

teste_ancora_em_arquivo_local() {
    mkdir -p d; echo x > d/pag.md
    printf '[sec](pag.md#parte)\n' > d/doc.md
    executar d/doc.md
    afirmar_status 0          # a âncora é removida antes de testar o arquivo
}
