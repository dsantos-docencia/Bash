# 🏋️ Exercises — Module 05

**🌍 Idioma / Language:** [Português](README.md) · **English**

> 🌐 *Community translation. Found a slip? [Open an issue or PR](https://github.com/dsantos-docencia/Bash/issues).*
>
> ⚠️ **The expected outputs/formats below are kept in Portuguese on purpose** — the grader checks them literally.

Grade with `./ferramentas/corrigir.sh 05`. Solutions in [solucoes/](solucoes/).

### 01 — Extract emails · `01-extrair-emails.sh`
Receives a file in `$1` and prints **only the email addresses** that appear in it, one per line. Use `grep -oE`. A sufficient pattern: `[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]+`.

### 02 — Sum a column · `02-somar-coluna.sh`
Receives a file with numbers in the **2nd column** (space-separated) in `$1` and prints the integer sum. Use `awk`.

### 03 — Swap extension · `03-trocar-extensao.sh`
Receives a path in `$1` and prints the same path with the extension swapped to `.bak`, using **parameter expansion** (no sed/awk). E.g.: `/a/b/c.txt` → `/a/b/c.bak`. Assume there's exactly one extension.

<sub>© 2026 Prof. Daniel Santos and translators · CC BY-NC-SA 4.0</sub>
