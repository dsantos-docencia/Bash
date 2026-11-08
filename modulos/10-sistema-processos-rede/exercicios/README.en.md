# 🏋️ Exercises — Module 10

**🌍 Idioma / Language:** [Português](README.md) · **English**

> 🌐 *Community translation. Found a slip? [Open an issue or PR](https://github.com/dsantos-docencia/Bash/issues).*
>
> ⚠️ **The expected outputs below are kept in Portuguese on purpose** — the grader checks them literally.

Grade with `./ferramentas/corrigir.sh 10`. Solutions in [solucoes/](solucoes/).

### 01 — Run in parallel · `01-paralelo.sh`
Receives N numbers in `$@`, each representing seconds. It should run `sleep` for each one **in parallel** and, at the end (after `wait`), print `concluido: N` (N = the count). The total time should be ~the longest sleep, not the sum. (The test uses small values.)

### 02 — Validate a cron expression · `02-valida-cron.sh`
Receives a string in `$1` and prints `ok` if it has **exactly 5 fields** separated by spaces (doesn't validate the values, just the count), otherwise `invalido` with status 1. Hint: turn it into an array with `read -ra` and check `${#campos[@]}`.

### 03 — Simulate the cron environment · `03-precisa-path.sh`
Write a script that depends on a correct PATH: it should print the output of `seq 1 3` (one per line). The goal is for it to work even when called via `env -i PATH=/usr/bin:/bin bash 03-precisa-path.sh`. Hint: don't depend on anything exotic; `seq` is in /usr/bin.

<sub>© 2026 Prof. Daniel Santos and translators · CC BY-NC-SA 4.0</sub>
