#!/usr/bin/env bash
# Curso de Bash · Prof. Daniel Santos · github.com/dsantos-docencia/bash · © 2026 (PolyForm-NC · não comercial)
# Solução 01.02
chmod 640 "$1"
# %A pede a permissão simbólica; %a pediria a octal.
stat -c '%A' "$1"
