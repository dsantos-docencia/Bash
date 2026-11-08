# 🏋️ Exercises — Module 04

**🌍 Idioma / Language:** [Português](README.md) · **English**

> 🌐 *Community translation. Found a slip? [Open an issue or PR](https://github.com/dsantos-docencia/Bash/issues).*
>
> ⚠️ **The expected outputs below are kept in Portuguese on purpose** — the grader checks them literally.

Grade with `./ferramentas/corrigir.sh 04`. Solutions in [solucoes/](solucoes/).

### 01 — Even or odd · `01-par-ou-impar.sh`
Receives an integer in `$1` and prints `par` (even) or `impar` (odd). Hint: `(( n % 2 == 0 ))`.

### 02 — Grade classifier · `02-classificar-nota.sh`
Receives a grade (0 to 10) in `$1` and prints the letter, using `if/elif`:
- `>= 9` → `A`
- `>= 7` → `B`
- `>= 5` → `C`
- else → `D`

### 03 — FizzBuzz · `03-fizzbuzz.sh`
Prints the numbers from 1 to `$1` (one per line). Multiples of 3 become `Fizz`, of 5 become `Buzz`, of both become `FizzBuzz`. A classic that exercises loop + conditional.
```console
$ bash 03-fizzbuzz.sh 5
1
2
Fizz
4
Buzz
```

<sub>© 2026 Prof. Daniel Santos and translators · CC BY-NC-SA 4.0</sub>
