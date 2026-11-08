#!/usr/bin/env bats
SOMA="${BATS_TEST_DIRNAME}/03-soma.sh"
@test "soma simples"    { run bash "$SOMA" 2 3;    [ "$output" = "5" ]; }
@test "com negativo"    { run bash "$SOMA" -2 5;   [ "$output" = "3" ]; }
@test "com zero"        { run bash "$SOMA" 0 0;    [ "$output" = "0" ]; }
