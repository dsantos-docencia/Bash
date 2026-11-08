# Module 09 — Advanced Bash

> *"Here are the features that separate those who 'know Bash' from those who 'master Bash'. Rarely needed — but when they are, nothing else solves it so well."*

**🌍 Idioma / Language:** [Português](README.md) · **English**

> 🌐 *Community translation. Spotted a slip or have a better wording? [Open an issue or PR](https://github.com/dsantos-docencia/Bash/issues) — see [traducoes/](../../traducoes/README.en.md).*

**Suggested time:** 8–10 h · **Level:** advanced · **Prerequisite:** [Module 08](../08-qualidade-e-testes/README.en.md)

## 🎯 Objectives

- Understand subshells `( )` vs. grouping `{ }`
- Use **process substitution** `<(...)` and `>(...)`
- Master **here-documents** and **here-strings**
- Manipulate **file descriptors** (fd 3–9) directly
- Create **FIFOs** (named pipes) with `mkfifo`

---

## 1. Subshell `( )` vs. grouping `{ }`

Both group commands, but with a crucial difference in **environment**:

```bash
( cd /tmp; pwd )        # subshell: runs in a CHILD process
pwd                     # ← you're still in the original folder! the cd didn't "leak"

{ cd /tmp; pwd; }       # grouping: runs in the CURRENT shell
pwd                     # ← now you ARE in /tmp
```

| | `( ... )` | `{ ...; }` |
|---|---|---|
| Process | **new** (subshell) | the current one |
| `cd`, variables | stay contained | affect the shell |
| Syntax | parentheses | braces + **`;`** before `}` and internal spaces |
| Use | isolate effects | group redirections without isolating |

```bash
# Redirect the output of SEVERAL commands at once:
{ echo "header"; cat dados; echo "footer"; } > relatorio.txt
```

> 💡 Every time you use `$(...)` or a pipe, subshells are involved. That's why variables changed in there don't survive (the Module 06 trap).

## 2. Process substitution `<(...)` and `>(...)`

Turns a command's **output** into a temporary "file" that another command can read — without creating a real file.

```bash
# Compare the output of two commands without intermediate files:
diff <(ls dir1) <(ls dir2)

# Feed a 'while read' without the pipe's subshell (Module 06):
while read -r linha; do
    echo ">> $linha"
done < <(grep erro log.txt)          # note: < <(...) with a space

# >(...) sends output TO a command:
echo "message" > >(logger -t meuapp)
comando 2> >(grep -v ruido >&2)      # filters stderr live
```

> 💡 `<(cmd)` becomes a path like `/dev/fd/63` that holds `cmd`'s output. It's the elegant way to pass "command output" where a "file" is expected, and the correct way to avoid the `|` subshell in a `while read`.

## 3. Here-documents and here-strings

### Here-document `<<` — text blocks

```bash
cat <<FIM
Line 1
Current user: $USER         ← variables expand
Date: $(date +%F)           ← commands expand
FIM

cat <<'FIM'
Here NOTHING expands: $USER and $(date) come out literal.
(single quotes on the delimiter = raw text)
FIM

cat <<-FIM
	Leading tabs are removed (only TABs, not spaces),
	letting you indent the here-doc along with the code.
	FIM
```

| Form | Expands variables? | Use |
|---|---|---|
| `<<FIM` | ✅ yes | generating config/text with values |
| `<<'FIM'` | ❌ no (literal) | text that has real `$` (e.g., another script) |
| `<<-FIM` | depends | lets you indent with TABs |

Typical use: generating configuration files inside a script.
```bash
cat > /etc/meuapp.conf <<CONF
porta=$PORTA
log=/var/log/meuapp.log
CONF
```

### Here-string `<<<` — a single line

```bash
grep "x" <<< "$variavel"        # feeds stdin with the variable's content
read -ra campos <<< "a b c"     # splits a string
bc <<< "2 + 2"                  # 4
```

## 4. File descriptors (fd)

You already know 0 (stdin), 1 (stdout), 2 (stderr). Bash lets you open more (3 to 9) for advanced I/O.

```bash
exec 3> saida.log          # opens fd 3 for WRITING to the file
echo "only to the log" >&3 # writes via fd 3
exec 3>&-                  # closes fd 3

exec 4< entrada.txt        # opens fd 4 for READING
read -r linha <&4          # reads a line from fd 4
exec 4<&-                  # closes

# Swap/duplicate channels:
comando 3>&1 1>&2 2>&3 3>&-   # swaps stdout and stderr
```

> 💡 Extra descriptors are useful when you need to read from a file **and** interact with the user at the same time, or keep a log open throughout the script without reopening it on each write.

```bash
# Read a file line by line while keeping stdin free to prompt the user:
exec 3< lista.txt
while read -r item <&3; do
    read -rp "Process $item? [y/n] " resp   # uses normal stdin (keyboard)
    [[ "$resp" == y ]] && echo "ok: $item"
done
exec 3<&-
```

## 5. FIFOs (named pipes)

A pipe `|` is anonymous and disappears at the end of the command. A **FIFO** is a pipe with a **name** on the file system — two independent processes can communicate through it.

```bash
mkfifo /tmp/meu_cano            # creates the FIFO
# Terminal 1:
cat < /tmp/meu_cano            # blocks, waiting for data
# Terminal 2:
echo "hello through the pipe" > /tmp/meu_cano   # Terminal 1 receives and prints it
rm /tmp/meu_cano               # it's a file; remove it when done
```

Real use: decoupling a producer from a consumer, or implementing simple queues between scripts. Combine it with `trap ... EXIT` to remove the FIFO on exit.

---

## 🧪 Examples in this module

| File | Demonstrates |
|---|---|
| [01-subshell-vs-grupo.sh](exemplos/01-subshell-vs-grupo.sh) | `( )` isolates, `{ }` doesn't — effect on `cd` and variables |
| [02-process-substitution.sh](exemplos/02-process-substitution.sh) | `diff <(...) <(...)` and `while read < <(...)` |
| [03-heredoc-e-fd.sh](exemplos/03-heredoc-e-fd.sh) | Here-doc with/without expansion, here-string, and descriptors |

## ⚠️ Module pitfalls

- Forgetting the `;` before `}` in the grouping `{ ...; }`
- Confusing `( )` (isolates) with `{ }` (doesn't isolate) and losing a `cd`
- `< <(...)` without the space between `<` and `<(` (becomes a malformed here-doc)
- Leaving an orphan FIFO on disk (use `trap` to remove it)
- Forgetting to close descriptors (`exec 3>&-`)

## 🏋️ Exercises

See [exercicios/README.en.md](exercicios/README.en.md). Grade with `./ferramentas/corrigir.sh 09`.

## ✅ Mastery checklist

- [ ] I can explain when to use `( )` and when to use `{ }`
- [ ] I compare outputs with `diff <(...) <(...)`
- [ ] I generate a config file with a here-doc
- [ ] I open, use, and close an extra descriptor
- [ ] I know what a FIFO is and when to use it

---

⬅️ [Module 08](../08-qualidade-e-testes/README.en.md) · ➡️ [Module 10 — System, Processes, and Network](../10-sistema-processos-rede/README.en.md)

<sub>© 2026 Prof. Daniel Santos and translators · Content [CC BY-NC-SA 4.0](../../LICENSE-CONTEUDO.md) · Code [PolyForm NC](../../LICENSE)</sub>
