#!/usr/bin/env bats
# ============================================================================
#  Curso de Bash · Módulo 08 · calculadora.bats
#  Prof. Daniel Santos · github.com/dsantos-docencia/bash · © 2026 (MIT)
# ----------------------------------------------------------------------------
#  Testes Bats para calculadora.sh. Rode com:
#     bats modulos/08-qualidade-e-testes/exemplos/calculadora.bats
# ============================================================================

# Caminho do script sob teste, relativo a este arquivo .bats.
CALC="${BATS_TEST_DIRNAME}/calculadora.sh"

@test "soma é o padrão" {
    run bash "$CALC" 2 3
    [ "$status" -eq 0 ]
    [ "$output" = "5" ]
}

@test "subtração com -o" {
    run bash "$CALC" -o SUBTRAIR 10 4
    [ "$status" -eq 0 ]
    [ "$output" = "6" ]
}

@test "multiplicação" {
    run bash "$CALC" -o MULTIPLICAR 6 7
    [ "$output" = "42" ]
}

@test "modo verboso mostra a conta" {
    run bash "$CALC" -v 2 3
    [ "$output" = "2 + 3 = 5" ]
}

@test "divisão por zero falha com mensagem" {
    run bash "$CALC" -o DIVIDIR 5 0
    [ "$status" -ne 0 ]
    [[ "$output" == *"divisão por zero"* ]]
}

@test "entrada não numérica é rejeitada" {
    run bash "$CALC" dois 3
    [ "$status" -ne 0 ]
}

@test "número errado de argumentos mostra uso e sai com 2" {
    run bash "$CALC" 5
    [ "$status" -eq 2 ]
}
