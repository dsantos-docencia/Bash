# Project 5 — Markdown link checker

**🌍 Idioma / Language:** [Português](README.md) · **English**

Extracts the `[text](target)` links from Markdown files and checks whether the **local links** point to files that exist. Reports the broken ones and exits with status 1 if there are any — perfect for a documentation check in CI.

## Usage
```bash
bash checar-links.sh README.md
bash checar-links.sh -v docs/*.md        # -v also shows the OK and external ones
```

## What it teaches
- Extracting patterns with `grep -oE` + `sed`
- Resolving **relative paths** from the file's folder
- Handling cases (external `http`, `#section` anchors) with `case`
- Using the **exit code** as a verdict for automation

## Real-world idea
Run it on this repository's `.md` files to make sure no documentation has a dead link:
```bash
find . -name '*.md' -not -path './scripts/*' -exec bash checar-links.sh {} +
```

<sub>© 2026 Prof. Daniel Santos and translators · Code [PolyForm NC](../../LICENSE) · Content [CC BY-NC-SA 4.0](../../LICENSE-CONTEUDO.md)</sub>
