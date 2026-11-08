#!/usr/bin/env bash
# Curso de Bash · Prof. Daniel Santos · github.com/dsantos-docencia/bash · © 2026 (PolyForm-NC · não comercial)
# Solução 05.03 — ${1%.*} remove a menor extensão; concatenamos .bak.
echo "${1%.*}.bak"
