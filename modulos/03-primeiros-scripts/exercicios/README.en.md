# 🏋️ Exercises — Module 03

**🌍 Idioma / Language:** [Português](README.md) · **English**

> 🌐 *Community translation. Found a slip? [Open an issue or PR](https://github.com/dsantos-docencia/Bash/issues).*
>
> ⚠️ **The expected outputs below are kept in Portuguese on purpose** — the grader checks them literally.

Grade with `./ferramentas/corrigir.sh 03`. Solutions in [solucoes/](solucoes/).

### 01 — Greeting with an argument · `01-saudacao.sh`
Receives a name in `$1` and prints `Olá, NOME!`. If **no** argument is passed, print `Olá, visitante!` and finish normally (status 0). Hint: `${1:-visitante}`.

### 02 — Argument counter · `02-quantos.sh`
Prints exactly: `Você passou N argumento(s).` where N is the number received.

### 03 — Formatted receipt · `03-recibo.sh`
Receives a product in `$1` and a price in `$2` and prints, with `printf`, one line: the product left-aligned in **15 columns** (`%-15s`), then `R$ ` and the price with **width 6 and 2 decimals** (`%6.2f`):
```console
$ bash 03-recibo.sh Mel 4.5
Mel             R$   4.50
```
> Hint: `printf` counts **bytes**, so test with accent-free products to predict the alignment.

<sub>© 2026 Prof. Daniel Santos and translators · CC BY-NC-SA 4.0</sub>
