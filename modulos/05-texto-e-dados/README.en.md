# Module 05 — Text and Data Manipulation

> *"In Unix, data is text, and text is where Bash shines. Logs, CSVs, configs — it's all a stream of characters waiting to be filtered."*

**🌍 Idioma / Language:** [Português](README.md) · **English**

> 🌐 *Community translation. Spotted a slip or have a better wording? [Open an issue or PR](https://github.com/dsantos-docencia/Bash/issues) — see [traducoes/](../../traducoes/README.en.md).*

**Suggested time:** 10–12 h · **Level:** intermediate · **Prerequisite:** [Module 04](../04-controle-de-fluxo/README.en.md)

## 🎯 Objectives

- Master the **golden trio**: `grep`, `sed`, `awk`
- Use regular expressions (ERE/PCRE) safely
- Slice and assemble text with `cut`, `paste`, `tr`, `sort`, `uniq`, `wc`
- Do string manipulation **without leaving Bash** (parameter expansion)
- Know **when** to use each tool (performance and readability)

---

## 1. Regular expressions in 5 minutes

A regex describes a **pattern** of text. It's another language, different from the shell's glob.

| Pattern | Matches |
|---|---|
| `.` | any **one** character |
| `*` | zero or more of the **previous** |
| `+` | one or more (ERE) |
| `?` | zero or one (ERE) |
| `^` | start of the line |
| `$` | end of the line |
| `[abc]` | one of a, b, c |
| `[^abc]` | one that is **not** a, b, c |
| `[0-9]` | a digit |
| `\{2,5\}` / `{2,5}` | 2 to 5 repetitions (BRE / ERE) |
| `\|` / `\|` | "or" alternative (ERE) |
| `( )` | grouping (ERE) |

> ⚠️ There are **two dialects**: BRE (basic, the default in `grep`/`sed`, requires `\` before `+ ? { } ( ) |`) and ERE (extended, with `grep -E`/`sed -E`, no backslashes). **Tip:** always use `-E`; the syntax is much cleaner.

```bash
grep -E '^[0-9]{3}-[0-9]{4}$' contatos   # lines that are exactly 123-4567
grep -E 'erro|falha|warn'      log        # any of the three words
```

## 2. `grep` — find lines

```bash
grep "texto" arquivo          # lines that contain "texto"
grep -i "erro" log            # ignores upper/lowercase
grep -v "debug" log           # INVERTS: lines that do NOT contain
grep -n "TODO" *.sh           # shows the line number
grep -r "função" src/         # recursive in directories
grep -c "erro" log            # just counts how many lines matched
grep -o 'https://[^ ]*' pág   # prints only the PART that matched
grep -E 'cat|dog' arq         # extended regex
grep -q "x" arq && echo found # -q: silent, just the exit code (for if)
```

| Option | Does |
|---|---|
| `-i` | ignores case |
| `-v` | inverts (doesn't match) |
| `-n` | line number |
| `-r` / `-R` | recursive |
| `-c` | counts lines |
| `-o` | only the matched piece |
| `-E` | extended regex (ERE) |
| `-q` | quiet (to use in `if`) |
| `-w` | whole word |

## 3. `sed` — stream editor (substitute and edit)

`sed` transforms text that passes through it. The most common use (95%) is substitution:

```bash
sed 's/antigo/novo/'  arq     # replaces the 1st occurrence per line
sed 's/antigo/novo/g' arq     # g = all occurrences on the line
sed 's/erro/ERRO/gi'  arq     # g=all, i=ignore case
sed -n '10,20p'       arq     # -n silences everything; p prints only lines 10–20
sed '/debug/d'        arq     # deletes (d) lines matching /debug/
sed -E 's/([0-9]+)/[\1]/g'    # \1 = what the 1st group () captured
sed -i 's/v1/v2/g'    arq     # -i edits the file IN PLACE (careful!)
sed -i.bak 's/v1/v2/g' arq    # -i.bak edits and keeps a backup arq.bak
```

> ⚠️ `sed -i` **changes the file** without asking for confirmation. Always test without `-i` first (seeing the result on screen), and prefer `-i.bak` for a safety net.

> 💡 The `s///` separator doesn't have to be `/`. To work on paths, use another: `sed 's#/usr/local#/opt#g'` — avoids escaping each slash.

## 4. `awk` — process columns and reports

`awk` is a whole language, but 90% of use is: "for each line, do something with the columns". It splits each line into fields `$1`, `$2`, … (`$0` is the whole line).

```bash
awk '{print $1}'            arq   # 1st column of each line
awk '{print $1, $3}'       arq   # 1st and 3rd (the comma becomes a space)
awk -F: '{print $1}'  /etc/passwd # -F: uses ":" as the separator
awk '$3 > 100'             arq   # lines whose 3rd column is > 100
awk 'NR==1 {print}'        arq   # NR = line number (only the 1st)
awk 'END {print NR}'       arq   # at the end, prints the total number of lines
awk '{soma += $2} END {print soma}' arq   # sums the 2nd column
awk -F, '{print $2}'       dados.csv       # simple CSV
```

| awk variable | Is |
|---|---|
| `$1`, `$2`… | fields (columns) |
| `$0` | the whole line |
| `NF` | number of fields on the line |
| `NR` | current line number |
| `FS` / `-F` | field separator (input) |
| `BEGIN{}` / `END{}` | block before / after processing everything |

> 💡 **grep vs sed vs awk — which to use?**
> - **grep**: I just want to *filter* lines (find/exclude). The fastest.
> - **sed**: I want to *transform* text (substitute, delete lines).
> - **awk**: I want to work with *columns*, *compute*, generate a *report*.
> To sum a column of a large file, `awk` is far faster and more readable than a `while read` in Bash.

## 5. The supporting utilities

```bash
cut -d: -f1 /etc/passwd       # cuts: delimiter ":", field 1
cut -c1-10 arq                # characters 1 to 10 of each line
sort arq                      # sorts (alphabetical)
sort -n arq                   # numeric
sort -rn arq                  # numeric reverse
sort -u arq                   # sorts and removes duplicates
uniq arq                      # removes ADJACENT duplicates (needs sort first)
uniq -c arq                   # counts occurrences
tr 'a-z' 'A-Z' < arq          # translates characters (lower → upper)
tr -d ' ' < arq               # deletes characters (removes spaces)
tr -s ' ' < arq               # "squeeze": collapses repeated spaces
paste a.txt b.txt             # joins files side by side (columns)
tee arq                       # copies stdin to the screen AND to arq
wc -l arq                     # counts lines (-w words, -c bytes)
```

The classic ranking combo (you saw it in Module 02):
```bash
cut -d' ' -f1 acesso.log | sort | uniq -c | sort -rn | head
```

## 6. **Native** string manipulation (without calling programs)

For simple operations, Bash's parameter expansion is faster than calling `sed`/`cut` (no process created). Full table in [referencia/tabela-expansoes.md](../../referencia/tabela-expansoes.md).

```bash
arq="/home/daniel/foto.jpg"
echo "${arq##*/}"      # foto.jpg      (basename — removes the longest prefix up to /)
echo "${arq%/*}"       # /home/daniel  (dirname — removes from the last / to the end)
echo "${arq%.jpg}.png" # swaps extension → /home/daniel/foto.png
echo "${#arq}"         # length

texto="Olá Mundo"
echo "${texto^^}"      # OLÁ MUNDO
echo "${texto,,}"      # olá mundo
echo "${texto/Mundo/Bash}"   # Olá Bash
echo "${texto:4:5}"    # slice from index 4
```

> 💡 Rule of thumb: **one simple replacement in a value** → parameter expansion. **Transforming a whole stream/file** → `sed`/`awk`. Don't call `echo "$x" | sed ...` for something `${x/.../...}` solves.

## 7. Advanced globbing (`shopt`)

```bash
shopt -s nullglob     # a glob with no match becomes EMPTY (instead of literal)
shopt -s dotglob      # * now includes hidden files (.something)
shopt -s globstar     # ** matches recursively: **/*.sh
shopt -s extglob      # enables extended patterns: ?(..) *(..) +(..) @(..) !(..)
```

```bash
shopt -s globstar
for f in **/*.sh; do echo "$f"; done   # all the .sh in the whole tree
```

---

## 🧪 Examples in this module

| File | Demonstrates |
|---|---|
| [01-grep-sed-awk.sh](exemplos/01-grep-sed-awk.sh) | The golden trio solving the same log from three angles |
| [02-relatorio-csv.sh](exemplos/02-relatorio-csv.sh) | `awk` generating a report from a CSV |
| [03-strings-nativas.sh](exemplos/03-strings-nativas.sh) | Parameter expansion vs. calling `sed`/`cut` |

## ⚠️ Module pitfalls

- Mixing regex dialects (BRE vs ERE) — prefer `-E` always
- `uniq` without `sort` first (it only removes **adjacent** duplicates)
- `sed -i` without a backup destroying a file
- Calling `sed`/`awk` for something `${var/.../...}` does natively
- Forgetting `shopt -s nullglob` and a glob becoming literal text

## 🏋️ Exercises

See [exercicios/README.en.md](exercicios/README.en.md). Grade with `./ferramentas/corrigir.sh 05`.

## ✅ Mastery checklist

- [ ] I write a simple ERE regex (anchors, classes, quantifiers)
- [ ] I choose between grep/sed/awk by the type of task
- [ ] I make a report summing a column with `awk`
- [ ] I extract basename/dirname/extension with parameter expansion
- [ ] I use `shopt` when I need to (nullglob, globstar)

---

⬅️ [Module 04](../04-controle-de-fluxo/README.en.md) · ➡️ [Module 06 — Arrays and Functions](../06-arrays-e-funcoes/README.en.md)

<sub>© 2026 Prof. Daniel Santos and translators · Content [CC BY-NC-SA 4.0](../../LICENSE-CONTEUDO.md) · Code [PolyForm NC](../../LICENSE)</sub>
