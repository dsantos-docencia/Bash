#!/usr/bin/env bash
# ============================================================================
#  Curso de Bash · Módulo 00 · Exemplo 01 — Olá, mundo
#  Prof. Daniel Santos · github.com/dsantos-docencia/bash · © 2026 (MIT)
# ----------------------------------------------------------------------------
#  OBJETIVO  Ver a anatomia mínima de um script Bash.
#  EXECUTE   bash 01-ola-mundo.sh            (pede ao bash para ler o arquivo)
#            chmod +x 01-ola-mundo.sh && ./01-ola-mundo.sh   (usa o shebang)
#  OBSERVE   As duas formas produzem o mesmo resultado — mas por caminhos
#            diferentes. O Módulo 04 explica a diferença em detalhes.
# ============================================================================

# A PRIMEIRA LINHA (#!/usr/bin/env bash) é o "shebang".
# Quando você roda ./script, o KERNEL lê esses dois caracteres "#!" e entende:
# "este arquivo deve ser entregue ao programa indicado a seguir".
# Linhas que começam com # (fora o shebang) são comentários: o Bash ignora.

echo "Olá, mundo!"

# `echo` imprime seus argumentos separados por espaço e termina com \n.
# As aspas duplas mantêm "Olá," e "mundo!" como UM argumento só.
# Experimente depois:   echo Olá,     mundo!     (sem aspas: espaços colapsam)

echo "Este script se chama: $0"
# $0 é uma variável especial: o nome com que o script foi chamado.
# Rode das duas formas e compare o que aparece aqui.

echo "Ele está sendo interpretado pelo Bash $BASH_VERSION"
