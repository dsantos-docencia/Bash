# 🏋️ Exercises — Module 07

**🌍 Idioma / Language:** [Português](README.md) · **English**

> 🌐 *Community translation. Found a slip? [Open an issue or PR](https://github.com/dsantos-docencia/Bash/issues).*
>
> ⚠️ **The expected outputs below are kept in Portuguese on purpose** — the grader checks them literally.

Grade with `./ferramentas/corrigir.sh 07`. Solutions in [solucoes/](solucoes/).

### 01 — Validate argument · `01-validar.sh`
Must require **exactly 1** argument. If none comes (or more than one), print to **stderr** `uso: 01-validar.sh <nome>` and finish with code **2**. If it comes correctly, print `Olá, NOME` to stdout and finish with 0.

### 02 — Safe division · `02-divisao.sh`
Receives two numbers (`$1` and `$2`) and prints `$1 / $2` (integer). If `$2` is `0`, print to stderr `erro: divisao por zero` and exit with code **1** (without crashing). Otherwise, print the result.

### 03 — Robust sum · `03-soma-robusta.sh`
With `set -euo pipefail` at the top, sum all the numeric arguments and print the total. **Watch the trap**: the increment/sum must not abort the script under `set -e`. E.g.: `bash 03-soma-robusta.sh 3 4 5` → `12`. No arguments → `0`.

<sub>© 2026 Prof. Daniel Santos and translators · CC BY-NC-SA 4.0</sub>
