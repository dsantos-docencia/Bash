#!/usr/bin/env bash
# Curso de Bash · Prof. Daniel Santos · github.com/dsantos-docencia/bash · © 2026 (MIT)
# Solução 04.03 — testa o múltiplo de 15 (3 e 5) ANTES dos individuais.
for (( i=1; i<=$1; i++ )); do
    if   (( i % 15 == 0 )); then echo "FizzBuzz"
    elif (( i % 3  == 0 )); then echo "Fizz"
    elif (( i % 5  == 0 )); then echo "Buzz"
    else                        echo "$i"
    fi
done
