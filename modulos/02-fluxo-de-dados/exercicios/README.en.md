# 🏋️ Exercises — Module 02

**🌍 Idioma / Language:** [Português](README.md) · **English**

> 🌐 *Community translation. Found a slip? [Open an issue or PR](https://github.com/dsantos-docencia/Bash/issues).*
>
> ⚠️ **The expected outputs below are kept in Portuguese on purpose** — the grader checks them literally.

Grade with `./ferramentas/corrigir.sh 02`. Solutions in [solucoes/](solucoes/).

### 01 — Only the errors · `01-so-os-erros.sh`
The script runs a command that talks on both channels. Make it print **only** the **stderr** content of the command below (discard stdout). Use the provided internal command:
```bash
gerar() { echo "resultado bom"; echo "deu ruim" >&2; }
```
Expected output:
```
deu ruim
```

### 02 — Top 3 words · `02-top-palavras.sh`
Receives a text file in `$1` and prints the **3 most frequent words**, one per line, from most to least frequent, **only the word** (without the count). Treat words as separated by spaces; you don't need to handle punctuation. Hint: `tr ' ' '\n' | sort | uniq -c | sort -rn`.

### 03 — Batch create · `03-criar-lote.sh`
Using **brace expansion**, create in the current directory the files `nota-01.md` through `nota-05.md` and print how many `.md` files now exist:
```
5
```

<sub>© 2026 Prof. Daniel Santos and translators · CC BY-NC-SA 4.0</sub>
