#!/usr/bin/env bash
# Curso de Bash · Prof. Daniel Santos · github.com/dsantos-docencia/bash · © 2026 (MIT)
# Solução 08.01
nome="mundo"; maiusc=0
while getopts "n:uh" opt; do
    case "$opt" in
        n) nome="$OPTARG" ;;
        u) maiusc=1 ;;
        h) echo "uso: $(basename "$0") [-n NOME] [-u] [-h]"; exit 0 ;;
        *) echo "opção inválida" >&2; exit 2 ;;
    esac
done
msg="Oi, $nome"
(( maiusc )) && msg="${msg^^}"
echo "$msg"
