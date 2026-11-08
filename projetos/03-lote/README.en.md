# Project 3 — Batch processing (rename)

**🌍 Idioma / Language:** [Português](README.md) · **English**

Mass-renames the files in a folder: lowercase, spaces → `_`, optional prefix. **Safe by default**: it simulates (dry-run) and only acts with `-x`.

## Usage
```bash
bash renomear.sh pasta/           # SIMULATES (shows what it would do)
bash renomear.sh -x pasta/        # actually applies
bash renomear.sh -x -p 2026_ fotos/   # also adds a prefix
```

## What it teaches
- Transforming strings with parameter expansion (`${v,,}`, `${v// /_}`)
- The **dry-run** pattern (simulate before acting) — essential in destructive automation
- **Idempotency**: running again causes no harm (already-correct names stay unchanged)
- `shopt -s nullglob` for empty folders

<sub>© 2026 Prof. Daniel Santos and translators · Code [PolyForm NC](../../LICENSE) · Content [CC BY-NC-SA 4.0](../../LICENSE-CONTEUDO.md)</sub>
