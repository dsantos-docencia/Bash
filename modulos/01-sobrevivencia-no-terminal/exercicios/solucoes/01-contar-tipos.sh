#!/usr/bin/env bash
# Curso de Bash · Prof. Daniel Santos · github.com/dsantos-docencia/bash · © 2026 (PolyForm-NC · não comercial)
# Solução 01.01
dir="$1"
# -type f conta arquivos comuns; -type d, diretórios. 'wc -l' conta as linhas.
# -mindepth 1 evita contar o próprio diretório recebido.
echo "arquivos: $(find "$dir" -mindepth 1 -type f | wc -l)"
echo "diretorios: $(find "$dir" -mindepth 1 -type d | wc -l)"
