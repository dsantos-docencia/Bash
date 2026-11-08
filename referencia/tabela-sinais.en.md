# 📡 Unix signals — reference table

**🌍 Idioma / Language:** [Português](tabela-sinais.md) · **English**

Signals are "messages" sent to processes. You catch them with `trap` (Module 07) and send them with `kill` (Module 10).

| Name | No. | Default | Catchable? | Meaning / typical use |
|---|---|---|---|---|
| `SIGHUP` | 1 | terminate | yes | Terminal closed. Daemons use it to **reload config** |
| `SIGINT` | 2 | terminate | yes | **Ctrl+C**. User interrupt |
| `SIGQUIT` | 3 | core dump | yes | Ctrl+\ . Ends and generates a dump |
| `SIGKILL` | 9 | terminate | **no** | Kills instantly, no chance to clean up. Last resort |
| `SIGTERM` | 15 | terminate | yes | **Polite request** to terminate. The `kill` default |
| `SIGSTOP` | 19 | pause | **no** | Freezes the process |
| `SIGTSTP` | 20 | pause | yes | **Ctrl+Z**. Suspends to the background |
| `SIGCONT` | 18 | continue | yes | Resumes a paused process (`fg`/`bg`) |
| `SIGUSR1` | 10 | terminate | yes | Free for your use — signal something to your script |
| `SIGUSR2` | 12 | terminate | yes | Same |
| `SIGCHLD` | 17 | ignore | yes | A child process finished |
| `SIGPIPE` | 13 | terminate | yes | Wrote to a pipe with no reader (e.g., `... | head`) |
| `SIGALRM` | 14 | terminate | yes | Alarm clock (`alarm()`, `timeout`) |

## `trap` pseudo-signals (Bash only)

| Name | Fires when… |
|---|---|
| `EXIT` (0) | the script ends, for any reason — ideal for **cleanup** |
| `ERR` | a command returns status ≠ 0 (with `set -e`) |
| `DEBUG` | before **each** command (debugging) |
| `RETURN` | a function or `source` finishes |

## Usage

```bash
kill -TERM 1234        # sends SIGTERM to PID 1234
kill -9 1234           # SIGKILL (brute force)
kill -l                # lists all signals
pkill -TERM firefox    # by name
trap 'echo cleaning up; rm -f "$tmp"' EXIT     # catches the exit
trap 'echo "Ctrl+C ignored"' INT               # catches Ctrl+C
```

> 💡 **Rule of thumb:** always try `SIGTERM` (15) first — the process can save state and exit cleanly. Only use `SIGKILL` (9) if it ignores the request. `SIGKILL` and `SIGSTOP` **cannot** be caught: they're the kernel's guarantee that any process can be stopped.

<sub>© 2026 Prof. Daniel Santos and translators · CC BY-NC-SA 4.0</sub>
