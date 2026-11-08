# 📖 Como ler uma man page sem surtar

As *man pages* (manuais) são a documentação-padrão do Unix. Parecem intimidadoras porque foram feitas em 1971 para especialistas. Com três truques, viram sua melhor amiga.

## Abrindo e navegando

```bash
man ls          # abre o manual do ls (no paginador 'less')
```

| Tecla | Faz |
|---|---|
| `/texto` | **Busca** por "texto" |
| `n` / `N` | Próxima / anterior ocorrência da busca |
| Espaço / `b` | Página para frente / para trás |
| `g` / `G` | Início / fim do documento |
| `q` | **Sai** |
| `h` | Ajuda do paginador |

## As seções de uma man page

Todo manual segue a mesma espinha dorsal. Você quase nunca lê tudo — vai direto na seção útil.

| Seção | O que tem | Quando olhar |
|---|---|---|
| **NAME** | Nome + descrição de uma linha | Para confirmar que é o comando certo |
| **SYNOPSIS** | Como se usa, resumido | **Sempre** — é o mapa |
| **DESCRIPTION** | Explicação completa + todas as opções | Para entender uma opção específica |
| **EXAMPLES** | Exemplos prontos | **Comece por aqui** quando existir |
| **EXIT STATUS** | Códigos de saída | Ao tratar erros em scripts |
| **SEE ALSO** | Comandos relacionados | Para descobrir alternativas |

## Decifrando a SYNOPSIS

Esta é a parte que assusta. A notação é sempre a mesma:

```
ls [OPTION]... [FILE]...
```

| Símbolo | Significado | Exemplo |
|---|---|---|
| `[ ]` | **Opcional** | `[FILE]` — pode passar um arquivo ou não |
| `...` | **Pode repetir** | `[FILE]...` — zero, um ou vários arquivos |
| `a\|b` | **Um OU outro** | `-a\|-b` |
| `<obrigatório>` ou sem colchetes | **Obrigatório** | em `cp ORIGEM DESTINO`, ambos são exigidos |
| `-x` | opção curta | `-l` |
| `--texto` | opção longa (mesma coisa, mais legível) | `--all` = `-a` |

Exemplo lido em voz alta:
```
grep [OPTIONS] PATTERN [FILE...]
```
> "grep recebe opções (talvez), **obrigatoriamente** um padrão, e depois nenhum, um ou vários arquivos."

## As seções numeradas do manual

Um mesmo nome pode ter várias páginas. `printf` é um **comando** (seção 1) e uma **função C** (seção 3).

| Nº | Conteúdo |
|---|---|
| 1 | Comandos de usuário (`ls`, `grep`) |
| 2 | Chamadas de sistema do kernel (`open`, `read`) |
| 3 | Funções de biblioteca C (`printf(3)`) |
| 5 | Formatos de arquivo (`man 5 crontab`, `man 5 passwd`) |
| 8 | Comandos de administração (`mount`, `iptables`) |

```bash
man 5 crontab    # o FORMATO do arquivo crontab
man 1 crontab    # o COMANDO crontab
man -a printf    # mostra todas as seções, uma após a outra
```

## Para builtins do Bash, use `help`

`man cd` não funciona bem — `cd` é um **builtin** do Bash, não um programa. Use:
```bash
help cd
help read
help [[
help          # lista todos os builtins
```

## Atalhos modernos

- `comando --help` — resumo rápido embutido (nem todo comando tem).
- [`tldr comando`](https://tldr.sh) — só exemplos práticos.
- [explainshell.com](https://explainshell.com) — cole um comando inteiro e veja cada parte explicada.

<sub>© 2026 Prof. Daniel Santos · CC BY-NC-SA 4.0</sub>
