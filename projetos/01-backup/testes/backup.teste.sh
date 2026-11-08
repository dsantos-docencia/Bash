# shellcheck shell=bash
# Prepara uma origem com conteúdo e um destino, ambos no diretório do teste.
_prep() {
    mkdir -p origem/sub
    echo "conteudo" > origem/a.txt
    echo "mais"     > origem/sub/b.txt
}

teste_cria_backup() {
    _prep
    executar -o dest origem
    afirmar_status 0
    afirmar_diretorio "dest"
    # o stdout final é o caminho do arquivo gerado
    afirmar_contem "backup_origem_" "$SAIDA"
    # deve existir exatamente 1 .tar.gz
    local n; n=$(find dest -name '*.tar.gz' | wc -l)
    afirmar_igual "1" "$n"
}

teste_rotacao_mantem_n() {
    _prep
    # cria 4 backups com -k 2; no fim devem sobrar 2
    for _ in 1 2 3 4; do executar -q -o dest -k 2 origem; sleep 1; done
    local n; n=$(find dest -name '*.tar.gz' | wc -l)
    afirmar_igual "2" "$n" "a rotação deveria manter só 2 cópias"
}

teste_origem_inexistente_falha() {
    executar -o dest /nao/existe/mesmo
    afirmar_status 1
    afirmar_contem "não existe" "$ERRO"
}

teste_ajuda() {
    executar -h
    afirmar_status 0
    afirmar_contem "Uso:" "$SAIDA"
}
