# Module 04 — Control Flow

> *"Up to here your scripts have been lists of commands. Now they gain the ability to **decide** and **repeat** — they become programs."*

**🌍 Idioma / Language:** [Português](README.md) · **English**

> 🌐 *Community translation. Spotted a slip or have a better wording? [Open an issue or PR](https://github.com/dsantos-docencia/Bash/issues) — see [traducoes/](../../traducoes/README.en.md).*

**Suggested time:** 8–10 h · **Level:** intermediate · **Prerequisite:** [Module 03](../03-primeiros-scripts/README.en.md)

## 🎯 Objectives

- Make decisions with `if`/`elif`/`else` and understand what's "true" in the shell
- Master `[[ ]]` and know why it's better than `[ ]`
- Use `case` for clean multi-option handling
- Repeat with `for`, `while`, `until`, and build menus with `select`
- Control loops with `break`, `continue`, and `shift`
- Read a file line by line **the right way**

---

## 1. What's "true" in Bash? (the exit code)

Here's the idea that confuses people coming from other languages: **Bash's `if` doesn't test `true`/`false` — it tests a command's exit code.**

Every command, when it finishes, returns a number from 0 to 255 (the `$?`):
- **0 = success** ("true")
- **≠ 0 = failure** ("false")

It's the **opposite** of the C/Python intuition (where 0 is false). Here, 0 is success because "there's one way to succeed and many to fail".

```bash
if comando; then
    echo "the command finished with 0 (success)"
else
    echo "the command finished with a code ≠ 0"
fi
```

```bash
if grep -q "erro" log.txt; then      # grep -q exits 0 if it FOUND something
    echo "found errors in the log"
fi

if ping -c1 -W1 8.8.8.8 &>/dev/null; then
    echo "there's internet"
fi
```

> 💡 There's no boolean type. `if [[ ... ]]` works because `[[ ]]` **is a command** that exits 0 (true) or 1 (false).

## 2. `if`, `elif`, `else`

```bash
if condição; then
    comandos
elif outra; then
    comandos
else
    comandos
fi                      # 'if' backwards closes the block
```

### `[ ]` vs `[[ ]]` vs `test`

`[` is literally a **command** (a synonym for `test`); that's why it needs spaces and is fragile. `[[ ]]` is a Bash **reserved word**, safer and more powerful.

```bash
[ "$x" = "sim" ]        # POSIX, works in sh, but fragile without quotes
[[ $x == "sim" ]]       # Bash: safer (no word splitting), supports == with glob and =~
```

| Feature | `[ ]` | `[[ ]]` |
|---|:---:|:---:|
| Portable to `sh` | ✅ | ❌ (Bash/ksh/zsh only) |
| Safe without quotes | ❌ | ✅ |
| Internal `&&` `\|\|` | ❌ | ✅ |
| `==` with glob, `=~` regex | ❌ | ✅ |

> 👉 **In this course we use `[[ ]]`.** We only fall back to `[ ]` when the goal is POSIX portability (Module 11).

### The tests (summary — full table in [referencia/tabela-testes.md](../../referencia/tabela-testes.md))

```bash
# Files
[[ -e cam ]]  # exists     [[ -f cam ]]  # is a file     [[ -d cam ]]  # is a directory
[[ -r cam ]]  # readable   [[ -s cam ]]  # non-empty
# Strings
[[ -z "$s" ]] # empty      [[ -n "$s" ]] # non-empty
[[ "$a" == "$b" ]]         [[ "$a" != "$b" ]]
[[ "$s" =~ ^[0-9]+$ ]]     # matches regex (digits only)
# Numbers (prefer (( )) )
(( a > b ))   (( a == b ))   [[ "$a" -gt "$b" ]]
```

### Logical operators

```bash
if [[ -f "$arq" && -r "$arq" ]]; then ...           # inside the [[ ]]
if comando1 && comando2; then ...                   # between commands
comando && echo "it worked"                         # only runs if the 1st succeeded
comando || echo "it failed"                         # only runs if the 1st failed
mkdir -p "$dir" || exit 1                            # classic idiom: "or die"
```

## 3. `case` — when there are many options

```bash
case "$1" in
    start)            echo "starting" ;;
    stop)             echo "stopping" ;;
    restart|reload)   echo "restarting" ;;     # | = "or"
    *.txt)            echo "it's a text file" ;;   # glob patterns!
    [0-9])            echo "a digit" ;;
    *)                echo "unknown option"; exit 1 ;;   # * = anything
esac
```

Cleaner than an `elif` ladder when comparing **one** variable against several patterns. The patterns are **globs** (as in Module 02), not regex.

## 4. Loops

### `for` — over a list

```bash
for fruta in maçã banana abacaxi; do
    echo "fruit: $fruta"
done

for arq in *.txt; do          # iterates over files (glob)
    echo "processing $arq"
done

for i in {1..5}; do           # sequence
    echo "step $i"
done
```

### C-style `for` — when you need a counter

```bash
for (( i=0; i<10; i++ )); do
    echo "i = $i"
done
```

### `while` and `until`

```bash
contador=0
while (( contador < 3 )); do          # while the condition is true
    echo "counter = $contador"
    (( contador++ ))
done

until ping -c1 servidor &>/dev/null; do    # until the condition becomes true
    echo "waiting for the server..."
    sleep 2
done
```

### Reading a file line by line — **the right way**

```bash
while IFS= read -r linha; do
    echo "line: $linha"
done < arquivo.txt
```

> ⚠️ This idiom has three details that **everyone** gets wrong at first:
> - `IFS=` (empty) prevents leading/trailing spaces on the line from being trimmed.
> - `read -r` prevents `\` from being interpreted.
> - `< arquivo` at the **end** of `done` — the file feeds the whole loop.
>
> ❌ **Never** use `for linha in $(cat arquivo)`: it breaks on spaces and expands globs. It's [BashPitfall #1](https://mywiki.wooledge.org/BashPitfalls). See example 03.

### `select` — a quick interactive menu

```bash
select opcao in "Backup" "Restaurar" "Sair"; do
    case "$opcao" in
        Backup)    echo "backing up"; break ;;
        Restaurar) echo "restoring"; break ;;
        Sair)      break ;;
        *)         echo "invalid option" ;;
    esac
done
```

## 5. `break`, `continue`, and `shift`

```bash
for i in {1..10}; do
    (( i == 5 )) && continue    # skips 5
    (( i == 8 )) && break       # stops at 8
    echo "$i"
done
# prints 1 2 3 4 6 7
```

`shift` "discards" the first positional argument, shifting the rest — useful for processing arguments one at a time:

```bash
while (( $# > 0 )); do
    echo "processing: $1"
    shift                       # $2 becomes $1, $3 becomes $2...
done
```

---

## 🧪 Examples in this module

| File | Demonstrates |
|---|---|
| [01-if-e-testes.sh](exemplos/01-if-e-testes.sh) | Exit code as "truth", file/string/number tests |
| [02-case-e-loops.sh](exemplos/02-case-e-loops.sh) | `case`, `for` (list, glob, C), `while`, `break`/`continue` |
| [03-ler-arquivo.sh](exemplos/03-ler-arquivo.sh) | The RIGHT way (`while read`) vs. the wrong one (`for ... $(cat)`) |

## ⚠️ Module pitfalls

- `for linha in $(cat arq)` — breaks on spaces and expands globs
- Forgetting the `;;` at the end of a `case` branch
- Comparing numbers with `<`/`>` in `[[ ]]` (there it's alphabetical order!) instead of `-lt`/`(( ))`
- `while ... | read var` losing the variable (the pipe's subshell — Module 06)
- Thinking `if` tests a boolean (it tests the **exit code**)

## 🏋️ Exercises

See [exercicios/README.en.md](exercicios/README.en.md). Grade with `./ferramentas/corrigir.sh 04`.

## ✅ Mastery checklist

- [ ] I can explain why 0 is "true" in the shell
- [ ] I choose `[[ ]]` and know when to fall back to `[ ]`
- [ ] I use `case` with glob patterns
- [ ] I read files with `while IFS= read -r`
- [ ] I control loops with `break`/`continue` and arguments with `shift`

---

⬅️ [Module 03](../03-primeiros-scripts/README.en.md) · ➡️ [Module 05 — Text and Data](../05-texto-e-dados/README.en.md)

<sub>© 2026 Prof. Daniel Santos and translators · Content [CC BY-NC-SA 4.0](../../LICENSE-CONTEUDO.md) · Code [PolyForm NC](../../LICENSE)</sub>
