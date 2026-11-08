# Module 11 — Security and Portability

> *"The last step to becoming a professional: writing scripts that are not just correct, but **safe** and that **run anywhere**."*

**🌍 Idioma / Language:** [Português](README.md) · **English**

> 🌐 *Community translation. Spotted a slip or have a better wording? [Open an issue or PR](https://github.com/dsantos-docencia/Bash/issues) — see [traducoes/](../../traducoes/README.en.md).*

**Suggested time:** 6–8 h · **Level:** advanced · **Prerequisite:** [Module 10](../10-sistema-processos-rede/README.en.md)

## 🎯 Objectives

- Recognize and avoid the classic traps that destroy data
- Write **safe** scripts: validate input, avoid `eval`, use `mktemp`
- Understand command injection and how to prevent it
- Know the difference between Bash, POSIX `sh`, and zsh
- Write portable scripts when needed

This module is about **defense**: protecting the system from your own mistakes and protecting your script from malicious or unexpected input.

---

## 1. The classic traps (and how to escape them)

### 1.1 Spaces in file names

```bash
# ❌ breaks if a file has a space in its name:
for f in $(ls *.txt); do rm $f; done

# ✔ use a glob directly and quote:
for f in *.txt; do rm -- "$f"; done
```

### 1.2 `for f in $(ls)` — never

`ls` is for humans. For programs, use a glob or `find -print0`:
```bash
# ✔ names with any character, including newlines:
find . -name '*.log' -print0 | while IFS= read -r -d '' f; do
    echo "processing: $f"
done
```

### 1.3 `rm -rf` with an empty variable 🔥

```bash
# 🔥 if $DIR is empty, this becomes 'rm -rf /' !
rm -rf "$DIR/"

# ✔ layered protections:
set -u                              # an undefined variable aborts the script
dir="${DIR:?the DIR variable is required}"   # aborts with a message if empty
[[ -n "$dir" && -d "$dir" ]] || { echo "invalid dir" >&2; exit 1; }
rm -rf -- "$dir"
```

> 💡 The `--` says "no more options": it protects against files whose name starts with `-` (e.g., a file named `-rf`).

### 1.4 A `cd` that fails silently

```bash
# 🔥 if the cd fails, the following commands run in the WRONG folder:
cd "$dir"
rm -rf *

# ✔ stop if the cd fails:
cd "$dir" || exit 1
rm -rf -- *
```

### 1.5 Unquoted variables in `[ ]`

```bash
# ❌ breaks if $resposta is empty or has a space:
if [ $resposta = sim ]; then ...

# ✔ quote (or use [[ ]], which is safe):
if [[ "$resposta" == sim ]]; then ...
```

> 💡 [ShellCheck](../08-qualidade-e-testes/README.en.md) (Module 08) catches **all** these traps automatically. Always run it. And the full, canonical list is at [BashPitfalls](https://mywiki.wooledge.org/BashPitfalls).

## 2. Security in scripts

### 2.1 Never trust input without validating

Every input (arguments, environment variables, file contents, API responses) can be malicious or simply unexpected.

```bash
# Validate the format BEFORE using it:
[[ "$id" =~ ^[0-9]+$ ]]        || erro "id must be numeric"
[[ "$email" =~ ^[^@]+@[^@]+$ ]] || erro "invalid email"
[[ "$arquivo" != *..* ]]       || erro "suspicious path"   # avoids path traversal
```

### 2.2 Command injection — the #1 vulnerability

Interpolating user input inside a command is like SQL injection:

```bash
# 🔥 DANGEROUS: if the user types  ; rm -rf ~  that IS EXECUTED
nome="$1"
eval "echo Hello $nome"         # NEVER do this with external input

# 🔥 Also dangerous — building a command by string:
comando="ls $diretorio_do_usuario"
$comando                        # word splitting + glob on the input
```

```bash
# ✔ Treat data as DATA, not as code:
echo "Hello $nome"              # no eval; the variable is just text
ls -- "$diretorio_do_usuario"   # quoted, with --
```

> ⚠️ **Rule:** user input is **data**, never **code**. If you catch yourself building a command string with external data, stop and rethink.

### 2.3 Avoid `eval`

`eval` executes a string as code. 99% of the time there's a better alternative (arrays, nameref, `case`). When it seems unavoidable, the design can probably change.

```bash
# Instead of eval for a "dynamic variable":
eval "valor=\$$nome_da_var"        # fragile and dangerous
# use indirection:
valor="${!nome_da_var}"            # safe
# or associative arrays:
declare -A config; valor="${config[$chave]}"
```

### 2.4 Safe temporary files

```bash
# ❌ predictable: another process can guess/attack the name (race condition)
tmp="/tmp/meuscript.$$"

# ✔ mktemp creates a unique, unpredictable name, with restricted permissions:
tmp="$(mktemp)"                    # a file
tmpdir="$(mktemp -d)"              # a directory
trap 'rm -rf "$tmp" "$tmpdir"' EXIT
```

### 2.5 Least privilege and permissions

```bash
umask 077                          # new files only for the owner (rw-------)
chmod 600 "$arquivo_de_senha"      # restrict secrets
# Run as root only strictly what's needed; validate first:
[[ $EUID -eq 0 ]] && erro "don't run this script as root"
```

## 3. Bash vs. POSIX `sh` vs. zsh

| | Bash | POSIX `sh` (dash) | zsh |
|---|---|---|---|
| `[[ ]]`, `=~` | ✅ | ❌ | ✅ |
| Arrays | ✅ | ❌ | ✅ (but the index starts at **1**!) |
| `local` | ✅ | ❌ (use only variables) | ✅ |
| `<<<`, `<(...)` | ✅ | ❌ | ✅ |
| `${var^^}` | ✅ | ❌ | different |
| Ubiquity | very high | **universal** | medium |

> ⚠️ **Why it matters:** on many systems `/bin/sh` is **not** Bash (on Debian/Ubuntu it's `dash`, much leaner). A script with `#!/bin/sh` that uses `[[ ]]` or arrays **fails** on those systems. And on macOS, zsh has subtle differences (arrays start at 1).

## 4. Writing portable scripts (POSIX)

When the script needs to run on **any** Unix (Alpine containers, BSD, routers), write POSIX:

```sh
#!/bin/sh
# Portable: avoid Bash-only features

# Use [ ] instead of [[ ]], ALWAYS quoting:
if [ "$x" = "sim" ]; then ...; fi

# No arrays — use positional parameters or space-separated lists:
set -- item1 item2 item3
for i in "$@"; do echo "$i"; done

# No <<<; use a here-doc or echo | :
grep x <<EOF
$variavel
EOF
```

What to **avoid** for portability: `[[ ]]`, arrays, `local`, `<<<`, `<(...)`, `${var^^}`, `source` (use `.`), `function name {`.

```bash
# Check portability with ShellCheck pointing at the target shell:
shellcheck --shell=sh script.sh
set -o posix          # inside Bash, approximates POSIX behavior
```

> 💡 **Rule of thumb:** if the script is yours and runs in an environment you control (Linux servers with Bash) → use Bash and take advantage of `[[ ]]`, arrays, etc. If it needs to run anywhere (distributed, minimal containers) → write POSIX `sh` and validate with `shellcheck --shell=sh`.

---

## 🧪 Examples in this module

| File | Demonstrates |
|---|---|
| [01-armadilhas.sh](exemplos/01-armadilhas.sh) | The classic mistakes side by side with the safe version |
| [02-validar-entrada.sh](exemplos/02-validar-entrada.sh) | Validation and why input is data, not code |
| [03-portabilidade.sh](exemplos/03-portabilidade.sh) | The same goal in Bash and in POSIX sh |

## ⚠️ Module pitfalls

- `rm -rf "$DIR/"` with `$DIR` empty (use `set -u` + `${DIR:?}`)
- `eval` or `$comando` with user input (injection)
- A temporary file with a predictable name (use `mktemp`)
- `#!/bin/sh` using Bash features (fails on dash)
- Forgetting the `--` and a file named `-rf` becoming an option

## 🏋️ Exercises

See [exercicios/README.en.md](exercicios/README.en.md). Grade with `./ferramentas/corrigir.sh 11`.

## ✅ Mastery checklist

- [ ] I protect `rm -rf` with `set -u`, validation, and `--`
- [ ] I validate all input before using it; I treat data as data
- [ ] I avoid `eval`; I use indirection/arrays instead
- [ ] I create temporaries with `mktemp` + `trap`
- [ ] I know when to write Bash and when to write POSIX `sh`

---

⬅️ [Module 10](../10-sistema-processos-rede/README.en.md) · ➡️ [Practical projects](../../projetos/README.en.md) · [Reference](../../referencia/README.en.md)

<sub>© 2026 Prof. Daniel Santos and translators · Content [CC BY-NC-SA 4.0](../../LICENSE-CONTEUDO.md) · Code [PolyForm NC](../../LICENSE)</sub>
