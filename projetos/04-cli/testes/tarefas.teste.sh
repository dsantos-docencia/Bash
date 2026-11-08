# shellcheck shell=bash
# Aponta o arquivo de estado para dentro do diretório temporário do teste.
_arq() { echo "$PWD/t.txt"; }

teste_add_e_list() {
    TAREFAS_ARQUIVO="$(_arq)" executar add "primeira tarefa"
    afirmar_contem "adicionada" "$SAIDA"
    TAREFAS_ARQUIVO="$(_arq)" executar list
    afirmar_contem "primeira tarefa" "$SAIDA"
    afirmar_contem "1 aberta(s) de 1" "$SAIDA"
}

teste_concluir() {
    local a; a="$(_arq)"
    TAREFAS_ARQUIVO="$a" executar add "tarefa X" >/dev/null 2>&1 || true
    # 'executar' roda num processo novo; refazemos o estado a cada passo:
    printf 'aberta|t1\naberta|t2\n' > "$a"
    TAREFAS_ARQUIVO="$a" executar "done" 1
    afirmar_contem "concluída" "$SAIDA"
    TAREFAS_ARQUIVO="$a" executar list
    afirmar_contem "[x] t1" "$SAIDA"
    afirmar_contem "1 aberta(s) de 2" "$SAIDA"
}

teste_remover() {
    local a; a="$(_arq)"
    printf 'aberta|t1\naberta|t2\n' > "$a"
    TAREFAS_ARQUIVO="$a" executar rm 1
    afirmar_contem "removida" "$SAIDA"
    afirmar_igual "1" "$(wc -l < "$a")"
}

teste_numero_invalido_falha() {
    local a; a="$(_arq)"; printf 'aberta|t1\n' > "$a"
    TAREFAS_ARQUIVO="$a" executar "done" 9
    afirmar_status 1
    afirmar_contem "não existe" "$ERRO"
}

teste_lista_vazia() {
    TAREFAS_ARQUIVO="$(_arq)" executar list
    afirmar_contem "nenhuma tarefa" "$SAIDA"
}
