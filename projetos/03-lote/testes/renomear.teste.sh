# shellcheck shell=bash
teste_simulacao_nao_altera() {
    mkdir -p p; touch "p/Foto Um.JPG"
    executar p                       # sem -x: só simula
    afirmar_contem "SIMULAÇÃO" "$SAIDA"
    afirmar_arquivo "p/Foto Um.JPG"  # o arquivo original CONTINUA lá
}

teste_executa_renomeia() {
    mkdir -p p; touch "p/Foto Um.JPG"
    executar -x p
    afirmar_arquivo "p/foto_um.jpg"          # minúsculas + espaço→_
    afirmar_igual "0" "$(find p -name 'Foto Um.JPG' | wc -l)" "o original devia ter sumido"
}

teste_prefixo() {
    mkdir -p p; touch "p/doc.txt"
    executar -x -p "2026_" p
    afirmar_arquivo "p/2026_doc.txt"
}

teste_idempotente() {
    mkdir -p p; touch "p/ja_ok.txt"
    executar -x p
    afirmar_contem "inalterados: 1" "$SAIDA"
}
