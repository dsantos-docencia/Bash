# Módulo 08 — Qualidade e Testes

> *"Código sem teste é código que você tem medo de mudar. E ninguém automatiza o que tem medo de tocar."*

**Carga sugerida:** 5–7 h · **Nível:** intermediário+ · **Pré-requisito:** [Módulo 07](../07-scripts-robustos/)

## 🎯 Objetivos

- Usar o **ShellCheck** para pegar bugs antes de rodar
- Processar argumentos profissionalmente com **`getopts`**
- Escrever testes automatizados com **Bats** (o padrão de mercado)
- Adotar um estilo consistente e documentar scripts

---

## 1. ShellCheck — seu revisor incansável

O [ShellCheck](https://www.shellcheck.net) é um analisador estático: ele lê seu script e aponta bugs, más práticas e armadilhas — **sem executar nada**. É a ferramenta que mais acelera o aprendizado de Bash.

```bash
shellcheck meu-script.sh            # analisa e lista os problemas, com explicação
shellcheck -S warning script.sh     # só warnings e erros (ignora 'info')
shellcheck -x script.sh             # segue arquivos 'source'ados
```

Exemplo do que ele pega:
```bash
# Você escreve:
rm -rf $DIR/arquivo
# ShellCheck avisa (SC2086): "Double quote to prevent globbing and word splitting"
# → correto: rm -rf "$DIR/arquivo"
```

| Código | Significa |
|---|---|
| SC2086 | variável sem aspas (o clássico) |
| SC2164 | `cd` sem `|| exit` |
| SC2046 | `$(...)` sem aspas |
| SC2006 | usou crase em vez de `$(...)` |
| SC2162 | `read` sem `-r` |

> 💡 **Integre ao editor.** No VS Code, a extensão ShellCheck sublinha os problemas enquanto você digita. É como ter um professor de Bash olhando por cima do ombro. Instale localmente: `apt install shellcheck` / `brew install shellcheck`.

### Silenciando um aviso (com justificativa)

Quando você **sabe** o que está fazendo, desative pontualmente — sempre com um comentário dizendo por quê:

```bash
# shellcheck disable=SC2086  # queremos a divisão em palavras aqui
comando $argumentos_intencionalmente_sem_aspas
```

> ⚠️ Este próprio repositório roda ShellCheck em **todos** os scripts via CI. Veja [`ferramentas/verificar-tudo.sh`](../../ferramentas/verificar-tudo.sh).

## 2. `getopts` — opções de linha de comando como gente grande

Scripts sérios aceitam opções (`-v`, `-o arquivo`, `--help`). O `getopts` (builtin) faz o trabalho pesado de forma padronizada:

```bash
#!/usr/bin/env bash
set -euo pipefail

verboso=0
saida=""

# A string "vo:h" significa: -v e -h são flags; -o espera um ARGUMENTO (o :)
while getopts "vo:h" opt; do
    case "$opt" in
        v) verboso=1 ;;
        o) saida="$OPTARG" ;;        # OPTARG tem o valor da opção
        h) echo "uso: $0 [-v] [-o arquivo]"; exit 0 ;;
        *) echo "opção inválida" >&2; exit 2 ;;
    esac
done
shift $(( OPTIND - 1 ))              # descarta as opções já lidas; sobram os args

echo "verboso=$verboso saida=$saida resto=$*"
```

```console
$ ./script.sh -v -o log.txt arquivo1 arquivo2
verboso=1 saida=log.txt resto=arquivo1 arquivo2
```

- A string de opções: letra sozinha = flag; letra com `:` = exige argumento (em `$OPTARG`).
- `OPTIND` aponta para o próximo argumento; `shift $((OPTIND-1))` deixa só os argumentos "de verdade".

> 💡 `getopts` (builtin, com "s") trata só opções curtas (`-v`). Para opções longas (`--verbose`), ou você trata manualmente num `while`/`case`, ou usa o `getopt` (programa externo, sem "s") — mas o builtin cobre a maioria dos casos com portabilidade.

## 3. Bats — testes automatizados de verdade

[Bats](https://github.com/bats-core/bats-core) (*Bash Automated Testing System*) é o framework padrão para testar scripts Bash. (Este curso usa um mini-framework próprio nos exercícios — leia [`ferramentas/lib/teste.sh`](../../ferramentas/lib/teste.sh) — mas **Bats é o que você usa no trabalho**.)

### Instalando

```bash
# Debian/Ubuntu
sudo apt install bats
# macOS
brew install bats-core
# npm
npm install -g bats
```

### Escrevendo um teste

Um arquivo `.bats` é um script com uma sintaxe especial. Cada `@test` é um caso:

```bash
#!/usr/bin/env bats

@test "soma dois números" {
    run bash soma.sh 2 3
    [ "$status" -eq 0 ]
    [ "$output" = "5" ]
}

@test "falha sem argumentos" {
    run bash soma.sh
    [ "$status" -ne 0 ]
}
```

- `run comando` executa e captura `$status` (código de saída) e `$output` (saída).
- Cada `@test` passa se **todos** os comandos dentro dele tiverem sucesso (Bats usa `set -e` por dentro).
- `[ ... ]` são as asserções (os mesmos testes do Módulo 04).

```bash
bats soma.bats          # roda os testes
# ✓ soma dois números
# ✓ falha sem argumentos
# 2 tests, 0 failures
```

### `setup` e `teardown`

```bash
setup() {
    TMP="$(mktemp -d)"           # roda antes de CADA teste
}
teardown() {
    rm -rf "$TMP"                # roda depois de CADA teste
}

@test "cria o arquivo de saída" {
    run bash gera.sh "$TMP/out.txt"
    [ -f "$TMP/out.txt" ]
}
```

Veja o exemplo [`exemplos/calculadora.bats`](exemplos/calculadora.bats) rodando contra [`exemplos/calculadora.sh`](exemplos/calculadora.sh).

## 4. Estilo e documentação

- Siga um guia consistente (o [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html) é uma ótima base).
- **Cabeçalho** em todo script: nome, uso, autor.
- Funções com um comentário dizendo entradas e saídas.
- Nomes descritivos; `snake_case` para variáveis e funções.
- `readonly`/`declare -r` para constantes.
- Uma função `uso()`/`help()` que documenta e serve ao `-h`.

```bash
#!/usr/bin/env bash
#
# backup.sh — compacta um diretório com data no nome
# Uso: backup.sh [-o destino] <diretório>
#
set -euo pipefail
readonly VERSAO="1.0.0"
```

---

## 🧪 Exemplos deste módulo

| Arquivo | Demonstra |
|---|---|
| [calculadora.sh](exemplos/calculadora.sh) | Script com `getopts`, validação e `uso()` |
| [calculadora.bats](exemplos/calculadora.bats) | Testes Bats para a calculadora (se o `bats` estiver instalado) |
| [01-getopts.sh](exemplos/01-getopts.sh) | Processamento de opções `-v -o arquivo -h` passo a passo |

> Rode os testes Bats com: `bats modulos/08-qualidade-e-testes/exemplos/calculadora.bats`
> (pulado automaticamente na verificação do curso se o `bats` não estiver instalado).

## ⚠️ Armadilhas do módulo

- Ignorar avisos do ShellCheck "porque funciona" (até o dia em que não funciona)
- Esquecer `shift $((OPTIND-1))` e processar opções como argumentos
- Teste que depende de estado deixado por outro teste (use `setup`/`teardown`)
- Testar só o caminho feliz — teste também erros e bordas

## 🏋️ Exercícios

Veja [exercicios/README.md](exercicios/README.md). Corrija com `./ferramentas/corrigir.sh 08`.

## ✅ Checklist de domínio

- [ ] Rodo ShellCheck e entendo os códigos SC mais comuns
- [ ] Processo opções com `getopts` e `shift $((OPTIND-1))`
- [ ] Escrevo um teste Bats com `run`, `$status` e `$output`
- [ ] Uso `setup`/`teardown` para isolar testes
- [ ] Documento o uso e ofereço `-h`

---

⬅️ [Módulo 07](../07-scripts-robustos/README.md) · ➡️ [Módulo 09 — Bash Avançado](../09-bash-avancado/README.md)

<sub>© 2026 Prof. Daniel Santos · Conteúdo [CC BY-NC-SA 4.0](../../LICENSE-CONTEUDO.md) · Código [MIT](../../LICENSE)</sub>
