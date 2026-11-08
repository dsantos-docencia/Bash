# Module 06 — Arrays and Functions

> *"Once a script passes 50 lines, functions stop being a luxury and become a necessity. And arrays are how you store lists without resorting to hacks with strings."*

**🌍 Idioma / Language:** [Português](README.md) · **English**

> 🌐 *Community translation. Spotted a slip or have a better wording? [Open an issue or PR](https://github.com/dsantos-docencia/Bash/issues) — see [traducoes/](../../traducoes/README.en.md).*

**Suggested time:** 6–8 h · **Level:** intermediate · **Prerequisite:** [Module 05](../05-texto-e-dados/README.en.md)

## 🎯 Objectives

- Use **indexed arrays** and **associative arrays** (dictionaries)
- Write **functions** with parameters, return, and correct scope (`local`)
- Understand why `echo x | read var` doesn't work (the subshell problem)
- Organize large scripts into small, testable functions

---

## 1. Indexed arrays

An array stores several values under a single name, accessed by a numeric index (starts at **0**).

```bash
frutas=(maçã banana abacaxi)      # creates
frutas[3]="manga"                 # assigns a position
frutas+=(uva pera)                # appends at the end

echo "${frutas[0]}"               # maçã   (one element — braces required!)
echo "${frutas[@]}"               # all elements
echo "${#frutas[@]}"              # the number of elements
echo "${!frutas[@]}"              # 0 1 2 3 4 5 → the indices
echo "${frutas[@]:1:2}"           # slice: 2 elements starting at index 1
```

> ⚠️ **Always `"${arr[@]}"` with quotes and `@`.** Without quotes, elements with spaces break apart. With `*` instead of `@`, everything becomes a single string. The correct form to iterate while preserving each element is `for x in "${arr[@]}"`.

```bash
for f in "${frutas[@]}"; do
    echo "fruit: $f"
done
```

### Filling arrays from commands

```bash
mapfile -t linhas < arquivo.txt       # each line becomes an element (no \n)
# or:  readarray -t linhas < arquivo.txt   (it's the same command)

arquivos=( *.txt )                    # a glob directly into an array
IFS=',' read -ra campos <<< "a,b,c"   # splits a string by comma
```

> 💡 `mapfile -t` is the **correct** way to read a file into an array (the `-t` removes the newline from each element). Forget `arr=($(cat arquivo))`, which breaks on spaces.

## 2. Associative arrays (dictionaries)

Keys are strings, not numbers. They must be **declared** with `declare -A`.

```bash
declare -A idade                  # REQUIRED to declare first
idade[ana]=30
idade[bia]=25
idade["caio silva"]=40            # key with a space, ok

echo "${idade[ana]}"              # 30
echo "${!idade[@]}"               # the keys: ana bia "caio silva"
echo "${idade[@]}"               # the values: 30 25 40
echo "${#idage[@]}"              # ⚠️ a typo won't warn you! (careful)

for chave in "${!idade[@]}"; do
    echo "$chave is ${idade[$chave]} years old"
done
```

> 💡 Associative arrays are perfect for **counting** (histograms) and **mapping** (from → to). The report example in Module 05 (`awk`) has an equivalent in pure Bash with `declare -A`.

## 3. Functions

```bash
# Two equivalent syntaxes:
saudar() { echo "Hello, $1"; }
function saudar { echo "Hello, $1"; }     # 'function' style (less portable)

saudar "Daniel"                          # call: arguments as in a script
```

Inside the function, the parameters are `$1`, `$2`, `$#`, `"$@"` — **just like a script**. There's no declared "signature"; you receive whatever comes.

### Return: `return` (code) vs. `echo` (value)

This is the part that confuses people coming from other languages:

```bash
# return gives back an EXIT CODE (0–255), not a value!
eh_par() {
    (( $1 % 2 == 0 ))      # the expression itself sets the exit code
}
if eh_par 4; then echo "even"; fi

# To "return" a VALUE, print to stdout and capture with $(...)
dobro() {
    echo $(( $1 * 2 ))
}
resultado=$(dobro 21)     # resultado=42
```

| To return… | Use | Capture with |
|---|---|---|
| success/failure (0–255) | `return N` | `if funcao; then` / `$?` |
| a value (text/number) | `echo`/`printf` | `var=$(funcao)` |

### Scope: `local` is almost mandatory

By default, **all variables are global** in Bash — even inside functions. That causes silent bugs. Use `local`:

```bash
contador() {
    local i                   # 'i' exists only inside the function
    for (( i=0; i<3; i++ )); do echo "$i"; done
}
i="important"
contador
echo "$i"                     # still "important" — the function didn't clobber it
```

> ⚠️ **Without `local`, an `i` variable inside a function overwrites the `i` outside.** In large scripts this becomes a debugging nightmare. Rule: **every** internal function variable is `local`.

> 💡 Idiom for "returning by reference" (avoids a subshell): pass the **name** of a variable and use `local -n` (nameref, Bash 4.3+):
> ```bash
> preencher() { local -n ref=$1; ref="value"; }
> preencher resultado; echo "$resultado"
> ```

## 4. The subshell trap (pipe + while/read)

One of Bash's most famous bugs:

```bash
contador=0
echo -e "a\nb\nc" | while read -r linha; do
    (( contador++ ))           # increments... but in a SUBSHELL
done
echo "$contador"               # prints 0!  😱
```

**Why?** Each side of a `|` runs in a separate **subshell**. The `while` changes `contador` inside the subshell, which dies at the end of the pipe, taking the change with it.

**Solutions:**
```bash
# 1. Redirect instead of piping (no subshell):
contador=0
while read -r linha; do (( contador++ )); done < <(echo -e "a\nb\nc")
echo "$contador"               # 3 ✔   (the < <(...) is "process substitution", Module 09)

# 2. Read from a file/here-string:
while read -r linha; do (( contador++ )); done <<< $'a\nb\nc'
```

## 5. Function best practices

- **Small**: one function, one responsibility.
- **Clear names**: `validar_email`, not `check`.
- **`local` on everything**: no variable leakage.
- **Document**: a comment saying what goes in (`$1`, `$2`) and what comes out.
- **Return early**: `[[ -z "$1" ]] && return 1` at the top avoids nesting.

```bash
# Validates a CEP in the format 00000-000. Returns 0 if valid.
validar_cep() {
    local cep="$1"
    [[ "$cep" =~ ^[0-9]{5}-[0-9]{3}$ ]]
}
```

---

## 🧪 Examples in this module

| File | Demonstrates |
|---|---|
| [01-arrays.sh](exemplos/01-arrays.sh) | Indexed and associative: create, iterate, count, slice |
| [02-funcoes.sh](exemplos/02-funcoes.sh) | Parameters, `return` vs `echo`, `local`, nameref |
| [03-armadilha-subshell.sh](exemplos/03-armadilha-subshell.sh) | The `pipe \| while read` bug and the two solutions |

## ⚠️ Module pitfalls

- `${arr[@]}` without quotes breaking elements with spaces
- Forgetting `declare -A` on an associative array (it becomes indexed!)
- Confusing `return` (code) with "returning a value" (that's `echo`)
- Not using `local` and a function clobbering an outside variable
- `cmd | while read` and losing the changes (subshell)

## 🏋️ Exercises

See [exercicios/README.en.md](exercicios/README.en.md). Grade with `./ferramentas/corrigir.sh 06`.

## ✅ Mastery checklist

- [ ] I iterate an array with `for x in "${arr[@]}"`
- [ ] I use `declare -A` and count occurrences with an associative array
- [ ] I know when to use `return` and when to use `echo` in a function
- [ ] I mark internal variables as `local` by reflex
- [ ] I can explain why `cmd | while read var` loses `var`

---

⬅️ [Module 05](../05-texto-e-dados/README.en.md) · ➡️ [Module 07 — Robust Scripts](../07-scripts-robustos/README.en.md)

<sub>© 2026 Prof. Daniel Santos and translators · Content [CC BY-NC-SA 4.0](../../LICENSE-CONTEUDO.md) · Code [PolyForm NC](../../LICENSE)</sub>
