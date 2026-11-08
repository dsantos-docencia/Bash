#!/usr/bin/env bash
# Curso de Bash · Prof. Daniel Santos · github.com/dsantos-docencia/bash · © 2026 (PolyForm-NC · não comercial)
# Solução 03.03 — %-15s alinha o produto à esquerda; %6.2f formata o preço.
printf '%-15s R$ %6.2f\n' "$1" "$2"
