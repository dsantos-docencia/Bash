# Project 2 — System monitor

**🌍 Idioma / Language:** [Português](README.md) · **English**

Collects **disk**, **memory**, and **load** usage, compares them to thresholds, and alerts. Exits with status 1 if any threshold is exceeded — ideal for cron or a health-check.

## Usage
```bash
bash monitor.sh                      # default thresholds (90%)
bash monitor.sh -d 80 -m 75 -p /var  # disk 80%, memory 75%, checks /var
```

## What it teaches
- Extracting numbers from `df` and `/proc/meminfo` with `awk`
- Numeric comparison and alert counting
- Using the **exit code** as a signal (0 = ok, 1 = alert) for cron/CI

## Schedule (alert every 5 min)
```cron
*/5 * * * * /caminho/monitor.sh -d 85 || echo "server under pressure" | mail -s alert you@example.com
```

<sub>© 2026 Prof. Daniel Santos and translators · Code [PolyForm NC](../../LICENSE) · Content [CC BY-NC-SA 4.0](../../LICENSE-CONTEUDO.md)</sub>
