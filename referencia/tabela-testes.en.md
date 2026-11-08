# ✅ Conditional tests table

**🌍 Idioma / Language:** [Português](tabela-testes.md) · **English**

Operators for `[[ ... ]]` (strings/files) and `(( ... ))` (numbers). See [Module 04](../modulos/04-controle-de-fluxo/README.en.md).

## Files

| Test | True if… |
|---|---|
| `-e arq` | exists (any type) |
| `-f arq` | exists and is a regular file |
| `-d arq` | exists and is a directory |
| `-L arq` | is a symbolic link |
| `-r` / `-w` / `-x` | you can read / write / execute |
| `-s arq` | exists and is **not** empty |
| `arq1 -nt arq2` | arq1 newer than arq2 (*newer than*) |
| `arq1 -ot arq2` | arq1 older (*older than*) |
| `arq1 -ef arq2` | same file (same inode) |

## Strings (inside `[[ ]]`)

| Test | True if… |
|---|---|
| `-z "$s"` | **empty** string (zero) |
| `-n "$s"` | **non**-empty string |
| `"$a" == "$b"` | equal (with `[[ ]]`, the right side can be a glob pattern!) |
| `"$a" == "$b"` with quotes on `$b` | equal, literal comparison |
| `"$a" != "$b"` | not equal |
| `"$a" < "$b"` | `a` comes before alphabetically |
| `"$a" =~ regex` | matches the regular expression (ERE) |

> ⚠️ In `[[ $x == a* ]]` the `a*` is a **glob** (starts with a). To compare literally, quote it: `[[ $x == "a*" ]]`. For regex use `=~` **without** quotes on the pattern.

## Numbers (use `(( ))` or the `-eq` operators in `[[ ]]`)

| In `(( ))` | In `[[ ]]` / `[ ]` | Meaning |
|---|---|---|
| `==` | `-eq` | equal |
| `!=` | `-ne` | not equal |
| `<` | `-lt` | less |
| `<=` | `-le` | less or equal |
| `>` | `-gt` | greater |
| `>=` | `-ge` | greater or equal |

```bash
(( idade >= 18 ))         # preferred for numbers
[[ "$n" -gt 10 ]]         # also works
```

## Combining

| In `[[ ]]` | Meaning |
|---|---|
| `&&` | AND |
| `\|\|` | OR |
| `!` | NOT |
| `( ... )` | grouping |

```bash
[[ -f "$arq" && -r "$arq" ]]        # exists AND is readable
[[ -z "$x" || "$x" == "sair" ]]     # empty OR equal to "sair"
(( a > 0 && a < 100 ))
```

## `[ ]` vs `[[ ]]` vs `test`

| | `[ ]` / `test` | `[[ ]]` |
|---|---|---|
| Standard | POSIX, portable to `sh` | Bash/ksh/zsh only |
| Unquoted variables | **dangerous** (breaks on spaces/empty) | safe |
| `&&` `\|\|` inside | no (use `-a`/`-o`, fragile) | yes |
| `==` with glob, `=~` regex | no | **yes** |
| Recommendation | only for portable `sh` scripts | **the default in Bash** |

<sub>© 2026 Prof. Daniel Santos and translators · CC BY-NC-SA 4.0</sub>
