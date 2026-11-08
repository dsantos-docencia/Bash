# Project 4 — Professional CLI (task manager)

**🌍 Idioma / Language:** [Português](README.md) · **English**

A command-line `todo` with **subcommands** (git style), colors, `--help`, and file persistence.

## Usage
```bash
export TAREFAS_ARQUIVO=./minhas.txt   # where to store (default ~/.tarefas.txt)
bash tarefas.sh add "Estudar o Módulo 08"
bash tarefas.sh add "Fazer backup"
bash tarefas.sh list
bash tarefas.sh done 1
bash tarefas.sh rm 2
```

## What it teaches
- **Subcommands** with `case` (the pattern of CLIs like git/docker)
- `getopts` for global options + per-subcommand arguments
- **ANSI colors** only when the output is a terminal (`[[ -t 1 ]]`)
- A state file and safe editing via `mktemp` + `mv`
- Small functions, one per responsibility

<sub>© 2026 Prof. Daniel Santos and translators · Code [PolyForm NC](../../LICENSE) · Content [CC BY-NC-SA 4.0](../../LICENSE-CONTEUDO.md)</sub>
