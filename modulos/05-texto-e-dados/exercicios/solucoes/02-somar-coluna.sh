#!/usr/bin/env bash
# Curso de Bash · Prof. Daniel Santos · github.com/dsantos-docencia/bash · © 2026 (MIT)
# Solução 05.02 — awk acumula a 2ª coluna e imprime no END. +0 garante número.
awk '{soma += $2} END {print soma+0}' "$1"
