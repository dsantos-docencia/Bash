<div align="center">

# 🐚 Bash from Zero to Professional Automation

### An open, practical, verifiable Bash course — the lingua franca of the Linux terminal

*Free and open educational material — for noncommercial use.*

**🌍 Idioma / Language:** [Português](README.md) · **English**

[![Code license: PolyForm NC](https://img.shields.io/badge/code-PolyForm%20NC-orange.svg)](LICENSE)
[![Content license: CC BY-NC-SA 4.0](https://img.shields.io/badge/content-CC%20BY--NC--SA%204.0-lightgrey.svg)](LICENSE-CONTEUDO.md)
[![Checks](https://github.com/dsantos-docencia/Bash/actions/workflows/verificar.yml/badge.svg)](https://github.com/dsantos-docencia/Bash/actions)
[![PRs welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

</div>

---

## 👋 Welcome

Hi! I'm **Professor Daniel Santos** — developer, technology service provider, and teacher of technical IT and cybersecurity courses. I work with Linux infrastructure, automation, and security every day, and I teach what I do.

This repository was born from a simple conviction: **almost everyone who touches Linux ends up needing Bash — and almost nobody learns Bash properly.** People copy commands from the internet, hope they work, and never understand *why*. The result: scripts that break in production, delete the wrong things, and haunt whoever inherits them.

Here the approach is different. Every concept comes with **the why**, every example **actually runs** (an automated pipeline verifies this on every change), and every exercise has **automated grading**, so you know right away whether you got it. It's not a collection of recipes: it's a path from your first `echo` to writing automation you'd trust on a production server.

It's free and open (for noncommercial use). If it helps you, leave a ⭐ and, if you can, [contribute](CONTRIBUTING.md).

> *"I don't want to teach what everyone teaches. I want you, by the end, to look at a script and know exactly what each character does — and why it's there."* — Prof. Daniel

> **Note on this translation:** the course is being translated from Brazilian Portuguese. The landing page and Module 00 are in English; the remaining modules are being translated with community help — [come help translate!](traducoes/README.md)

---

## 🎯 Who this is for

- **Absolute beginners** who've never opened a terminal — start at [Module 00](modulos/00-boas-vindas-e-fundamentos/).
- **Linux users** who copy commands but want to **understand** them.
- **IT, networking, and security students** who need real automation.
- **DevOps/SRE/SysAdmin professionals** closing gaps and mastering the dark corners (file descriptors, `trap`, process substitution, portability).

Only prerequisite: a keyboard and the willingness to make mistakes in a safe place.

---

## 🗺️ Learning path

Modules are progressive. Each has: **theory** (`README.md`), **runnable commented examples** (`exemplos/`), and **exercises with automated grading** (`exercicios/`).

| # | Module | What you master | Hours |
|---|---|---|---|
| 00 | [Welcome & Fundamentals](modulos/00-boas-vindas-e-fundamentos/) | Shell vs. terminal vs. kernel, history, install, safe lab, getting help | 3–4 |
| 01 | [Surviving the Terminal](modulos/01-sobrevivencia-no-terminal/) | Navigation, files, permissions, links, search | 6–8 |
| 02 | [Data Flow](modulos/02-fluxo-de-dados/) | stdin/stdout/stderr, redirection, pipes, globbing, history | 5–7 |
| 03 | [First Scripts](modulos/03-primeiros-scripts/) | Shebang, variables, quoting & expansions, `echo`/`printf`/`read` | 6–8 |
| 04 | [Control Flow](modulos/04-controle-de-fluxo/) | `if`, `[[ ]]`, `case`, `for`, `while`, `until`, `select` | 8–10 |
| 05 | [Text & Data](modulos/05-texto-e-dados/) | `grep`, `sed`, `awk`, `cut`, `sort`, `uniq`, `tr`, parameter expansion | 10–12 |
| 06 | [Arrays & Functions](modulos/06-arrays-e-funcoes/) | Indexed & associative arrays, functions, scope, native strings | 6–8 |
| 07 | [Robust Scripts](modulos/07-scripts-robustos/) | Exit codes, `set -euo pipefail`, `trap`, logging, debugging | 6–8 |
| 08 | [Quality & Testing](modulos/08-qualidade-e-testes/) | ShellCheck, Bats, `getopts`, style, documentation | 5–7 |
| 09 | [Advanced Bash](modulos/09-bash-avancado/) | Subshells, process substitution, here-docs, descriptors, FIFOs | 8–10 |
| 10 | [System, Processes & Network](modulos/10-sistema-processos-rede/) | Jobs, signals, `cron`, `systemd` timers, `ssh`, `curl`, `rsync` | 8–10 |
| 11 | [Security & Portability](modulos/11-seguranca-e-portabilidade/) | Command injection, `eval`, `mktemp`, classic pitfalls, POSIX | 6–8 |

🚀 **Hands-on projects**: see [projetos/](projetos/) — backup, system monitor, batch processing, professional CLI, deploy, and more.

📚 **Quick reference**: see [referencia/](referencia/) — cheat sheets, test tables, expansions, signals.

---

## 🚦 Getting started in 3 steps

```bash
# 1. Clone the repository
git clone https://github.com/dsantos-docencia/Bash.git
cd Bash

# 2. Open the first module
less modulos/00-boas-vindas-e-fundamentos/README.en.md

# 3. Run an example (harmless — everything runs in a temp folder)
bash modulos/00-boas-vindas-e-fundamentos/exemplos/02-tres-formas-de-executar.sh
```

Did an exercise? Grade it instantly:
```bash
./ferramentas/corrigir.sh 00        # grades all exercises in module 00
```

Want a fully isolated, server-like environment? Use the container lab:
```bash
./laboratorio/entrar.sh             # needs Docker (see laboratorio/README.md)
```

---

## 🧰 What makes this repository different

- **Everything runs.** A bot ([GitHub Actions](.github/workflows/verificar.yml)) runs `bash -n`, ShellCheck, and **all** examples and solutions on every push. If you're seeing the green badge above, every line of code here works.
- **Automated grading with zero install.** The grader is pure Bash ([ferramentas/](ferramentas/)) and explains *why* you got it wrong, not just *that* you did.
- **The why before the how.** No syntax is shown in isolation: first the real problem, then the tool.
- **Pitfalls highlighted.** Every module flags the classic mistakes — the ones everyone makes once.

---

## 🌐 Communities, documentation, and resources

See the curated, commented list in **[referencia/recursos.md](referencia/recursos.md)**. Highlights: the [GNU Bash Manual](https://www.gnu.org/software/bash/manual/), [Greg's Wiki](https://mywiki.wooledge.org/) (BashFAQ, BashGuide, BashPitfalls), [ShellCheck](https://www.shellcheck.net/), [explainshell.com](https://explainshell.com/), and [Exercism's Bash track](https://exercism.org/tracks/bash).

---

## 🤝 Contributing

> **Join me and leave something useful for the next person.** 🌱
> Knowledge that isn't shared dies with whoever keeps it. This repo is an invitation: add your knowledge to everyone else's and help build the best Bash course out there.

Every bit helps:
- **Found a bug or have an idea?** [Open an issue](https://github.com/dsantos-docencia/Bash/issues/new/choose) or send a Pull Request.
- **Wrote a cool script and want to share it?** We have a community catalog. Submit yours via the **"📜 Submit a script to the community"** issue — we review it, discuss, and if it fits, include it in [`scripts/comunidade/`](scripts/comunidade/) **with your credit**. *Don't let your knowledge die with you.*
- **Speak another language?** Help translate (see the [translation guide](traducoes/README.md)).

Read the [contribution guide](CONTRIBUTING.md). Contributors are listed in [CONTRIBUTORS.md](CONTRIBUTORS.md). 💚

---

## 📄 License & authorship

Created and maintained by **Prof. Daniel Santos** ([@dsantos-docencia](https://github.com/dsantos-docencia)).

This is **open material for noncommercial use** — study, use, and learn freely; just don't exploit it commercially. Details and the author's rights in the [NOTICE](NOTICE.md).

- **Code** (scripts, tooling, examples): [PolyForm Noncommercial 1.0.0](LICENSE) — use, modify, and redistribute **for noncommercial purposes**.
- **Educational content** (text, exercises, diagrams): [CC BY-NC-SA 4.0](LICENSE-CONTEUDO.md) — share and adapt **for noncommercial purposes**, with attribution and share-alike.
- **Commercial use** requires the author's permission. Need it? [Open an issue](https://github.com/dsantos-docencia/Bash/issues) or get in touch.

<div align="center">
<sub>Made with care for those who want to <b>understand</b>, not just copy. · © 2026 Daniel Santos</sub>
</div>
