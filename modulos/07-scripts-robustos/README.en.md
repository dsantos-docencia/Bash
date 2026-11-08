# Module 07 — Robust Scripts

> *"The difference between a script and a tool is what happens when something goes wrong. Production is where fragile scripts go to die."*

**🌍 Idioma / Language:** [Português](README.md) · **English**

> 🌐 *Community translation. Spotted a slip or have a better wording? [Open an issue or PR](https://github.com/dsantos-docencia/Bash/issues) — see [traducoes/](../../traducoes/README.en.md).*

**Suggested time:** 6–8 h · **Level:** intermediate+ · **Prerequisite:** [Module 06](../06-arrays-e-funcoes/README.en.md)

## 🎯 Objectives

- Use exit codes with meaning
- Understand and apply `set -euo pipefail` (and know when **not** to use it)
- Catch signals and clean up resources with `trap`
- Debug scripts with `set -x`, `PS4`, and logging
- Write the "safety header" every serious script has

---

## 1. Exit codes

Every command returns a number (0–255) accessible in `$?`. **0 = success**, the rest = error.

```bash
grep "x" arquivo
echo "$?"            # 0 if found, 1 if not found, 2 if a usage error
```

In your script, return codes with meaning:

```bash
exit 0      # success
exit 1      # generic error
exit 2      # usage error (wrong arguments) — common convention
exit 127    # "command not found" (the shell uses this one)
```

> 💡 Convention: codes 1–125 are yours; 126 (not executable), 127 (not found), 128+N (killed by signal N) are reserved by the shell. Document yours in the header.

```bash
if ! comando_critico; then
    echo "error: comando_critico failed" >&2   # errors go to stderr!
    exit 1
fi
```

## 2. The "strict mode": `set -euo pipefail`

Three options that turn silent failures into visible stops. It's the start of almost every professional script.

```bash
set -euo pipefail
```

| Option | Does | Protects against |
|---|---|---|
| `set -e` (errexit) | aborts if a command returns ≠ 0 | continuing after a serious error |
| `set -u` (nounset) | aborts on using an undefined variable | `rm -rf "$DIR/"` with `$DIR` empty, and typos |
| `set -o pipefail` | a pipe fails if **any** part fails | `cmd_que_falha \| tee log` hiding the error |

```bash
#!/usr/bin/env bash
set -euo pipefail

arquivo="$1"           # with set -u, if no $1 comes, the script stops right here
processar "$arquivo"   # with set -e, if 'processar' fails, it stops here
```

### ⚠️ `set -e` has traps — know the main ones

`set -e` is useful, but it has treacherous corners:

```bash
# 1. Commands under test do NOT abort (-e is suspended in if/while/&&/||):
if comando_que_falha; then ...; fi      # ok, doesn't abort

# 2. This does NOT abort even on error (the && "handles" the status):
comando_que_falha && echo "ok"

# 3. Functions and 'local' mask the status:
x=$(local v=$(cmd_que_falha))           # the 'local' swallows the error

# 4. Counters can take you down:
contador=0
(( contador++ ))        # returns 0 (value BEFORE), status 1 → ABORTS with set -e! 💥
(( ++contador ))        # pre-increment returns 1, status 0 → safe
```

> 💡 That's why some prefer **not** to use `set -e` and to check errors explicitly with `|| { ... }`. A balanced rule: use `set -euo pipefail` as the default, but know these traps and handle commands that "may fail on purpose" with `|| true` or inside `if`.

```bash
comando_que_pode_falhar || true     # "I don't want this to abort the script"
```

## 3. `trap` — catch signals and clean up

`trap` registers a command to run when a signal arrives or the script ends. The #1 use: **guaranteeing cleanup** (temporary files, locks) no matter what.

```bash
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT          # runs on EXIT, for any reason
# ... use $tmp freely; it'll be deleted even if the script fails or is killed
```

| Signal / event | Fires when… |
|---|---|
| `EXIT` | the script ends (success, error, or `exit`) — **the most used** |
| `ERR` | a command fails (with `set -e`) |
| `INT` | Ctrl+C |
| `TERM` | default `kill` |
| `HUP` | the terminal closed |

```bash
limpar() {
    echo "cleaning up resources..." >&2
    rm -f "$lock"
}
trap limpar EXIT INT TERM           # one cleanup function for several events

trap 'echo "got Ctrl+C, exiting"; exit 130' INT
```

> 💡 Put the `trap ... EXIT` **right after** creating the temporary resource, not at the end of the script. That way, if something fails in the middle, the cleanup is already registered. (The full table of signals is in [referencia/tabela-sinais.md](../../referencia/tabela-sinais.md).)

## 4. Debugging

```bash
bash -x script.sh          # shows each command BEFORE running it (trace)
bash -n script.sh          # only checks the syntax, without running
set -x; comando; set +x    # turns tracing on only for a suspicious snippet
```

Customize the trace prefix with `PS4` to see **where** you are:

```bash
export PS4='+ ${BASH_SOURCE}:${LINENO}: '   # shows file:line at each step
bash -x script.sh
```

A simple, effective technique — "printf debugging" aimed at stderr:
```bash
depurar() { [[ "${DEBUG:-}" == 1 ]] && echo "DEBUG: $*" >&2; }
depurar "value of x = $x"        # only appears if you run with DEBUG=1 ./script
```

## 5. Logging with a timestamp

```bash
log() {
    printf '%(%Y-%m-%d %H:%M:%S)T [%s] %s\n' -1 "${1}" "${2}" >&2
}
log INFO "starting backup"
log ERRO "disk full"
```

Or use the system's `logger` (goes to syslog/journald):
```bash
logger -t meu-script "backup complete"     # appears in journalctl -t meu-script
```

Redirect the whole script to a log, keeping the screen:
```bash
exec > >(tee -a /var/log/meu-script.log) 2>&1   # everything goes to screen AND file
```

## 6. The standard safety header

Start every serious script like this:

```bash
#!/usr/bin/env bash
#
# script-name — what it does
# Usage: script-name [options] <argument>
#
set -euo pipefail

# Fail with a message and a code
erro() { echo "error: $*" >&2; exit 1; }

# Guaranteed cleanup
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

# Input validation
[[ $# -ge 1 ]] || erro "usage: $0 <file>"
[[ -f "$1" ]]  || erro "file not found: $1"

# ... the real work ...
```

---

## 🧪 Examples in this module

| File | Demonstrates |
|---|---|
| [01-modo-estrito.sh](exemplos/01-modo-estrito.sh) | The effect of `set -e`, `set -u`, `pipefail` (and the `(( ))` trap) |
| [02-trap-limpeza.sh](exemplos/02-trap-limpeza.sh) | `trap ... EXIT` guaranteeing cleanup even after an error |
| [03-logging-e-debug.sh](exemplos/03-logging-e-debug.sh) | A log function with a timestamp and conditional debugging via `DEBUG` |

## ⚠️ Module pitfalls

- `(( contador++ ))` aborting the script under `set -e` (use `|| true` or `++contador`)
- Sending errors to stdout instead of stderr (`>&2`)
- Forgetting the `trap` and leaving temporary garbage (or stuck locks)
- Thinking `set -e` catches **every** error (it doesn't in `if`, `&&`, a `$()` subshell)
- `set -u` taking the script down on a missing `$1` without a clear message (validate first)

## 🏋️ Exercises

See [exercicios/README.en.md](exercicios/README.en.md). Grade with `./ferramentas/corrigir.sh 07`.

## ✅ Mastery checklist

- [ ] I write the safety header from memory
- [ ] I can explain each letter of `set -euo pipefail` and its traps
- [ ] I use `trap ... EXIT` for cleanup right after creating the resource
- [ ] I send errors to stderr and use exit codes with meaning
- [ ] I debug with `bash -x` and `PS4`

---

⬅️ [Module 06](../06-arrays-e-funcoes/README.en.md) · ➡️ [Module 08 — Quality and Testing](../08-qualidade-e-testes/README.en.md)

<sub>© 2026 Prof. Daniel Santos and translators · Content [CC BY-NC-SA 4.0](../../LICENSE-CONTEUDO.md) · Code [PolyForm NC](../../LICENSE)</sub>
