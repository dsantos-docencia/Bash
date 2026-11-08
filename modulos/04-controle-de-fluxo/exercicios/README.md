# 🏋️ Exercícios — Módulo 04

Corrija com `./ferramentas/corrigir.sh 04`. Soluções em [solucoes/](solucoes/).

### 01 — Par ou ímpar · `01-par-ou-impar.sh`
Recebe um número inteiro em `$1` e imprime `par` ou `impar`. Dica: `(( n % 2 == 0 ))`.

### 02 — Classificar nota · `02-classificar-nota.sh`
Recebe uma nota (0 a 10) em `$1` e imprime o conceito, usando `if/elif`:
- `>= 9` → `A`
- `>= 7` → `B`
- `>= 5` → `C`
- senão → `D`

### 03 — FizzBuzz · `03-fizzbuzz.sh`
Imprime os números de 1 a `$1` (um por linha). Múltiplos de 3 viram `Fizz`, de 5 viram `Buzz`, de ambos viram `FizzBuzz`. Clássico que exercita laço + condicional.
```console
$ bash 03-fizzbuzz.sh 5
1
2
Fizz
4
Buzz
```
