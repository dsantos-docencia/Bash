# 🏋️ Exercises — Module 01

**🌍 Idioma / Language:** [Português](README.md) · **English**

> 🌐 *Community translation. Found a slip? [Open an issue or PR](https://github.com/dsantos-docencia/Bash/issues).*
>
> ⚠️ **The expected outputs below are kept in Portuguese on purpose** — the grader checks them literally.

Grade with `./ferramentas/corrigir.sh 01`. Commented solutions in [solucoes/](solucoes/).

### 01 — Count by type · `01-contar-tipos.sh`
The script receives **one directory** as `$1` and prints **two lines**, exactly:
```
arquivos: N
diretorios: M
```
where N is the number of regular files and M the number of directories **inside** it (recursive, not counting itself). Hint: `find "$1" -type f | wc -l`.

### 02 — Octal to rwx · `02-octal-para-rwx.sh`
Receives a file in `$1`, applies `chmod 640` to it, and prints the resulting permission in `rwx` format (use `stat -c '%A'`). Expected output for a regular file:
```
-rw-r-----
```

### 03 — Largest file · `03-maior-arquivo.sh`
Receives a directory in `$1` and prints **only the name** (path) of the largest regular file inside it (recursive). In case of a tie, any one will do. Hint: `find ... -printf '%s %p\n' | sort -n | tail -1`.

<sub>© 2026 Prof. Daniel Santos and translators · CC BY-NC-SA 4.0</sub>
