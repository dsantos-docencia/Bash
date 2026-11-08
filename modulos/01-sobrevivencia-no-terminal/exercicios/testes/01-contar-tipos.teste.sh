# shellcheck shell=bash
teste_conta_certo() {
    mkdir -p a/b/c; : > a/x.txt; : > a/b/y.txt   # 2 arquivos, 3 diretórios (a, a/b, a/b/c)
    executar "$PWD"
    afirmar_contem "arquivos: 2" "$SAIDA"
    afirmar_contem "diretorios: 3" "$SAIDA"
}
