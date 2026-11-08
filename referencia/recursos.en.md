# 🌐 Resources: communities, documentation, and practice

**🌍 Idioma / Language:** [Português](recursos.md) · **English**

A curated, annotated list. Not everything is equal — below, what's worth your time.

## 📘 Official documentation (the source of truth)

- **[GNU Bash Manual](https://www.gnu.org/software/bash/manual/bash.html)** — the complete, normative manual. Also available offline: `man bash` and `info bash`. Dense, but definitive. When in doubt about behavior, this is where you check.
- **[GNU Bash — project page](https://www.gnu.org/software/bash/)** — downloads, changelog, and the `help-bash` list.
- **[POSIX Shell Command Language](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html)** — the POSIX standard, important when you need portable scripts (Module 11).

## 🏆 The best community references

- **[Greg's Wiki (mywiki.wooledge.org)](https://mywiki.wooledge.org/)** — probably the best Bash material on the internet. Three gems:
  - **[BashGuide](https://mywiki.wooledge.org/BashGuide)** — a beginner-to-intermediate guide, done right.
  - **[BashFAQ](https://mywiki.wooledge.org/BashFAQ)** — answers to practically every real question ("how do I read a file line by line?", "why is `$(ls)` problematic?").
  - **[BashPitfalls](https://mywiki.wooledge.org/BashPitfalls)** — the 60+ most common traps. **Required reading** after Module 07.
- **[Bash Hackers Wiki](https://bash-hackers.gabe565.com/)** — the old `wiki.bash-hackers.org` (whose domain expired in 2023) preserved and maintained by the community. Excellent on parameter expansion and internal features. Alternative mirror: [flokoe/bash-hackers-wiki](https://github.com/flokoe/bash-hackers-wiki).
- **[Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)** — pragmatic, widely adopted style conventions.
- **[pure bash bible](https://github.com/dylanaraps/pure-bash-bible)** — how to do dozens of tasks using only Bash internals (without calling external programs). Great for performance.

## 🔧 Tools you'll use your whole life

- **[ShellCheck](https://www.shellcheck.net/)** — paste your script and it flags bugs and bad practices, with explanations. Install it locally (`apt/brew install shellcheck`) and integrate it with your editor. Covered in [Module 08](../modulos/08-qualidade-e-testes/README.en.md).
- **[explainshell.com](https://explainshell.com/)** — paste a complex command (e.g., `tar -xzvf arq.tar.gz`) and see each part explained from the man pages. Perfect for deciphering that command you copied.
- **[Bats-core](https://github.com/bats-core/bats-core)** — a testing framework for Bash. Covered in [Module 08](../modulos/08-qualidade-e-testes/README.en.md). Docs: [bats-core.readthedocs.io](https://bats-core.readthedocs.io).
- **[tldr pages](https://tldr.sh/)** — practical, short command examples, the opposite of the dense man page. `tldr tar`.

## 🏋️ To practice

- **[Exercism — Bash Track](https://exercism.org/tracks/bash)** — ~90 free exercises with automatic tests and **free human mentoring**. Uses Bats, like our Module 08.
- **[This course's exercises](../modulos/)** — with automatic grading via `./ferramentas/corrigir.sh`.
- **[This course's projects](../projetos/README.en.md)** — real end-to-end automations.
- **[OverTheWire: Bandit](https://overthewire.org/wargames/bandit/)** — a wargame that teaches the command line and Linux by solving challenges over SSH. Addictive and educational.

## 🇧🇷 In Portuguese

- **[Blau Araujo](https://codeberg.org/blau_araujo/para-aprender-shell)** — courses, videos, and the book *Pequeno Manual do Programador GNU/Bash*. Deep content on the GNU shell philosophy, in Portuguese. Highlights: [Curso Básico de Programação em Bash](https://codeberg.org/blau_araujo/prog-bash-basico) and the Intensivão on YouTube.
- **[Aurélio Marinho Jargas — aurelio.net](https://aurelio.net/shell/)** — a classic Brazilian reference. Author of *Shell Script Profissional* (Novatec) and *Expressões Regulares — Uma abordagem divertida*. The [Introdução ao Shell Script](https://aurelio.net/shell/) is a great first contact.

## 📺 Channels and newsletters

- **[help-bash mailing list](https://lists.gnu.org/mailman/listinfo/help-bash)** — questions answered by people who maintain Bash.
- **[r/bash](https://www.reddit.com/r/bash/)** — an active community, good for questions and discoveries.

---

> 💡 **How to study documentation without drowning:** don't read `man bash` cover to cover. Use it as a dictionary: you have a specific question, open it with `man bash`, press `/`, and search for the term (e.g., `/Parameter Expansion`). See [ler-o-man.md](ler-o-man.en.md).

<sub>© 2026 Prof. Daniel Santos and translators · CC BY-NC-SA 4.0</sub>
