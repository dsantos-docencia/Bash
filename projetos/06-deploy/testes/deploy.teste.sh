# shellcheck shell=bash
_build() { mkdir -p build; echo "v$1" > "build/versao.txt"; }

teste_deploy_bem_sucedido() {
    _build 1
    executar build producao
    afirmar_status 0
    afirmar_contem "concluído com sucesso" "$SAIDA"
    # 'atual' deve apontar para uma release com o conteúdo certo
    afirmar_igual "v1" "$(cat producao/atual/versao.txt)"
}

teste_rollback_quando_teste_falha() {
    # 1º deploy OK (vira a versão "anterior")
    _build 1; executar build producao >/dev/null 2>&1
    # 2º deploy com smoke test que SEMPRE falha → deve voltar para a v1
    _build 2; executar -t 'false' build producao
    afirmar_status 1
    afirmar_contem "rollback" "$SAIDA"
    afirmar_igual "v1" "$(cat producao/atual/versao.txt)" "deveria ter voltado para v1"
}

teste_primeiro_deploy_com_falha_nao_deixa_link() {
    _build 1
    executar -t 'false' build producao
    afirmar_status 1
    # como não havia versão anterior, o symlink não deve existir
    [[ -L producao/atual ]] && afirmar_igual "sem link" "com link" "não devia sobrar symlink"
    afirmar_contem "rollback" "$SAIDA"
}

teste_rotacao() {
    _build 1
    # 4 deploys com -k 2 → no máx 2 releases (+ a ativa protegida)
    for v in 1 2 3 4; do _build "$v"; executar -k 2 build producao >/dev/null 2>&1; done
    local n; n=$(find producao/releases -maxdepth 1 -mindepth 1 -type d | wc -l)
    (( n <= 3 )) && afirmar_igual "ok" "ok" || afirmar_igual "<=3" "$n"
}
