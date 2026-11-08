# 🔧 Parameter expansion table

**🌍 Idioma / Language:** [Português](tabela-expansoes.md) · **English**

"Parameter expansion" is Bash's superpower for manipulating strings **without calling external programs** (no `sed`/`cut` for simple things). See [Module 05](../modulos/05-texto-e-dados/README.en.md).

Base for the examples: `arquivo="/home/daniel/foto.backup.jpg"` · `vazia=""` · `nome="Daniel Santos"`

## Default values

| Expansion | What it does | Example → result |
|---|---|---|
| `${v:-pad}` | uses `pad` if `v` is empty/unset (doesn't change `v`) | `${vazia:-sem nome}` → `sem nome` |
| `${v:=pad}` | same **and assigns** `pad` to `v` | `${vazia:=X}` → `X` (and now `vazia=X`) |
| `${v:?msg}` | aborts with error `msg` if empty/unset | `${vazia:?faltou}` → error |
| `${v:+alt}` | uses `alt` **if** `v` has a value | `${nome:+ok}` → `ok` |

## Length and slices

| Expansion | Result |
|---|---|
| `${#nome}` | `14` (number of characters) |
| `${nome:0:6}` | `Daniel` (from index 0, 6 chars) |
| `${nome:7}` | `Santos` (from index 7 to the end) |
| `${nome: -6}` | `Santos` (space before the `-`: last 6) |

## Remove prefix / suffix (great for paths)

| Expansion | Removes | Example → result |
|---|---|---|
| `${arquivo#*/}` | **shortest** prefix matching `*/` | `home/daniel/foto.backup.jpg` |
| `${arquivo##*/}` | **longest** prefix — becomes the **basename** | `foto.backup.jpg` |
| `${arquivo%.*}` | **shortest** `.*` suffix — drops the last extension | `/home/daniel/foto.backup` |
| `${arquivo%%.*}` | **longest** suffix — drops **all** extensions | `/home/daniel/foto` |
| `${arquivo%/*}` | drops from the last `/` — becomes the **dirname** | `/home/daniel` |

> 💡 Mnemonic: `#` is on the **left** of the `$` on the keyboard (works on the **start**); `%` is on the **right** (works on the **end**). Doubling the symbol = greedy (matches the maximum).

## Replace

| Expansion | What it does |
|---|---|
| `${v/a/b}` | replaces the **first** occurrence of `a` with `b` |
| `${v//a/b}` | replaces **all** |
| `${v/#a/b}` | replaces only if `a` is at the **start** |
| `${v/%a/b}` | replaces only if `a` is at the **end** |
| `${v//a/}` | **removes** all occurrences of `a` |

## Upper / lower case (Bash 4+)

| Expansion | Result for `nome="Daniel Santos"` |
|---|---|
| `${nome^^}` | `DANIEL SANTOS` |
| `${nome,,}` | `daniel santos` |
| `${nome^}` | `Daniel Santos` (first letter only) |
| `${nome,}` | `daniel Santos` |

## Indirection and listing

| Expansion | What it does |
|---|---|
| `${!prefixo*}` | names of variables starting with `prefixo` |
| `ref=nome; ${!ref}` | value of the variable **whose name** is in `ref` (indirection) |

## Practical example: swap extension

```bash
arq="relatorio.txt"
echo "${arq%.txt}.pdf"      # relatorio.pdf  (no sed!)

caminho="/var/log/sys.log"
echo "${caminho##*/}"       # sys.log   (basename)
echo "${caminho%/*}"        # /var/log  (dirname)
nome="${caminho##*/}"; echo "${nome%.*}"   # sys  (no folder, no extension)
```

<sub>© 2026 Prof. Daniel Santos and translators · CC BY-NC-SA 4.0</sub>
