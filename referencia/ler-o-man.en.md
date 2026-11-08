# 📖 How to read a man page without panicking

**🌍 Idioma / Language:** [Português](ler-o-man.md) · **English**

*Man pages* (manuals) are the standard Unix documentation. They look intimidating because they were made in 1971 for experts. With three tricks, they become your best friend.

## Opening and navigating

```bash
man ls          # opens the ls manual (in the 'less' pager)
```

| Key | Does |
|---|---|
| `/text` | **Searches** for "text" |
| `n` / `N` | Next / previous search occurrence |
| Space / `b` | Page forward / back |
| `g` / `G` | Start / end of the document |
| `q` | **Quits** |
| `h` | Pager help |

## The sections of a man page

Every manual follows the same backbone. You almost never read it all — you go straight to the useful section.

| Section | What it has | When to look |
|---|---|---|
| **NAME** | Name + one-line description | To confirm it's the right command |
| **SYNOPSIS** | How it's used, in brief | **Always** — it's the map |
| **DESCRIPTION** | Full explanation + all the options | To understand a specific option |
| **EXAMPLES** | Ready-made examples | **Start here** when it exists |
| **EXIT STATUS** | Exit codes | When handling errors in scripts |
| **SEE ALSO** | Related commands | To discover alternatives |

## Deciphering the SYNOPSIS

This is the scary part. The notation is always the same:

```
ls [OPTION]... [FILE]...
```

| Symbol | Meaning | Example |
|---|---|---|
| `[ ]` | **Optional** | `[FILE]` — you may pass a file or not |
| `...` | **Can repeat** | `[FILE]...` — zero, one, or several files |
| `a\|b` | **One OR the other** | `-a\|-b` |
| `<required>` or no brackets | **Required** | in `cp ORIGEM DESTINO`, both are required |
| `-x` | short option | `-l` |
| `--text` | long option (same thing, more readable) | `--all` = `-a` |

Example read aloud:
```
grep [OPTIONS] PATTERN [FILE...]
```
> "grep takes options (maybe), **required** a pattern, and then none, one, or several files."

## The numbered manual sections

The same name can have several pages. `printf` is a **command** (section 1) and a **C function** (section 3).

| No. | Content |
|---|---|
| 1 | User commands (`ls`, `grep`) |
| 2 | Kernel system calls (`open`, `read`) |
| 3 | C library functions (`printf(3)`) |
| 5 | File formats (`man 5 crontab`, `man 5 passwd`) |
| 8 | Administration commands (`mount`, `iptables`) |

```bash
man 5 crontab    # the FORMAT of the crontab file
man 1 crontab    # the crontab COMMAND
man -a printf    # shows all sections, one after another
```

## For Bash builtins, use `help`

`man cd` doesn't work well — `cd` is a Bash **builtin**, not a program. Use:
```bash
help cd
help read
help [[
help          # lists all builtins
```

## Modern shortcuts

- `command --help` — a quick built-in summary (not every command has it).
- [`tldr command`](https://tldr.sh) — just practical examples.
- [explainshell.com](https://explainshell.com) — paste a whole command and see each part explained.

<sub>© 2026 Prof. Daniel Santos and translators · CC BY-NC-SA 4.0</sub>
