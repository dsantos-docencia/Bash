#!/usr/bin/env bash
# Curso de Bash · Prof. Daniel Santos · github.com/dsantos-docencia/bash · © 2026 (MIT)
# Solução 10.01
for s in "$@"; do
    sleep "$s" &
done
wait
echo "concluido: $#"
