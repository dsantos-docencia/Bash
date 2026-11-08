#!/usr/bin/env bash
# Curso de Bash · Prof. Daniel Santos · github.com/dsantos-docencia/bash · © 2026 (MIT)
# Solução 00.03
# type -t imprime a categoria, ou nada (com status 1) se não encontrar.
# O "if" testa o CÓDIGO DE SAÍDA do comando — conceito central do Módulo 05.
if tipo="$(type -t "$1" 2>/dev/null)"; then
    echo "$tipo"
else
    echo "desconhecido"
    exit 1
fi
