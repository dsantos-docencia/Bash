# 🏋️ Exercises — Module 08

**🌍 Idioma / Language:** [Português](README.md) · **English**

> 🌐 *Community translation. Found a slip? [Open an issue or PR](https://github.com/dsantos-docencia/Bash/issues).*
>
> ⚠️ **The expected outputs below are kept in Portuguese on purpose** — the grader checks them literally.

Grade with `./ferramentas/corrigir.sh 08`. Solutions in [solucoes/](solucoes/).

### 01 — Options with getopts · `01-saudacao-opts.sh`
Accept the options:
- `-n NOME` → name to greet (default: `mundo`)
- `-u` → output in UPPERCASE
- `-h` → prints `uso: ...` and exits with 0

Behavior:
```console
$ bash 01-saudacao-opts.sh            → Oi, mundo
$ bash 01-saudacao-opts.sh -n Ana     → Oi, Ana
$ bash 01-saudacao-opts.sh -u -n Ana  → OI, ANA
```

### 02 — CPF validator (format) · `02-valida-formato.sh`
Receives a string in `$1` and prints `valido` if it matches the format `000.000.000-00` (format only, not the check digit), otherwise `invalido` with status 1. Use `[[ =~ ]]`. (`CPF` is the Brazilian taxpayer ID.)

### 03 — Writing a test · `03-soma.bats` (+ `03-soma.sh`)
We've provided `03-soma.sh` (adds two numbers). **Complete** the Bats test file `03-soma.bats` with at least 2 cases. (This exercise is checked by inspecting/running bats, not by the automatic grader.)

<sub>© 2026 Prof. Daniel Santos and translators · CC BY-NC-SA 4.0</sub>
