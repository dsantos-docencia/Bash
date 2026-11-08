# Module 10 — System, Processes, and Network

> *"Now Bash stops playing with text and starts controlling the server: processes, scheduling, and the network."*

**🌍 Idioma / Language:** [Português](README.md) · **English**

> 🌐 *Community translation. Spotted a slip or have a better wording? [Open an issue or PR](https://github.com/dsantos-docencia/Bash/issues) — see [traducoes/](../../traducoes/README.en.md).*

**Suggested time:** 8–10 h · **Level:** advanced · **Prerequisite:** [Module 09](../09-bash-avancado/README.en.md)

## 🎯 Objectives

- Manage processes: `ps`, `top`/`htop`, `kill`, signals
- Control jobs: `&`, `jobs`, `fg`, `bg`, `nohup`, `disown`, `wait`
- Schedule tasks with `cron`, `at`, and `systemd` timers
- Interact with the network: `curl`, `wget`, `ssh`, `scp`, `rsync`
- Run things in parallel and wait for the result

---

## 1. Processes and signals

```bash
ps aux                   # all processes (owner, PID, CPU, memory, command)
ps aux | grep nginx      # filters
pgrep -f nginx           # only the matching PIDs
top                      # interactive monitor (q quits); htop is the improved version
```

**Signals** are messages sent to processes (full table in [referencia/tabela-sinais.md](../../referencia/tabela-sinais.md)):

```bash
kill 1234                # sends SIGTERM (15): "terminate, please"
kill -TERM 1234          # the same, explicit
kill -9 1234             # SIGKILL: kills by force (last resort — no cleanup)
kill -HUP 1234           # SIGHUP: many daemons reload their config
pkill -f "python app"    # kills by name/command line
killall nginx            # kills all processes with that name
```

> ⚠️ **Always** prefer `SIGTERM` (15) before `SIGKILL` (9). `TERM` lets the process save state and exit cleanly; `KILL` cuts the power — it can corrupt data. Only use `-9` when the process ignores `-15`.

Catching signals in your script (review from Module 07):
```bash
trap 'echo "got SIGTERM, shutting down"; limpar; exit 0' TERM
trap 'echo "ignoring Ctrl+C"' INT
```

## 2. Job control (background/foreground)

```bash
comando_longo &          # runs in BACKGROUND; returns control immediately
echo "$!"                # PID of the last background process
jobs                     # lists this session's jobs
fg %1                    # brings job 1 to the FOREGROUND
bg %1                    # resumes job 1 in the background
# Ctrl+Z                 # SUSPENDS the foreground job (then: bg or fg)
wait                     # waits for ALL background jobs to finish
wait "$pid"              # waits for a specific PID
```

### Surviving the terminal closing

When you close the terminal, your processes receive `SIGHUP` and die. To avoid it:

```bash
nohup comando_longo &            # ignores HUP; output goes to nohup.out
comando & disown                 # removes the job from the list (gets no HUP)
```

> 💡 For really long tasks, professionals use `tmux` or `screen` (terminal multiplexers): the session keeps running on the server even if your SSH connection drops. `nohup`/`disown` are the quick fix.

### Simple parallelism

```bash
# Fires 3 tasks at once and waits for all:
for alvo in servidor1 servidor2 servidor3; do
    verificar "$alvo" &          # each one in the background
done
wait                             # only continues when they all finish
echo "all checked"
```

For parallelism with control (N at a time), the tool is `xargs -P` or GNU `parallel`:
```bash
printf '%s\n' *.jpg | xargs -P4 -I{} convert {} {}.png   # 4 conversions at a time
```

## 3. Scheduling

### `cron` — recurring tasks

```bash
crontab -e               # edits your scheduled tasks
crontab -l               # lists them
```

Format of a cron line (5 time fields + command):
```
┌── minute (0-59)
│ ┌── hour (0-23)
│ │ ┌── day of month (1-31)
│ │ │ ┌── month (1-12)
│ │ │ │ ┌── day of week (0-7, 0 and 7 = Sunday)
│ │ │ │ │
* * * * *  command
```
```bash
0 2 * * *      /opt/backup.sh           # every day at 02:00
*/15 * * * *   /opt/checar.sh           # every 15 minutes
0 9 * * 1-5    /opt/relatorio.sh        # 09:00, Monday to Friday
```

> ⚠️ **The #1 cron trap: the PATH.** cron runs with a **minimal** environment (short `PATH`, none of your variables). A script that "works in my terminal" fails under cron because it can't find a command or a variable. **Solutions:** use absolute paths (`/usr/bin/python3`), set `PATH` at the top of the script, and redirect the output to a log (`>> /var/log/x.log 2>&1`) to see the errors.

### `at` — once only

```bash
echo "/opt/tarefa.sh" | at 22:00        # runs today at 10pm, once
at now + 1 hour <<< "comando"           # in 1 hour
atq                                     # lists; atrm N removes
```

### `systemd` timers — the modern alternative

On systems with systemd, timers replace cron with advantages (logs in journald, dependencies, recoverable missed runs). They need two files: a `.service` (what to run) and a `.timer` (when). Overview:

```ini
# /etc/systemd/system/backup.timer
[Timer]
OnCalendar=*-*-* 02:00:00
Persistent=true
[Install]
WantedBy=timers.target
```
```bash
systemctl enable --now backup.timer
systemctl list-timers
journalctl -u backup.service     # the run's logs
```

## 4. Network

```bash
curl -fsSL https://api.exemplo.com/status     # downloads/queries (f=fail on error,
                                              # s=silent, S=show error, L=follow redirect)
curl -o arq.zip https://.../arq.zip           # saves to a file
curl -X POST -d '{"a":1}' -H 'Content-Type: application/json' url   # POST
wget https://.../arquivo                      # downloads (good for large files, resumes with -c)

ssh usuario@servidor 'comando'                # runs a remote command
ssh usuario@servidor < script.sh              # runs a local script on the server
scp arquivo usuario@servidor:/destino/        # copies via SSH
rsync -avz --progress origem/ usuario@servidor:/destino/   # syncs (only what changed)
```

> 💡 `rsync` only transfers what changed — it's the right tool for backups and deploys. `-a` preserves permissions/dates, `-v` is verbose, `-z` compresses, `--delete` mirrors (removes at the destination what disappeared at the source — careful).

> ⚠️ In `curl` inside scripts, use `-fsS`: without `-f`, an HTTP error (404/500) still "succeeds" (status 0) and you download an error page thinking it's the data.

---

## 🧪 Examples in this module

| File | Demonstrates |
|---|---|
| [01-jobs-e-paralelo.sh](exemplos/01-jobs-e-paralelo.sh) | Background `&`, `wait`, parallelism, and time saved |
| [02-sinais-e-trap.sh](exemplos/02-sinais-e-trap.sh) | Sending and catching signals between processes |
| [03-cron-explicado.sh](exemplos/03-cron-explicado.sh) | Decodes cron expressions and shows the PATH trap |

> The examples do **not** access the network or schedule anything for real — they simulate locally so they run anywhere, including in CI.

## ⚠️ Module pitfalls

- `kill -9` by reflex (corrupts data; try `-15` first)
- A cron script failing due to a missing `PATH`/variables
- `curl` without `-f` downloading an error page as if it were data
- `rsync --delete` wiping the destination by mistake
- Forgetting `wait` and the script ending before the background jobs

## 🏋️ Exercises

See [exercicios/README.en.md](exercicios/README.en.md). Grade with `./ferramentas/corrigir.sh 10`.

## ✅ Mastery checklist

- [ ] I send `SIGTERM` before `SIGKILL` and know the difference
- [ ] I run tasks in the background and wait with `wait`
- [ ] I read and write a cron expression
- [ ] I know why a script fails under cron and how to fix it (PATH, absolute paths)
- [ ] I use `curl -fsSL` and `rsync -avz` consciously

---

⬅️ [Module 09](../09-bash-avancado/README.en.md) · ➡️ [Module 11 — Security and Portability](../11-seguranca-e-portabilidade/README.en.md)

<sub>© 2026 Prof. Daniel Santos and translators · Content [CC BY-NC-SA 4.0](../../LICENSE-CONTEUDO.md) · Code [PolyForm NC](../../LICENSE)</sub>
