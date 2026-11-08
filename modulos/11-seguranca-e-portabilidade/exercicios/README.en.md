# 🏋️ Exercises — Module 11

**🌍 Idioma / Language:** [Português](README.md) · **English**

> 🌐 *Community translation. Found a slip? [Open an issue or PR](https://github.com/dsantos-docencia/Bash/issues).*
>
> ⚠️ **The expected outputs below are kept in Portuguese on purpose** — the grader checks them literally.

Grade with `./ferramentas/corrigir.sh 11`. Solutions in [solucoes/](solucoes/).

### 01 — Safe removal · `01-remocao-segura.sh`
Receives a path in `$1`. It must **refuse** (print `recusado` to stderr and exit with 1) if the argument is missing/empty, is `/`, or contains `..`. Otherwise, print `ok: removeria CAMINHO` (don't actually remove anything — it's a validation exercise).
```console
$ bash 01-remocao-segura.sh /tmp/x   → ok: removeria /tmp/x
$ bash 01-remocao-segura.sh ""       → (stderr) recusado   [status 1]
$ bash 01-remocao-segura.sh /        → (stderr) recusado   [status 1]
$ bash 01-remocao-segura.sh ../etc   → (stderr) recusado   [status 1]
```

### 02 — Validate integer · `02-so-inteiro.sh`
Receives `$1` and prints `numero` if it's an integer (with an optional sign), otherwise `nao` with status 1. Use `[[ =~ ]]` with the correct anchor (without using external programs).

### 03 — Normalize to uppercase (portable) · `03-maiusc-portavel.sh`
Receives `$1` and prints it in UPPERCASE **without** using `${var^^}` (which isn't POSIX) — use `tr`. That way the script would work even in `#!/bin/sh`. E.g.: `bash 03-maiusc-portavel.sh bash` → `BASH`.

<sub>© 2026 Prof. Daniel Santos and translators · CC BY-NC-SA 4.0</sub>
