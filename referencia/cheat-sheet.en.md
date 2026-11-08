# 🎴 Bash Cheat Sheet

**🌍 Idioma / Language:** [Português](cheat-sheet.md) · **English**

A quick pocket reference. For the why of each item, see the indicated module.

## Variables and expansions — Modules 03, 05

```bash
nome="valor"              # no spaces around the =
echo "$nome" "${nome}"    # reference; braces when adjacent: "${nome}_x"
nome=$(comando)           # command output becomes a value
readonly PI=3.14          # constant
unset nome                # deletes the variable
```

| Parameter expansion | Result |
|---|---|
| `${var:-padrão}` | `var`, or "padrão" if empty/unset |
| `${var:=padrão}` | same, and **assigns** the default to `var` |
| `${var:?msg}` | error with "msg" if empty/unset |
| `${var:+alt}` | "alt" if `var` **has** a value |
| `${#var}` | length |
| `${var#pre}` / `${var##pre}` | removes the shortest/longest prefix matching `pre` |
| `${var%suf}` / `${var%%suf}` | removes the shortest/longest suffix |
| `${var/a/b}` / `${var//a/b}` | replaces 1st / all occurrences |
| `${var^^}` / `${var,,}` | UPPERCASE / lowercase |
| `${var:offset:tam}` | slice (substring) |

## Special variables — Module 03

| Var | Meaning |
|---|---|
| `$0` | the script's name |
| `$1`…`$9`, `${10}` | positional arguments |
| `$#` | number of arguments |
| `"$@"` | all arguments, **each** quoted (almost always the right one) |
| `"$*"` | all joined into a single string |
| `$?` | exit code of the last command |
| `$$` | the script's PID |
| `$!` | PID of the last background command |

## Tests — Module 04

```bash
[[ -e arq ]]   # exists        [[ -f arq ]]  # is a regular file
[[ -d dir ]]   # is a directory [[ -r/-w/-x ]]# read./writ./exec.
[[ -s arq ]]   # exists and non-empty
[[ -z "$s" ]]  # empty string  [[ -n "$s" ]] # non-empty string
[[ "$a" == "$b" ]]  [[ "$a" != "$b" ]]   [[ "$a" < "$b" ]]  # alphabetical order
[[ "$a" =~ ^re+gex$ ]]            # matches regex (ERE)
(( a == b ))  (( a < b ))  (( a++ ))     # arithmetic and numeric comparison
```

Numeric in `[[ ]]`/`[ ]`: `-eq -ne -lt -le -gt -ge`. Logical: `&&` `||` `!`.

## Conditionals and loops — Module 04

```bash
if comando; then ...; elif outro; then ...; else ...; fi

case "$x" in
    a|b) ... ;;
    *)   ... ;;     # default
esac

for i in a b c; do ...; done
for ((i=0; i<10; i++)); do ...; done
while comando; do ...; done
until comando; do ...; done
while IFS= read -r linha; do ...; done < arquivo   # read a file line by line
```
`break` exits the loop · `continue` skips to the next iteration.

## Functions — Module 06

```bash
minha_func() {
    local x="$1"           # 'local' prevents leaking outside
    echo "resultado"       # "returns" a value via stdout
    return 0               # returns an EXIT CODE (0–255)
}
valor=$(minha_func arg)
```

## Arrays — Module 06

```bash
arr=(a b c)                # indexed
arr[3]="d";  arr+=("e")    # assign / append
"${arr[0]}"  "${arr[@]}"   # element / all
"${#arr[@]}" "${!arr[@]}"  # count / indices

declare -A mapa            # associative
mapa[chave]="valor"
"${mapa[chave]}"  "${!mapa[@]}"  "${mapa[@]}"
```

## Redirection and pipes — Module 02

```bash
cmd > arq        # stdout overwrites          cmd >> arq   # appends
cmd < arq        # stdin comes from the file
cmd 2> err       # stderr to a file
cmd > tudo 2>&1  # stdout and stderr together
cmd &> tudo      # same (Bash shortcut)
cmd 2>/dev/null  # discards errors
a | b | c        # pipe: one's stdout becomes the next's stdin
cmd | tee arq    # see on screen AND save
```

## Robust mode — Module 07

```bash
set -euo pipefail          # error stops the script; undefined variable is an error; pipe failure propagates
trap 'rm -rf "$tmp"' EXIT  # guaranteed cleanup on exit
tmp=$(mktemp -d)           # safe temporary directory
```

## Advanced — Modules 09–10

```bash
<(cmd)   >(cmd)            # process substitution (virtual file)
cmd <<EOF ... EOF          # here-document
cmd <<< "texto"           # here-string
exec 3< arq               # opens descriptor 3 for reading
cmd &                     # runs in the background
jobs; fg %1; bg %1; wait  # job control
kill -TERM "$pid"         # sends a signal
timeout 10 cmd            # kills it if it exceeds 10s
```

---
See also: [tabela-testes.md](tabela-testes.en.md) · [tabela-expansoes.md](tabela-expansoes.en.md) · [tabela-sinais.md](tabela-sinais.en.md)

<sub>© 2026 Prof. Daniel Santos and translators · CC BY-NC-SA 4.0</sub>
