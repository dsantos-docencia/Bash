#!/usr/bin/env bash
# Curso de Bash · Prof. Daniel Santos · github.com/dsantos-docencia/bash · © 2026 (PolyForm-NC · não comercial)
# Solução 02.02
# tr troca espaços por quebras de linha (uma palavra por linha);
# sort agrupa; uniq -c conta; sort -rn ordena desc; head pega 3;
# o awk final imprime só a 2ª coluna (a palavra), descartando a contagem.
tr ' ' '\n' < "$1" | grep -v '^$' | sort | uniq -c | sort -rn | head -3 | awk '{print $2}'
