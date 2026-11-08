<div align="center">

# 🐚 Bash do Zero à Automação Profissional

### Um curso aberto, prático e verificável de Bash — a língua franca do terminal Linux

*Material didático gratuito da comunidade, para a comunidade.*

[![Licença do código: MIT](https://img.shields.io/badge/c%C3%B3digo-MIT-blue.svg)](LICENSE)
[![Licença do conteúdo: CC BY-NC-SA 4.0](https://img.shields.io/badge/conte%C3%BAdo-CC%20BY--NC--SA%204.0-lightgrey.svg)](LICENSE-CONTEUDO.md)
[![Verificação](https://github.com/dsantos-docencia/bash/actions/workflows/verificar.yml/badge.svg)](https://github.com/dsantos-docencia/bash/actions)
[![PRs bem-vindos](https://img.shields.io/badge/PRs-bem--vindos-brightgreen.svg)](CONTRIBUTING.md)

</div>

---

## 👋 Boas-vindas

Olá! Eu sou o **Professor Daniel Santos** — desenvolvedor, provedor de serviços de tecnologia e professor de cursos técnicos de TI e segurança cibernética (Senac SP e Etec). Trabalho com infraestrutura Linux, automação e segurança todos os dias, e dou aula do que faço.

Este repositório nasceu de uma convicção simples: **quase todo mundo que mexe com Linux acaba precisando de Bash — e quase ninguém aprende Bash direito.** As pessoas copiam comandos da internet, torcem para funcionar e nunca entendem *por quê*. O resultado são scripts que quebram em produção, apagam o que não deviam e assombram quem os herda.

Aqui a proposta é outra. Cada conceito vem com **o porquê**, cada exemplo **roda de verdade** (uma esteira automática verifica isso a cada alteração) e cada exercício tem **correção automática**, para você saber na hora se acertou. Não é uma coleção de receitas: é um caminho do primeiro `echo` até escrever automações que você confiaria num servidor de produção.

É de graça, é aberto e é para a comunidade. Se ajudar você, deixe uma ⭐ e, se puder, [contribua](CONTRIBUTING.md).

> *"Não quero ensinar o que todo mundo ensina. Quero que, ao final, você olhe para um script e saiba exatamente o que cada caractere faz — e por que está ali."* — Prof. Daniel

---

## 🎯 Para quem é este curso

- **Iniciantes totais** que nunca abriram um terminal — comece no [Módulo 00](modulos/00-boas-vindas-e-fundamentos/).
- **Usuários de Linux** que copiam comandos mas querem **entender** o que fazem.
- **Estudantes de TI, redes e segurança** que precisam de automação de verdade.
- **Profissionais de DevOps/SRE/SysAdmin** querendo fechar lacunas e dominar os cantos obscuros (descritores de arquivo, `trap`, process substitution, portabilidade).

Pré-requisito único: um teclado e vontade de errar num ambiente seguro.

---

## 🗺️ Trilha de aprendizado

Os módulos são progressivos. Cada um tem: **teoria** (`README.md`), **exemplos executáveis comentados** (`exemplos/`) e **exercícios com correção automática** (`exercicios/`).

| # | Módulo | O que você domina | Horas |
|---|---|---|---|
| 00 | [Boas-vindas e Fundamentos](modulos/00-boas-vindas-e-fundamentos/) | Shell vs. terminal vs. kernel, história, instalação, ambiente seguro, pedir ajuda | 3–4 |
| 01 | [Sobrevivência no Terminal](modulos/01-sobrevivencia-no-terminal/) | Navegação, arquivos, permissões, links, busca | 6–8 |
| 02 | [Fluxo de Dados](modulos/02-fluxo-de-dados/) | stdin/stdout/stderr, redirecionamentos, pipes, globbing, histórico | 5–7 |
| 03 | [Primeiros Scripts](modulos/03-primeiros-scripts/) | Shebang, variáveis, aspas e expansões, `echo`/`printf`/`read` | 6–8 |
| 04 | [Controle de Fluxo](modulos/04-controle-de-fluxo/) | `if`, `[[ ]]`, `case`, `for`, `while`, `until`, `select` | 8–10 |
| 05 | [Texto e Dados](modulos/05-texto-e-dados/) | `grep`, `sed`, `awk`, `cut`, `sort`, `uniq`, `tr`, expansão de parâmetros | 10–12 |
| 06 | [Arrays e Funções](modulos/06-arrays-e-funcoes/) | Arrays indexados e associativos, funções, escopo, strings nativas | 6–8 |
| 07 | [Scripts Robustos](modulos/07-scripts-robustos/) | Códigos de saída, `set -euo pipefail`, `trap`, logging, depuração | 6–8 |
| 08 | [Qualidade e Testes](modulos/08-qualidade-e-testes/) | ShellCheck, Bats, `getopts`, estilo, documentação | 5–7 |
| 09 | [Bash Avançado](modulos/09-bash-avancado/) | Subshells, process substitution, here-docs, descritores, FIFOs | 8–10 |
| 10 | [Sistema, Processos e Rede](modulos/10-sistema-processos-rede/) | Jobs, sinais, `cron`, `systemd` timers, `ssh`, `curl`, `rsync` | 8–10 |
| 11 | [Segurança e Portabilidade](modulos/11-seguranca-e-portabilidade/) | Injeção de comandos, `eval`, `mktemp`, armadilhas clássicas, POSIX | 6–8 |

🚀 **Projetos práticos** (consolidam tudo): veja [projetos/](projetos/) — backup, monitor de sistema, processamento em lote, CLI profissional, deploy e mais.

📚 **Referência rápida** (consulta permanente): veja [referencia/](referencia/) — cheat sheets, tabelas de testes, expansões, sinais.

---

## 🚦 Começando em 3 passos

```bash
# 1. Clone o repositório
git clone https://github.com/dsantos-docencia/bash.git
cd bash

# 2. Abra o primeiro módulo
less modulos/00-boas-vindas-e-fundamentos/README.md

# 3. Rode um exemplo (não quebra nada — tudo roda em pasta temporária)
bash modulos/00-boas-vindas-e-fundamentos/exemplos/02-tres-formas-de-executar.sh
```

Fez um exercício? Corrija na hora:
```bash
./ferramentas/corrigir.sh 00        # corrige todos os exercícios do módulo 00
```

Quer um ambiente 100% isolado e idêntico ao de um servidor? Use o laboratório em container:
```bash
./laboratorio/entrar.sh             # precisa de Docker (veja laboratorio/README.md)
```

---

## 🧰 O que torna este repositório diferente

- **Tudo roda.** Um robô ([GitHub Actions](.github/workflows/verificar.yml)) executa `bash -n`, ShellCheck e **todos** os exemplos e soluções a cada push. Se você está lendo isto com o selo verde acima, cada linha de código aqui funciona.
- **Correção automática sem instalar nada.** O corretor é escrito em Bash puro ([ferramentas/](ferramentas/)) e explica *por que* você errou, não só *que* errou.
- **O porquê antes do como.** Nenhuma sintaxe é apresentada solta: primeiro o problema real, depois a ferramenta.
- **Armadilhas em destaque.** Cada módulo tem uma seção de erros clássicos — aqueles que todo mundo comete uma vez.
- **Português de verdade**, com exemplos do nosso dia a dia.

---

## 🌐 Comunidades, documentação e recursos

Veja a lista curada e comentada em **[referencia/recursos.md](referencia/recursos.md)**. Os destaques:

**Documentação oficial**
- [GNU Bash Manual](https://www.gnu.org/software/bash/manual/) — a fonte da verdade (também via `man bash`)
- [Bash Reference (local)](referencia/) — nossos resumos

**As melhores referências da comunidade**
- [Greg's Wiki (mywiki.wooledge.org)](https://mywiki.wooledge.org/) — BashFAQ, BashGuide e **BashPitfalls** são leitura obrigatória
- [Bash Hackers Wiki](https://bash-hackers.gabe565.com/) — arquivo mantido pela comunidade do antigo wiki.bash-hackers.org
- [ShellCheck](https://www.shellcheck.net/) — cole seu script e descubra os problemas
- [explainshell.com](https://explainshell.com/) — cole um comando e veja cada parte explicada

**Prática**
- [Exercism — Bash Track](https://exercism.org/tracks/bash) — dezenas de exercícios com mentoria gratuita
- Os [exercícios](modulos/) e [projetos](projetos/) deste repositório

**Em português**
- [Blau Araujo — cursos e vídeos de Shell/Bash (Codeberg)](https://codeberg.org/blau_araujo/para-aprender-shell)
- [Aurélio Jargas — aurelio.net](https://aurelio.net/shell/) — referência brasileira clássica de shell e expressões regulares

---

## 🤝 Contribuindo

Encontrou um erro? Tem uma ideia de exemplo ou exercício? Toda ajuda é bem-vinda. Leia o [guia de contribuição](CONTRIBUTING.md) — explicamos o padrão dos arquivos e como rodar a verificação localmente antes de abrir um PR.

Pessoas que contribuíram estão em [CONTRIBUTORS.md](CONTRIBUTORS.md).

---

## 📄 Licença e autoria

Criado e mantido por **Prof. Daniel Santos** ([@dsantos-docencia](https://github.com/dsantos-docencia)).

- **Código** (scripts, ferramentas, exemplos): [MIT](LICENSE) — use como quiser, inclusive comercialmente.
- **Conteúdo didático** (textos, exercícios, diagramas): [CC BY-NC-SA 4.0](LICENSE-CONTEUDO.md) — compartilhe e adapte para fins não comerciais, citando a autoria e mantendo a mesma licença.

> A pasta [`scripts/`](scripts/) contém scripts reais de infraestrutura (Samba AD, auditoria) usados em aula, com curadoria de versões. Leia o [aviso da pasta](scripts/README.md) antes de executá-los.

<div align="center">
<sub>Feito com dedicação para quem quer <b>entender</b>, não apenas copiar. · © 2026 Daniel Santos</sub>
</div>
