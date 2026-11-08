# 🌐 Recursos: comunidades, documentação e prática

Lista curada e comentada. Nem tudo é igual — abaixo, o que vale o seu tempo.

## 📘 Documentação oficial (a fonte da verdade)

- **[GNU Bash Manual](https://www.gnu.org/software/bash/manual/bash.html)** — o manual completo e normativo. Também disponível offline: `man bash` e `info bash`. Denso, mas definitivo. Quando houver dúvida sobre comportamento, é aqui que se confere.
- **[GNU Bash — página do projeto](https://www.gnu.org/software/bash/)** — downloads, changelog e a lista `help-bash`.
- **[POSIX Shell Command Language](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html)** — o padrão POSIX, importante quando você precisa de scripts portáveis (Módulo 11).

## 🏆 As melhores referências da comunidade

- **[Greg's Wiki (mywiki.wooledge.org)](https://mywiki.wooledge.org/)** — provavelmente o melhor material de Bash da internet. Três joias:
  - **[BashGuide](https://mywiki.wooledge.org/BashGuide)** — guia do iniciante ao intermediário, feito certo.
  - **[BashFAQ](https://mywiki.wooledge.org/BashFAQ)** — respostas para praticamente toda dúvida real ("como ler um arquivo linha a linha?", "por que `$(ls)` é problemático?").
  - **[BashPitfalls](https://mywiki.wooledge.org/BashPitfalls)** — as 60+ armadilhas mais comuns. **Leitura obrigatória** depois do Módulo 07.
- **[Bash Hackers Wiki](https://bash-hackers.gabe565.com/)** — o antigo `wiki.bash-hackers.org` (cujo domínio expirou em 2023) preservado e mantido pela comunidade. Excelente sobre expansão de parâmetros e recursos internos. Espelho alternativo: [flokoe/bash-hackers-wiki](https://github.com/flokoe/bash-hackers-wiki).
- **[Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)** — convenções de estilo pragmáticas e amplamente adotadas.
- **[pure bash bible](https://github.com/dylanaraps/pure-bash-bible)** — como fazer dezenas de tarefas usando só recursos internos do Bash (sem chamar programas externos). Ótimo para performance.

## 🔧 Ferramentas que você vai usar a vida toda

- **[ShellCheck](https://www.shellcheck.net/)** — cole seu script e ele aponta bugs e más práticas, com explicação. Instale localmente (`apt/brew install shellcheck`) e integre ao seu editor. Tratado no [Módulo 08](../modulos/08-qualidade-e-testes/).
- **[explainshell.com](https://explainshell.com/)** — cole um comando complexo (ex.: `tar -xzvf arq.tar.gz`) e veja cada pedaço explicado a partir das man pages. Perfeito para decifrar aquele comando que você copiou.
- **[Bats-core](https://github.com/bats-core/bats-core)** — framework de testes para Bash. Tratado no [Módulo 08](../modulos/08-qualidade-e-testes/). Docs: [bats-core.readthedocs.io](https://bats-core.readthedocs.io).
- **[tldr pages](https://tldr.sh/)** — exemplos práticos e curtos de comandos, o oposto do man page denso. `tldr tar`.

## 🏋️ Para praticar

- **[Exercism — Bash Track](https://exercism.org/tracks/bash)** — ~90 exercícios gratuitos com testes automáticos e **mentoria humana gratuita**. Usa Bats, como o nosso Módulo 08.
- **[Os exercícios deste curso](../modulos/)** — com correção automática via `./ferramentas/corrigir.sh`.
- **[Os projetos deste curso](../projetos/)** — automações reais de ponta a ponta.
- **[OverTheWire: Bandit](https://overthewire.org/wargames/bandit/)** — jogo de wargame que ensina linha de comando e Linux resolvendo desafios por SSH. Viciante e educativo.

## 🇧🇷 Em português

- **[Blau Araujo](https://codeberg.org/blau_araujo/para-aprender-shell)** — cursos, vídeos e o livro *Pequeno Manual do Programador GNU/Bash*. Conteúdo profundo sobre a filosofia do shell GNU, em português. Destaques: [Curso Básico de Programação em Bash](https://codeberg.org/blau_araujo/prog-bash-basico) e o Intensivão no YouTube.
- **[Aurélio Marinho Jargas — aurelio.net](https://aurelio.net/shell/)** — referência brasileira clássica. Autor de *Shell Script Profissional* (Novatec) e de *Expressões Regulares — Uma abordagem divertida*. A [Introdução ao Shell Script](https://aurelio.net/shell/) é um ótimo primeiro contato.

## 📺 Canais e newsletters

- **[help-bash mailing list](https://lists.gnu.org/mailman/listinfo/help-bash)** — perguntas respondidas por gente que mantém o Bash.
- **[r/bash](https://www.reddit.com/r/bash/)** — comunidade ativa, boa para dúvidas e descobertas.

---

> 💡 **Como estudar documentação sem se afogar:** não leia o `man bash` de cabo a rabo. Use-o como dicionário: tem uma dúvida específica, abre com `man bash`, aperta `/` e busca o termo (ex.: `/Parameter Expansion`). Veja [ler-o-man.md](ler-o-man.md).

<sub>© 2026 Prof. Daniel Santos · CC BY-NC-SA 4.0</sub>
