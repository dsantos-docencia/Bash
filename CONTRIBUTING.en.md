# 🤝 Contribution Guide

**Join me and leave something useful for the next person.** 🌱 Knowledge that isn't shared dies with whoever keeps it. Bug fixes, new examples, exercises, translations, community scripts, and text improvements are all welcome — no matter the size.

*(Português: [CONTRIBUTING.md](CONTRIBUTING.md))*

## Ways to contribute

| I want to… | How |
|---|---|
| **Fix a bug** (text, example, link) | ["🐛 Bug" issue](https://github.com/dsantos-docencia/Bash/issues/new/choose) or a direct PR |
| **Suggest an example/exercise** | ["💡 Suggestion" issue](https://github.com/dsantos-docencia/Bash/issues/new/choose) |
| **Share a script of mine** | ["📜 Submit a script" issue](https://github.com/dsantos-docencia/Bash/issues/new/choose) → goes into [`scripts/comunidade/`](scripts/comunidade/) with your credit |
| **Translate** | see the [translation guide](traducoes/README.md) |

> **On the license of contributions:** by contributing, you agree your contribution is published under the project's licenses (**noncommercial** — PolyForm Noncommercial for code, CC BY-NC-SA for content; see the [NOTICE](NOTICE.md)), keeping your credit as its author.

## Before you start

This repo has a promise: **all code here works**. An automated check enforces it. Run it locally before opening a Pull Request:

```bash
./ferramentas/verificar-tudo.sh
```

It runs, for every `.sh` (outside `scripts/`): **syntax** (`bash -n`), **ShellCheck**, **execution** of all examples, **official solutions** against the tests, and **project tests**. If it's green locally, it'll be green in [GitHub Actions](.github/workflows/verificar.yml).

## File conventions

Mirror the existing structure (modules have `README.md` + `exemplos/` + `exercicios/` with `solucoes/` and `testes/`). Every `.sh` carries the standard header, examples must **run without arguments and without hanging** and must **not alter the system** (use `mktemp -d` + `trap`), comments explain the **why**, and there should be **zero ShellCheck warnings** (or a justified `# shellcheck disable=...`).

### Writing a test

Every `teste_*` function in a `.teste.sh` file is discovered and run in isolation. Those files are *sourced* (not executed), so they begin with `# shellcheck shell=bash`. Assertions are documented in [`ferramentas/lib/teste.sh`](ferramentas/lib/teste.sh):

```bash
# shellcheck shell=bash
teste_short_description() {
    executar arg1 arg2          # runs the student's script
    afirmar_status 0
    afirmar_igual "expected" "$SAIDA"
    afirmar_contem "fragment" "$SAIDA"
}
```

## Pull Request flow

1. Fork and create a branch: `git checkout -b my-change`
2. Make changes following the conventions above
3. Run `./ferramentas/verificar-tudo.sh` — all green
4. Commit with a clear message
5. Open the PR describing **what** and **why**

## Bash style adopted

`#!/usr/bin/env bash` · `set -euo pipefail` in production scripts · **always** quote variables (`"$var"`, `"${array[@]}"`) · `[[ ]]` over `[ ]` · `snake_case` names (Portuguese is fine) · `$(...)` over backticks.

## Code of conduct

Be kind. We're here to learn and teach. See [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).

<sub>© 2026 Prof. Daniel Santos</sub>
