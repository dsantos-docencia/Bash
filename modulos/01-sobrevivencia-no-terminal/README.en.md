# Module 01 — Surviving the Terminal

> *"Before you automate, you need to be able to walk around the house in the dark."*

**🌍 Idioma / Language:** [Português](README.md) · **English**

> 🌐 *Community translation. Spotted a slip or have a better wording? [Open an issue or PR](https://github.com/dsantos-docencia/Bash/issues) — see [traducoes/](../../traducoes/README.en.md).*

**Suggested time:** 6–8 h · **Level:** beginner · **Prerequisite:** [Module 00](../00-boas-vindas-e-fundamentos/README.en.md)

## 🎯 Objectives

- Navigate the file system with confidence (absolute and relative paths)
- Create, copy, move, and delete files and directories — and understand why `rm` is dangerous
- Read file contents in several ways
- Find files with `find` and `locate`
- Understand and manipulate **permissions** (the `rwx` model) — the #1 cause of "permission denied"
- Tell hard links apart from symbolic links

---

## 1. The map: Linux directory structure

On Linux **everything is a file**, and everything hangs off a single tree that starts at the root `/`. There's no "C:" and "D:"; a USB stick appears *inside* the tree (in `/media`, for example).

```
/
├── bin   → essential programs (ls, cp, bash)
├── etc   → system CONFIGURATION files (plain text!)
├── home  → users' personal folders (/home/daniel)
├── root  → the superuser's (root) personal folder
├── tmp   → temporary files (wiped on boot)
├── usr   → user programs and data (/usr/bin, /usr/share)
├── var   → data that VARies: logs (/var/log), queues, caches
├── dev   → devices (/dev/sda, /dev/null)
├── proc  → the kernel's virtual "files" (/proc/cpuinfo)
└── mnt, /media → mount points (USB sticks, disks)
```

> 💡 Want to know what each folder is for? `man hier` describes the whole hierarchy. It's a standard called the **FHS** (Filesystem Hierarchy Standard).

## 2. Where I am and where I'm going

| Command | Does | Example |
|---|---|---|
| `pwd` | *print working directory* — shows where you are | `/home/daniel` |
| `cd path` | enters a directory | `cd /var/log` |
| `cd` (alone) | goes back to your `$HOME` | |
| `cd -` | goes back to the **previous** directory | toggles between two |
| `cd ..` | goes up one level | |
| `ls` | lists the contents | |

### Paths: absolute vs. relative

- **Absolute** starts at `/`: `/home/daniel/projetos` — works from anywhere.
- **Relative** starts from where you are: `projetos/curso` — depends on `pwd`.

| Shortcut | Means |
|---|---|
| `~` | your personal folder (`/home/daniel`) |
| `.` | the **current** directory |
| `..` | the **parent** directory |
| `-` | the **previous** directory (only with `cd`) |

```bash
cd ~/projetos          # /home/daniel/projetos
cd ../documentos       # go up one and enter documentos
./meu-script.sh        # "the script HERE in this folder" — the . is required!
```

> ⚠️ Why `./script` and not just `script`? For **security**. The shell only looks for programs in the `PATH` folders. If the current directory were in the PATH, a malicious file named `ls` in your folder could be run by accident. The `./` explicitly says "this one here".

## 3. Listing with `ls` — the options that matter

```bash
ls              # names, in columns
ls -l           # long format: permissions, owner, size, date
ls -a           # shows hidden files (those starting with .)
ls -h           # human-readable sizes (K, M, G) — combine: ls -lh
ls -t           # sorts by modification date (newest first)
ls -R           # recursive (enters subfolders)
ls -la          # the classic combo: everything, long format
```

Reading a line of `ls -l`:
```
-rw-r--r-- 1 daniel daniel 4096 nov  7 23:14 notas.txt
│└┬┘└┬┘└┬┘   └──┬─┘ └──┬─┘  └┬─┘ └────┬────┘ └───┬──┘
│ │  │  │      owner group  size    date       name
│ │  │  └ others can: read
│ │  └ group can: read
│ └ owner can: read, write
└ type: - file, d directory, l link
```

## 4. Creating and destroying

| Command | Does | Caution |
|---|---|---|
| `mkdir pasta` | creates a directory | `mkdir -p a/b/c` creates the whole chain |
| `touch arq` | creates an empty file (or updates the date) | |
| `cp orig dest` | copies | `cp -r` for directories; `cp -i` asks before overwriting |
| `mv orig dest` | moves **or renames** | `mv -i` asks before overwriting |
| `rm arq` | **deletes** (no recycle bin!) | see below 🔥 |
| `rmdir pasta` | removes an **empty** directory | safe, which is why it exists |

### 🔥 The danger of `rm`

In the terminal **there is no recycle bin**. `rm` deletes forever.

```bash
rm arquivo.txt          # deletes the file
rm -r pasta/            # deletes the folder and ALL its contents (recursive)
rm -f arquivo           # forces, without asking
rm -rf pasta/           # recursive + force = the most dangerous combo in Unix
```

> 🔥 **`rm -rf /` or `rm -rf ~` can destroy your entire system.** Classic mistakes:
> - `rm -rf $PASTA/` with `$PASTA` empty becomes `rm -rf /`
> - One extra space: `rm -rf / home/lixo` (note the space after `/`)
>
> **Protections every professional uses:**
> - `alias rm='rm -i'` in `~/.bashrc` (asks before each removal)
> - Prefer moving to a trash: the `trash-cli` tool
> - **Always** test with `ls` what the glob will match before `rm`: swap `rm` for `echo rm` and see what would show up.

## 5. Reading files

| Command | Best for |
|---|---|
| `cat arq` | short files; concatenates several (`cat a b > c`) |
| `less arq` | long files — navigate with `/`, arrows, `q` to quit |
| `head arq` | first 10 lines (`head -n 5`, `head -c 100`) |
| `tail arq` | last 10 lines |
| `tail -f log` | **follows** a log in real time (great for `/var/log`) |
| `wc arq` | counts lines (`-l`), words (`-w`), bytes (`-c`) |

```bash
tail -f /var/log/syslog    # watch the log grow live — Ctrl+C to stop
wc -l *.txt                # counts lines of each .txt
```

## 6. Finding files

| Command | How it works | When to use |
|---|---|---|
| `find` | **walks** the disk now, slow but precise and powerful | searches by name, size, date, and **running** actions |
| `locate` | queries a **pre-indexed database**, instant | finding fast by name (may be stale; `updatedb` refreshes it) |
| `which cmd` | where a command's executable is | `which bash` → `/usr/bin/bash` |
| `type cmd` | classifies the command (builtin? alias? file?) | always the 1st step |

```bash
find . -name "*.log"              # .log from the current folder down (recursive)
find /etc -type f -name "*.conf"  # only files (-type f), .conf in /etc
find . -type d -name "cache"      # only directories
find . -size +10M                 # larger than 10 MB
find . -mtime -7                  # modified in the last 7 days
find . -name "*.tmp" -delete      # FINDS and DELETES (careful!)
find . -name "*.sh" -exec chmod +x {} \;   # makes each found .sh executable
```

> 💡 `find` is a mini Swiss Army knife. The `{}` is replaced by each file found, and the `\;` ends the `-exec`. Always test without the `-delete`/`-exec` first, just to see the list.

## 7. Permissions: the `rwx` model

Every file has an **owner**, a **group**, and permissions for three classes of people: the **owner** (u), the **group** (g), and the **others** (o).

```
  rwx r-x r--
  └┬┘ └┬┘ └┬┘
 owner group others
```

Each class has 3 bits:
| Letter | On a file | On a directory |
|---|---|---|
| `r` (read, 4) | read the content | list the content |
| `w` (write, 2) | change the content | create/delete files inside |
| `x` (execute, 1) | execute | **enter** (`cd`) it |

> 💡 On a directory, `x` without `r` lets you enter but not list; `r` without `x` lets you "see the name" but not use it. That's why directories are almost always `rwx` (7) or `r-x` (5).

### `chmod` — changing permissions

**Octal mode** (sum the values of each class):
```bash
chmod 755 script.sh   # owner rwx(7), group r-x(5), others r-x(5) — typical of a program
chmod 644 nota.txt    # owner rw-(6), group r--(4), others r--(4) — typical of a file
chmod 600 segredo     # only the owner reads and writes — typical of a key/password
chmod 700 ~/privado   # a folder only yours
```
| Octal | Binary | rwx |
|---|---|---|
| 7 | 111 | rwx |
| 6 | 110 | rw- |
| 5 | 101 | r-x |
| 4 | 100 | r-- |
| 0 | 000 | --- |

**Symbolic mode** (more readable for one-off changes):
```bash
chmod +x script.sh      # adds execution for everyone
chmod u+x script.sh     # only for the owner (user)
chmod g-w arquivo       # removes write from the group
chmod o= arquivo        # zeroes the others' permissions
chmod a+r arquivo       # all can read
```

### Owner and group

```bash
chown daniel arquivo          # changes the owner (needs sudo)
chown daniel:dev arquivo      # changes owner and group
chgrp dev arquivo             # changes only the group
```

> ⚠️ "Permission denied" is almost always: (a) missing `x` on a script → `chmod +x`; (b) missing permission on the file/folder → check with `ls -l`; (c) you need `sudo` for system files.

## 8. Links: two names for the same data

```bash
ln arquivo apelido          # HARD link: another name for the SAME data (same inode)
ln -s alvo atalho           # SOFT link (symbolic): a "shortcut" pointing to a path
```

| | Hard link | Soft link (symbolic) |
|---|---|---|
| Points to | the **data** (inode) | a **path** (text) |
| If the original is deleted | keeps working | **breaks** (points to nothing) |
| Crosses file systems | no | yes |
| Can point to a directory | no | yes |
| Typical use | rare | **shortcuts, "current" versions** |

```bash
ls -l atalho     # shows:  atalho -> alvo
readlink atalho  # shows where the link points
```

---

## 🧪 Examples in this module

| File | Demonstrates |
|---|---|
| [01-navegacao.sh](exemplos/01-navegacao.sh) | `pwd`, `cd`, absolute/relative paths, `~ . .. -` in a temp lab |
| [02-permissoes.sh](exemplos/02-permissoes.sh) | Octal vs. symbolic, the real effect of each bit |
| [03-find-na-pratica.sh](exemplos/03-find-na-pratica.sh) | Searches by name, type, size, and `-exec` |

## ⚠️ Module pitfalls

- `rm -rf` with an empty variable or an extra space
- Forgetting `-r` when copying/deleting directories
- Forgetting `chmod +x` and getting "permission denied" when running a script
- Trusting `locate` right after creating a file (the index may be stale)
- Deleting the original of a **soft link** and breaking everything that points to it

## 🏋️ Exercises

See [exercicios/README.en.md](exercicios/README.en.md). Grade with `./ferramentas/corrigir.sh 01`.

## ✅ Mastery checklist

- [ ] I know the difference between an absolute and a relative path
- [ ] I can explain each field of `ls -l`
- [ ] I convert `rwxr-xr--` to `754` and vice versa
- [ ] I use `find` to locate by name, type, and size
- [ ] I know when a soft link will break

---

⬅️ [Module 00](../00-boas-vindas-e-fundamentos/README.en.md) · ➡️ [Module 02 — Data Flow](../02-fluxo-de-dados/README.en.md)

<sub>© 2026 Prof. Daniel Santos and translators · Content [CC BY-NC-SA 4.0](../../LICENSE-CONTEUDO.md) · Code [PolyForm NC](../../LICENSE)</sub>
