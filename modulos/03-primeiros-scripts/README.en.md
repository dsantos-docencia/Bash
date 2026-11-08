# Module 03 — First Scripts

> *"A script is just a sequence of commands you'd type in the terminal — saved to run as many times as you like."*

**🌍 Idioma / Language:** [Português](README.md) · **English**

> 🌐 *Community translation. Spotted a slip or have a better wording? [Open an issue or PR](https://github.com/dsantos-docencia/Bash/issues) — see [traducoes/](../../traducoes/README.en.md).*

**Suggested time:** 6–8 h · **Level:** beginner+ · **Prerequisite:** [Module 02](../02-fluxo-de-dados/README.en.md)

## 🎯 Objectives

- Write the correct anatomy of a script (shebang, permission, execution)
- Master **variables**: creation, referencing, environment vs. local
- Understand the topic that causes the most bugs in Bash: **quoting and expansions**
- Use the special variables (`$0`, `$1`, `$#`, `$@`, `$?`…)
- Interact: `echo`, `printf` (the professional one), and `read`

---

## 1. Anatomy of a script

```bash
#!/usr/bin/env bash          # 1. shebang: who runs this file
# Makes a quick backup       # 2. comments start with #
set -euo pipefail            # 3. safe mode (Module 07) — a good habit from the start
origem="$HOME/dados"         # 4. variables
echo "Backup of $origem"     # 5. commands, one per line
```

### The shebang: `#!/bin/bash` vs. `#!/usr/bin/env bash`

That first line tells the **kernel** which interpreter to use.

| Form | Meaning | When |
|---|---|---|
| `#!/bin/bash` | fixed path to Bash | you control the system and know it's there |
| `#!/usr/bin/env bash` | "find bash in the `PATH`" | **recommended** — works on macOS (Homebrew bash), BSDs, etc. |

> 💡 Why `env`? On macOS modern Bash lives in `/opt/homebrew/bin/bash`, not `/bin/bash`. `env` follows the `PATH` and finds the right version. This course always uses `#!/usr/bin/env bash`.

### Running: three ways (review from Module 00)

```bash
bash script.sh      # no +x needed; ignores the shebang; new process
chmod +x script.sh  # grants execute permission (once)
./script.sh         # uses the shebang; new process
source script.sh    # runs in the CURRENT shell (affects your variables)  — or: . script.sh
```

## 2. Variables

```bash
nome="Daniel"          # NO spaces around the = (nome = "x" is an ERROR)
idade=38
echo "$nome is $idade years old"
echo "${nome}Santos"   # braces when the name "sticks" to the following text
```

Rules:
- No spaces on the `=`. `x=1` ✔ · `x = 1` ✘ (the shell thinks `x` is a command).
- To **read**, use `$nome` or `${nome}`.
- Everything is **text** by default. `idade=38` stores the string "38"; arithmetic uses `(( ))` (Module 04).

### Environment vs. local variables

- **Local**: they exist only in the current shell.
- **Environment** (`export`): they are **inherited** by child processes.

```bash
cor="azul"              # local: only this shell knows it
export EDITOR="nano"    # environment: programs you open will inherit it
env | sort              # lists all the environment variables
printenv PATH           # shows a specific one
```

Famous environment variables: `PATH` (where to look for programs), `HOME`, `USER`, `PWD`, `LANG`, `SHELL`.

> 💡 Why `export PATH` matters: when you type `git`, the shell looks for an executable named `git` in each folder of the `PATH`, in order. `echo "$PATH"` shows the list, separated by `:`.

## 3. Quoting and expansions — the module's most important topic

Half of a beginner's Bash bugs are born here. Three behaviors:

| | Expands variables? (`$x`) | Expands commands? (`$(..)`) | Preserves spaces? |
|---|:---:|:---:|:---:|
| `"double quotes"` | ✅ yes | ✅ yes | ✅ yes |
| `'single quotes'` | ❌ no (literal) | ❌ no | ✅ yes |
| `no quotes` | ✅ yes | ✅ yes | ❌ **no** (splits into words) |

```bash
nome="Ana Paula"
echo "$nome"      # Ana Paula          ← one argument, correct
echo '$nome'      # $nome              ← literal
echo $nome        # Ana Paula          ← TWO arguments! (echo joins them, but...)
mkdir $nome       # creates TWO folders: "Ana" and "Paula"!  💥
mkdir "$nome"     # creates ONE folder: "Ana Paula"  ✔
```

> ⚠️ **The golden rule: always quote your variables.** `"$var"`, `"${array[@]}"`, `"$(command)"`. Without quotes, Bash does *word splitting* (splits on spaces) and *globbing* (expands `*`), causing bugs that only show up when a name has a space or a special character. ShellCheck (Module 08) warns about this religiously.

### Types of expansion (overview)

```bash
echo "$nome"                 # variable expansion
echo "$(date +%H:%M)"        # command substitution: runs it and inserts the output
echo "$((3 * 7))"            # arithmetic expansion → 21
echo "~/docs"                # ⚠️ inside quotes, ~ does NOT expand! use: "$HOME/docs"
echo ~/docs                  # /home/daniel/docs  (tilde only expands outside quotes)
```

> ⚠️ Command substitution: prefer `$(command)` to backticks `` `command` ``. Same thing, but `$(...)` nests cleanly: `$(echo $(date))`.

## 4. Special variables

Inside a script, Bash fills in automatically:

| Variable | Is |
|---|---|
| `$0` | the script's name |
| `$1`, `$2`, … `${10}` | 1st, 2nd, … arguments (from the 10th on, use braces) |
| `$#` | **how many** arguments came |
| `"$@"` | all arguments, **each** quoted ← almost always what you want |
| `"$*"` | all joined into a single string |
| `$?` | exit code of the **last** command (0 = success) |
| `$$` | PID of the script's process |
| `$!` | PID of the last command put in the background (`&`) |

```bash
#!/usr/bin/env bash
echo "Script: $0"
echo "I got $# arguments"
echo "The first is: $1"
echo "All: $@"
```
```console
$ ./exemplo.sh maçã banana
Script: ./exemplo.sh
I got 2 arguments
The first is: maçã
All: maçã banana
```

> ⚠️ **`"$@"` vs `"$*"`**: `"$@"` preserves the original separation of each argument; `"$*"` glues everything together. To pass arguments on to another command, it's **always** `"$@"`.

## 5. Output: `echo` and `printf`

```bash
echo "simple and direct"
echo -n "no newline at the end"
echo -e "with\tescape\tfor tab"        # -e enables \t \n etc. (not portable!)
```

For **serious** output (formatting, portability), use `printf`:

```bash
printf '%s is %d years old\n' "Daniel" 38      # Daniel is 38 years old
printf '%-10s %5.2f\n' "café" 4.5          # aligns: café       4.50
printf '%03d\n' 7                          # 007 (zero-padded)
printf '%x\n' 255                          # ff (hexadecimal)
```

> 💡 **Why `printf` > `echo` in scripts?** `echo` varies between systems (`-e` and `-n` don't always behave the same). `printf` is standardized, controls the format, and **repeats** the format for each extra argument. In professional scripts, prefer `printf`.

| Format | Produces |
|---|---|
| `%s` | string |
| `%d` | integer |
| `%f` | number with decimals (`%.2f` = 2 decimals) |
| `%x` | hexadecimal |
| `%-Ns` | left-aligned in N columns |
| `%0Nd` | integer with N digits, zero-padded |
| `\n` `\t` | newline, tab (always work in printf) |

## 6. Input: `read`

```bash
read -p "Your name: " nome          # -p shows a prompt
echo "Hello, $nome"

read -s -p "Password: " senha; echo # -s hides what's typed
read -t 5 -p "Quick! " resposta     # -t 5 gives up after 5 seconds
read -a palavras <<< "a b c"        # -a reads into an array (Module 06)
```

| Option | Does |
|---|---|
| `-p text` | shows a prompt |
| `-s` | silent (passwords) |
| `-t N` | timeout of N seconds |
| `-n N` | stops after N characters |
| `-r` | does **not** interpret `\` (almost always what you want) |
| `-a arr` | reads the fields into an array |

> ⚠️ Use **`read -r`** by default. Without `-r`, a `\` in the text is treated as an escape and disappears. ShellCheck warns (SC2162).

> 💡 Reading a file line by line (the correct pattern, Module 04): `while IFS= read -r linha; do ...; done < arquivo`.

---

## 🧪 Examples in this module

| File | Demonstrates |
|---|---|
| [01-argumentos.sh](exemplos/01-argumentos.sh) | `$0`, `$1`, `$#`, `"$@"` vs `"$*"` |
| [02-aspas.sh](exemplos/02-aspas.sh) | The real effect of double, single, and no quotes |
| [03-printf-vs-echo.sh](exemplos/03-printf-vs-echo.sh) | Formatting and why `printf` is more reliable |

## ⚠️ Module pitfalls

- A space on the `=`: `x = 1`
- Forgetting quotes and a name with a space becoming two arguments
- Using `"$*"` where you needed `"$@"`
- `read` without `-r` eating the backslashes
- Thinking `~` expands inside quotes (it doesn't — use `"$HOME"`)

## 🏋️ Exercises

See [exercicios/README.en.md](exercicios/README.en.md). Grade with `./ferramentas/corrigir.sh 03`.

## ✅ Mastery checklist

- [ ] I write the right shebang and know why `env`
- [ ] I quote **all** my variables by reflex
- [ ] I can explain the difference between `"$@"` and `"$*"`
- [ ] I use `printf` for formatted output
- [ ] I read input with `read -r` and handle prompt/password

---

⬅️ [Module 02](../02-fluxo-de-dados/README.en.md) · ➡️ [Module 04 — Control Flow](../04-controle-de-fluxo/README.en.md)

<sub>© 2026 Prof. Daniel Santos and translators · Content [CC BY-NC-SA 4.0](../../LICENSE-CONTEUDO.md) · Code [PolyForm NC](../../LICENSE)</sub>
