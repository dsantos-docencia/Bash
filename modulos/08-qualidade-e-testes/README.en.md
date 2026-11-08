# Module 08 — Quality and Testing

> *"Code without tests is code you're afraid to change. And nobody automates what they're afraid to touch."*

**🌍 Idioma / Language:** [Português](README.md) · **English**

> 🌐 *Community translation. Spotted a slip or have a better wording? [Open an issue or PR](https://github.com/dsantos-docencia/Bash/issues) — see [traducoes/](../../traducoes/README.en.md).*

**Suggested time:** 5–7 h · **Level:** intermediate+ · **Prerequisite:** [Module 07](../07-scripts-robustos/README.en.md)

## 🎯 Objectives

- Use **ShellCheck** to catch bugs before running
- Process arguments professionally with **`getopts`**
- Write automated tests with **Bats** (the industry standard)
- Adopt a consistent style and document scripts

---

## 1. ShellCheck — your tireless reviewer

[ShellCheck](https://www.shellcheck.net) is a static analyzer: it reads your script and flags bugs, bad practices, and traps — **without running anything**. It's the tool that most accelerates learning Bash.

```bash
shellcheck meu-script.sh            # analyzes and lists the problems, with explanations
shellcheck -S warning script.sh     # only warnings and errors (ignores 'info')
shellcheck -x script.sh             # follows 'source'd files
```

Example of what it catches:
```bash
# You write:
rm -rf $DIR/arquivo
# ShellCheck warns (SC2086): "Double quote to prevent globbing and word splitting"
# → correct: rm -rf "$DIR/arquivo"
```

| Code | Means |
|---|---|
| SC2086 | unquoted variable (the classic) |
| SC2164 | `cd` without `|| exit` |
| SC2046 | `$(...)` without quotes |
| SC2006 | used backticks instead of `$(...)` |
| SC2162 | `read` without `-r` |

> 💡 **Integrate it with the editor.** In VS Code, the ShellCheck extension underlines the problems as you type. It's like having a Bash teacher looking over your shoulder. Install locally: `apt install shellcheck` / `brew install shellcheck`.

### Silencing a warning (with justification)

When you **know** what you're doing, disable it locally — always with a comment saying why:

```bash
# shellcheck disable=SC2086  # we want the word splitting here
comando $argumentos_intencionalmente_sem_aspas
```

> ⚠️ This very repository runs ShellCheck on **all** scripts via CI. See [`ferramentas/verificar-tudo.sh`](../../ferramentas/verificar-tudo.sh).

## 2. `getopts` — command-line options the grown-up way

Serious scripts accept options (`-v`, `-o arquivo`, `--help`). `getopts` (builtin) does the heavy lifting in a standardized way:

```bash
#!/usr/bin/env bash
set -euo pipefail

verboso=0
saida=""

# The string "vo:h" means: -v and -h are flags; -o expects an ARGUMENT (the :)
while getopts "vo:h" opt; do
    case "$opt" in
        v) verboso=1 ;;
        o) saida="$OPTARG" ;;        # OPTARG holds the option's value
        h) echo "usage: $0 [-v] [-o file]"; exit 0 ;;
        *) echo "invalid option" >&2; exit 2 ;;
    esac
done
shift $(( OPTIND - 1 ))              # discards the options already read; args remain

echo "verboso=$verboso saida=$saida rest=$*"
```

```console
$ ./script.sh -v -o log.txt arquivo1 arquivo2
verboso=1 saida=log.txt rest=arquivo1 arquivo2
```

- The option string: a lone letter = flag; a letter with `:` = requires an argument (in `$OPTARG`).
- `OPTIND` points to the next argument; `shift $((OPTIND-1))` leaves only the "real" arguments.

> 💡 `getopts` (builtin, with an "s") handles only short options (`-v`). For long options (`--verbose`), you either handle them manually in a `while`/`case`, or use `getopt` (external program, without the "s") — but the builtin covers most cases with portability.

## 3. Bats — real automated tests

[Bats](https://github.com/bats-core/bats-core) (*Bash Automated Testing System*) is the standard framework for testing Bash scripts. (This course uses its own mini-framework in the exercises — read [`ferramentas/lib/teste.sh`](../../ferramentas/lib/teste.sh) — but **Bats is what you use at work**.)

### Installing

```bash
# Debian/Ubuntu
sudo apt install bats
# macOS
brew install bats-core
# npm
npm install -g bats
```

### Writing a test

A `.bats` file is a script with a special syntax. Each `@test` is a case:

```bash
#!/usr/bin/env bats

@test "adds two numbers" {
    run bash soma.sh 2 3
    [ "$status" -eq 0 ]
    [ "$output" = "5" ]
}

@test "fails with no arguments" {
    run bash soma.sh
    [ "$status" -ne 0 ]
}
```

- `run comando` executes it and captures `$status` (exit code) and `$output` (output).
- Each `@test` passes if **all** the commands inside it succeed (Bats uses `set -e` internally).
- `[ ... ]` are the assertions (the same tests from Module 04).

```bash
bats soma.bats          # runs the tests
# ✓ adds two numbers
# ✓ fails with no arguments
# 2 tests, 0 failures
```

### `setup` and `teardown`

```bash
setup() {
    TMP="$(mktemp -d)"           # runs before EACH test
}
teardown() {
    rm -rf "$TMP"                # runs after EACH test
}

@test "creates the output file" {
    run bash gera.sh "$TMP/out.txt"
    [ -f "$TMP/out.txt" ]
}
```

See the example [`exemplos/calculadora.bats`](exemplos/calculadora.bats) running against [`exemplos/calculadora.sh`](exemplos/calculadora.sh).

## 4. Style and documentation

- Follow a consistent guide (the [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html) is a great base).
- A **header** on every script: name, usage, author.
- Functions with a comment stating inputs and outputs.
- Descriptive names; `snake_case` for variables and functions.
- `readonly`/`declare -r` for constants.
- A `uso()`/`help()` function that documents and serves `-h`.

```bash
#!/usr/bin/env bash
#
# backup.sh — compresses a directory with the date in the name
# Usage: backup.sh [-o destination] <directory>
#
set -euo pipefail
readonly VERSAO="1.0.0"
```

---

## 🧪 Examples in this module

| File | Demonstrates |
|---|---|
| [calculadora.sh](exemplos/calculadora.sh) | A script with `getopts`, validation, and `uso()` |
| [calculadora.bats](exemplos/calculadora.bats) | Bats tests for the calculator (if `bats` is installed) |
| [01-getopts.sh](exemplos/01-getopts.sh) | Processing `-v -o file -h` options step by step |

> Run the Bats tests with: `bats modulos/08-qualidade-e-testes/exemplos/calculadora.bats`
> (automatically skipped in the course verification if `bats` isn't installed).

## ⚠️ Module pitfalls

- Ignoring ShellCheck warnings "because it works" (until the day it doesn't)
- Forgetting `shift $((OPTIND-1))` and processing options as arguments
- A test that depends on state left by another test (use `setup`/`teardown`)
- Testing only the happy path — also test errors and edges

## 🏋️ Exercises

See [exercicios/README.en.md](exercicios/README.en.md). Grade with `./ferramentas/corrigir.sh 08`.

## ✅ Mastery checklist

- [ ] I run ShellCheck and understand the most common SC codes
- [ ] I process options with `getopts` and `shift $((OPTIND-1))`
- [ ] I write a Bats test with `run`, `$status`, and `$output`
- [ ] I use `setup`/`teardown` to isolate tests
- [ ] I document the usage and offer `-h`

---

⬅️ [Module 07](../07-scripts-robustos/README.en.md) · ➡️ [Module 09 — Advanced Bash](../09-bash-avancado/README.en.md)

<sub>© 2026 Prof. Daniel Santos and translators · Content [CC BY-NC-SA 4.0](../../LICENSE-CONTEUDO.md) · Code [PolyForm NC](../../LICENSE)</sub>
