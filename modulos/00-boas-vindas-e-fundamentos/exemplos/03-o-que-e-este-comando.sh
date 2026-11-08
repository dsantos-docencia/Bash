#!/usr/bin/env bash
# ============================================================================
#  Curso de Bash · Módulo 00 · Exemplo 03 — O que é este comando?
#  Prof. Daniel Santos · github.com/dsantos-docencia/bash · © 2026 (PolyForm-NC · não comercial)
# ----------------------------------------------------------------------------
#  OBJETIVO  Aprender a classificar comandos com `type` antes de procurar ajuda.
#  EXECUTE   bash 03-o-que-e-este-comando.sh
#  OBSERVE   Cada tipo pede uma ferramenta de ajuda diferente.
# ============================================================================

# Um "comando" no Bash pode ser cinco coisas diferentes:
#   keyword  palavra reservada da linguagem (if, for, [[ ...)  → help
#   builtin  embutido no próprio Bash (cd, echo, read)          → help
#   function função definida no shell                           → type mostra o código
#   alias    apelido (só em shells interativos)                 → alias
#   file     programa externo em disco (ls, grep)               → man / --help

saudar() { echo "oi"; }   # uma função, só para aparecer na lista

for cmd in if cd echo saudar ls grep printf comando_que_nao_existe; do
    # type -t devolve só a categoria. 2>/dev/null descarta a mensagem de erro.
    tipo="$(type -t "$cmd" 2>/dev/null)"
    case "$tipo" in
        keyword)  dica="help $cmd" ;;
        builtin)  dica="help $cmd" ;;
        function) dica="type $cmd   (mostra o corpo da função)" ;;
        alias)    dica="alias $cmd" ;;
        file)     dica="man $cmd   ou   $cmd --help" ;;
        *)        tipo="(não encontrado)"; dica="confira a grafia ou instale o pacote" ;;
    esac
    printf '  %-24s %-18s ajuda: %s\n' "$cmd" "$tipo" "$dica"
done

echo
echo "Curiosidade: existem DOIS echo — o builtin e o programa externo:"
type -a echo | sed 's/^/  /'
echo "  O Bash sempre prefere o builtin. Por isso 'man echo' pode descrever"
echo "  opções diferentes das que o seu 'echo' realmente aceita."
