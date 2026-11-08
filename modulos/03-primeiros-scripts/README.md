# Módulo 03 — Primeiros Scripts

> *"Um script é só uma sequência de comandos que você digitaria no terminal — guardada para rodar quantas vezes quiser."*

**Carga sugerida:** 6–8 h · **Nível:** iniciante+ · **Pré-requisito:** [Módulo 02](../02-fluxo-de-dados/)

## 🎯 Objetivos

- Escrever a anatomia correta de um script (shebang, permissão, execução)
- Dominar **variáveis**: criação, referência, ambiente vs. locais
- Entender o assunto que mais causa bug no Bash: **aspas e expansões**
- Usar as variáveis especiais (`$0`, `$1`, `$#`, `$@`, `$?`…)
- Interagir: `echo`, `printf` (o profissional) e `read`

---

## 1. Anatomia de um script

```bash
#!/usr/bin/env bash          # 1. shebang: quem executa este arquivo
# Faz um backup rápido       # 2. comentários começam com #
set -euo pipefail            # 3. modo seguro (Módulo 07) — bom hábito desde já
origem="$HOME/dados"         # 4. variáveis
echo "Backup de $origem"     # 5. comandos, um por linha
```

### O shebang: `#!/bin/bash` vs. `#!/usr/bin/env bash`

Aquela primeira linha diz ao **kernel** qual interpretador usar.

| Forma | Significado | Quando |
|---|---|---|
| `#!/bin/bash` | caminho fixo para o Bash | você controla o sistema e sabe que está lá |
| `#!/usr/bin/env bash` | "ache o bash no `PATH`" | **recomendado** — funciona no macOS (bash do Homebrew), em BSDs, etc. |

> 💡 Por que `env`? No macOS o Bash moderno fica em `/opt/homebrew/bin/bash`, não em `/bin/bash`. `env` segue o `PATH` e acha a versão certa. Este curso usa sempre `#!/usr/bin/env bash`.

### Executando: três formas (revisão do Módulo 00)

```bash
bash script.sh      # não precisa de +x; ignora o shebang; processo novo
chmod +x script.sh  # dá permissão de execução (uma vez)
./script.sh         # usa o shebang; processo novo
source script.sh    # roda no shell ATUAL (afeta suas variáveis)  — ou: . script.sh
```

## 2. Variáveis

```bash
nome="Daniel"          # SEM espaços ao redor do = (nome = "x" é ERRO)
idade=38
echo "$nome tem $idade anos"
echo "${nome}Santos"   # chaves quando o nome "gruda" no texto seguinte
```

Regras:
- Sem espaços no `=`. `x=1` ✔ · `x = 1` ✘ (o shell acha que `x` é um comando).
- Para **ler**, use `$nome` ou `${nome}`.
- Tudo é **texto** por padrão. `idade=38` guarda a string "38"; aritmética é com `(( ))` (Módulo 04).

### Variáveis de ambiente vs. locais

- **Locais**: só existem no shell atual.
- **De ambiente** (`export`): são **herdadas** pelos processos filhos.

```bash
cor="azul"              # local: só este shell conhece
export EDITOR="nano"    # de ambiente: programas que você abrir vão herdar
env | sort              # lista todas as variáveis de ambiente
printenv PATH           # mostra uma específica
```

Variáveis de ambiente famosas: `PATH` (onde procurar programas), `HOME`, `USER`, `PWD`, `LANG`, `SHELL`.

> 💡 Por que `export PATH` importa: quando você digita `git`, o shell procura um executável chamado `git` em cada pasta do `PATH`, na ordem. `echo "$PATH"` mostra a lista, separada por `:`.

## 3. Aspas e expansões — o tema mais importante do módulo

Metade dos bugs de iniciante em Bash nasce aqui. Três comportamentos:

| | Expande variáveis? (`$x`) | Expande comandos? (`$(..)`) | Preserva espaços? |
|---|:---:|:---:|:---:|
| `"aspas duplas"` | ✅ sim | ✅ sim | ✅ sim |
| `'aspas simples'` | ❌ não (literal) | ❌ não | ✅ sim |
| `sem aspas` | ✅ sim | ✅ sim | ❌ **não** (divide em palavras) |

```bash
nome="Ana Paula"
echo "$nome"      # Ana Paula          ← um argumento, correto
echo '$nome'      # $nome              ← literal
echo $nome        # Ana Paula          ← DOIS argumentos! (o echo junta, mas...)
mkdir $nome       # cria DUAS pastas: "Ana" e "Paula"!  💥
mkdir "$nome"     # cria UMA pasta: "Ana Paula"  ✔
```

> ⚠️ **A regra de ouro: sempre cite suas variáveis.** `"$var"`, `"${array[@]}"`, `"$(comando)"`. Sem aspas, o Bash faz *word splitting* (divide em espaços) e *globbing* (expande `*`), causando bugs que só aparecem quando um nome tem espaço ou um caractere especial. O ShellCheck (Módulo 08) avisa religiosamente sobre isso.

### Tipos de expansão (visão geral)

```bash
echo "$nome"                 # expansão de variável
echo "$(date +%H:%M)"        # substituição de comando: roda e insere a saída
echo "$((3 * 7))"            # expansão aritmética → 21
echo "~/docs"                # ⚠️ entre aspas, ~ NÃO expande! use: "$HOME/docs"
echo ~/docs                  # /home/daniel/docs  (til só expande fora de aspas)
```

> ⚠️ Substituição de comando: prefira `$(comando)` à crase `` `comando` ``. Faz o mesmo, mas `$(...)` aninha bem: `$(echo $(date))`.

## 4. Variáveis especiais

Dentro de um script, o Bash preenche automaticamente:

| Variável | É |
|---|---|
| `$0` | nome do script |
| `$1`, `$2`, … `${10}` | 1º, 2º, … argumentos (a partir do 10º, use chaves) |
| `$#` | **quantos** argumentos vieram |
| `"$@"` | todos os argumentos, **cada um** entre aspas ← quase sempre o que você quer |
| `"$*"` | todos juntos num texto só |
| `$?` | código de saída do **último** comando (0 = sucesso) |
| `$$` | PID do processo do script |
| `$!` | PID do último comando posto em background (`&`) |

```bash
#!/usr/bin/env bash
echo "Script: $0"
echo "Recebi $# argumentos"
echo "O primeiro é: $1"
echo "Todos: $@"
```
```console
$ ./exemplo.sh maçã banana
Script: ./exemplo.sh
Recebi 2 argumentos
O primeiro é: maçã
Todos: maçã banana
```

> ⚠️ **`"$@"` vs `"$*"`**: com argumentos `a b` `c` (três), `"$@"` são três strings (`a b`, `c`… espera, dois). Guarde: `"$@"` preserva a separação original de cada argumento; `"$*"` cola tudo. Para repassar argumentos a outro comando, é **sempre** `"$@"`.

## 5. Saída: `echo` e `printf`

```bash
echo "simples e direto"
echo -n "sem quebra de linha no fim"
echo -e "com\tescape\tde tab"        # -e ativa \t \n etc. (não portável!)
```

Para saída **séria** (formatação, portabilidade), use `printf`:

```bash
printf '%s tem %d anos\n' "Daniel" 38      # Daniel tem 38 anos
printf '%-10s %5.2f\n' "café" 4.5          # alinha: café       4.50
printf '%03d\n' 7                          # 007 (preenche com zeros)
printf '%x\n' 255                          # ff (hexadecimal)
```

> 💡 **Por que `printf` > `echo` em scripts?** O `echo` varia entre sistemas (o `-e` e `-n` nem sempre funcionam igual). O `printf` é padronizado, controla formato e **repete** o formato para cada argumento extra. Em scripts profissionais, prefira `printf`.

| Formato | Produz |
|---|---|
| `%s` | string |
| `%d` | inteiro |
| `%f` | número com casas (`%.2f` = 2 casas) |
| `%x` | hexadecimal |
| `%-Ns` | alinhado à esquerda em N colunas |
| `%0Nd` | inteiro com N dígitos, preenchido com zeros |
| `\n` `\t` | quebra de linha, tab (sempre funcionam no printf) |

## 6. Entrada: `read`

```bash
read -p "Seu nome: " nome           # -p mostra um prompt
echo "Olá, $nome"

read -s -p "Senha: " senha; echo    # -s esconde o que é digitado
read -t 5 -p "Rápido! " resposta    # -t 5 desiste depois de 5 segundos
read -a palavras <<< "a b c"        # -a lê numa array (Módulo 06)
```

| Opção | Faz |
|---|---|
| `-p texto` | exibe um prompt |
| `-s` | silencioso (senhas) |
| `-t N` | timeout de N segundos |
| `-n N` | para depois de N caracteres |
| `-r` | **não** interpreta `\` (quase sempre você quer isto) |
| `-a arr` | lê os campos numa array |

> ⚠️ Use **`read -r`** por padrão. Sem o `-r`, uma `\` no texto é tratada como escape e some. O ShellCheck avisa (SC2162).

> 💡 Ler um arquivo linha a linha (padrão correto, Módulo 04): `while IFS= read -r linha; do ...; done < arquivo`.

---

## 🧪 Exemplos deste módulo

| Arquivo | Demonstra |
|---|---|
| [01-argumentos.sh](exemplos/01-argumentos.sh) | `$0`, `$1`, `$#`, `"$@"` vs `"$*"` |
| [02-aspas.sh](exemplos/02-aspas.sh) | O efeito real de aspas duplas, simples e nenhuma |
| [03-printf-vs-echo.sh](exemplos/03-printf-vs-echo.sh) | Formatação e por que `printf` é mais confiável |

## ⚠️ Armadilhas do módulo

- Espaço no `=`: `x = 1`
- Esquecer aspas e um nome com espaço virar dois argumentos
- Usar `"$*"` onde precisava de `"$@"`
- `read` sem `-r` comendo as barras invertidas
- Achar que `~` expande dentro de aspas (não expande — use `"$HOME"`)

## 🏋️ Exercícios

Veja [exercicios/README.md](exercicios/README.md). Corrija com `./ferramentas/corrigir.sh 03`.

## ✅ Checklist de domínio

- [ ] Escrevo o shebang certo e sei por que `env`
- [ ] Cito **todas** as minhas variáveis por reflexo
- [ ] Explico a diferença entre `"$@"` e `"$*"`
- [ ] Uso `printf` para saída formatada
- [ ] Leio entrada com `read -r` e trato prompt/senha

---

⬅️ [Módulo 02](../02-fluxo-de-dados/README.md) · ➡️ [Módulo 04 — Controle de Fluxo](../04-controle-de-fluxo/README.md)

<sub>© 2026 Prof. Daniel Santos · Conteúdo [CC BY-NC-SA 4.0](../../LICENSE-CONTEUDO.md) · Código [PolyForm NC](../../LICENSE)</sub>
