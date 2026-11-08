#!/usr/bin/env bash
# Curso de Bash · Prof. Daniel Santos · github.com/dsantos-docencia/bash · © 2026 (MIT)
# Solução 03.01 — ${1:-visitante} usa "visitante" se $1 estiver ausente/vazio.
nome="${1:-visitante}"
echo "Olá, ${nome}!"
