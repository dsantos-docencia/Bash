#!/usr/bin/env bash
# Curso de Bash · Prof. Daniel Santos · github.com/dsantos-docencia/bash · © 2026 (MIT)
# Solução 02.03
touch nota-{01..05}.md
find . -maxdepth 1 -name '*.md' | wc -l
