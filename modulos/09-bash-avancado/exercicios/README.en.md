# 🏋️ Exercises — Module 09

**🌍 Idioma / Language:** [Português](README.md) · **English**

> 🌐 *Community translation. Found a slip? [Open an issue or PR](https://github.com/dsantos-docencia/Bash/issues).*
>
> ⚠️ **The expected outputs below are kept in Portuguese on purpose** — the grader checks them literally.

Grade with `./ferramentas/corrigir.sh 09`. Solutions in [solucoes/](solucoes/).

### 01 — Config via here-doc · `01-gerar-config.sh`
Receives a service name in `$1` and a port in `$2`. Using a **here-doc**, print to stdout exactly:
```
[servico]
nome=NOME
porta=PORTA
```

### 02 — Sum via process substitution · `02-somar-seq.sh`
Receives a number `N` in `$1` and prints the sum from `1` to `N`, reading from `seq` with a `while read` fed by **process substitution** (`< <(...)`), without using a pipe. E.g.: `bash 02-somar-seq.sh 10` → `55`.

### 03 — Compare lists · `03-comparar.sh`
Receives two files (`$1`, `$2`) and prints `iguais` if they have the same sorted content, or `diferentes` (status 1) otherwise. Use `diff <(sort ...) <(sort ...)`.

<sub>© 2026 Prof. Daniel Santos and translators · CC BY-NC-SA 4.0</sub>
