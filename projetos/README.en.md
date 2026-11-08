# 🚀 Practical Projects

**🌍 Idioma / Language:** [Português](README.md) · **English**

Here theory becomes a tool. Each project is a **complete, working** script, with commented code, error handling, and **automated tests** — exactly as you'd write it at work.

> Unlike the examples (which illustrate a concept), the projects solve a real problem end to end. Read the code, run it, break it, improve it.

## The projects

| # | Project | Concepts applied | Modules |
|---|---|---|---|
| 1 | [Smart backup](01-backup/README.en.md) | `tar`, date in the name, rotation, log, `trap` | 05, 07, 10 |
| 2 | [System monitor](02-monitor/README.en.md) | `awk` over `/proc`, thresholds, alerts | 05, 07 |
| 3 | [Batch processing](03-lote/README.en.md) | mass renaming, report, idempotency | 04, 05, 06 |
| 4 | [Professional CLI](04-cli/README.en.md) | `getopts`, colors, `--help`, subcommands | 06, 08 |
| 5 | [Link checker](05-verifica-links/README.en.md) | file reading, parallelism, exit codes | 06, 10 |
| 6 | [Simple deploy with rollback](06-deploy/README.en.md) | `trap` for rollback, stages, idempotency | 07, 10 |

## Running and testing

Each project has its `README`, the main script, and a `testes/` folder with tests in the course's mini-framework:

```bash
# run the project
bash projetos/01-backup/backup.sh --help

# run a project's tests (via the grader, which also covers projects)
./ferramentas/verificar-tudo.sh      # includes the project tests
```

All projects are **safe to run**: they operate in temporary directories or require you to point explicitly at the target, and none touches the real network in the tests.

<sub>© 2026 Prof. Daniel Santos and translators · Code [PolyForm NC](../LICENSE) · Content [CC BY-NC-SA 4.0](../LICENSE-CONTEUDO.md)</sub>
