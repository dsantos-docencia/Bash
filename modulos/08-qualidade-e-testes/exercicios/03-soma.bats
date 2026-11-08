#!/usr/bin/env bats
# Complete com seus casos de teste. Rode: bats 03-soma.bats
SOMA="${BATS_TEST_DIRNAME}/03-soma.sh"

@test "soma simples" {
    run bash "$SOMA" 2 3
    [ "$output" = "5" ]
}

# TODO: adicione pelo menos mais um @test (ex.: números negativos, zero...)
