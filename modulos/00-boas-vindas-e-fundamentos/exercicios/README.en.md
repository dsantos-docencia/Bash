# 🏋️ Exercises — Module 00

**🌍 Idioma / Language:** [Português](README.md) · **English**

> 🌐 *Community translation. Found a slip? [Open an issue or PR](https://github.com/dsantos-docencia/Bash/issues).*
>
> ⚠️ **The expected outputs below are kept in Portuguese on purpose** — the automated grader checks them literally, so your script must print exactly those strings to pass.

Edit the `.sh` files in this folder and grade with:

```bash
./ferramentas/corrigir.sh 00        # all in the module
./ferramentas/corrigir.sh 00 01     # only exercise 01
```

Stuck? The commented solutions are in [solucoes/](solucoes/). Try for at least 15 minutes before opening them — the effort of recalling is what fixes the knowledge.

---

### 01 — Hello, world · `01-ola-mundo.sh`
Make the script print exactly:
```
Olá, mundo!
```

### 02 — Version in two parts · `02-versao.sh`
Using the `BASH_VERSINFO` array (positions `0` and `1`), print the version in the format:
```
Bash 5.2
```
(with **your** version's numbers). Don't use `bash --version` — read the variable.

### 03 — Classifier · `03-classificador.sh`
The script receives **one** command name as an argument (`$1`) and prints only the category returned by `type -t`. If the command doesn't exist, print `desconhecido` and finish with exit code `1`.
```console
$ bash 03-classificador.sh cd
builtin
$ bash 03-classificador.sh xyz
desconhecido
```

<sub>© 2026 Prof. Daniel Santos and translators · CC BY-NC-SA 4.0</sub>
