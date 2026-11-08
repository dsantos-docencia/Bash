#!/usr/bin/env bash
# Curso de Bash · Prof. Daniel Santos · github.com/dsantos-docencia/bash · © 2026 (PolyForm-NC · não comercial)
# Solução 11.03 — tr é portável (funciona em sh), ao contrário de ${var^^}.
printf '%s\n' "$1" | tr '[:lower:]' '[:upper:]'
