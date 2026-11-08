# Project 1 — Smart backup

**🌍 Idioma / Language:** [Português](README.md) · **English**

Compresses a directory into a `.tar.gz` with the date in the name, keeps only the N most recent copies, and logs everything.

## Usage
```bash
bash backup.sh -o /caminho/backups -k 5 /pasta/importante
bash backup.sh --help
```
| Option | Does |
|---|---|
| `-o DESTINO` | where to save (default `./backups`) |
| `-k MANTER` | how many copies to keep (default 5) |
| `-q` | quiet |

## What it teaches
- Creating archives with `tar -czf` and a name with `date`
- **Rotation**: listing by date (`find -printf '%T@'`) and deleting the excess
- Logging with a timestamp and `set -euo pipefail`
- Validating input before acting

## Schedule in cron (example)
```cron
0 2 * * *  /caminho/backup.sh -q -o /backups -k 7 /dados >> /var/log/backup.log 2>&1
```

## Test
```bash
./ferramentas/verificar-tudo.sh   # includes this project's tests
```

<sub>© 2026 Prof. Daniel Santos and translators · Code [PolyForm NC](../../LICENSE) · Content [CC BY-NC-SA 4.0](../../LICENSE-CONTEUDO.md)</sub>
