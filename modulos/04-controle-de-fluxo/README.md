# Módulo 04 — Controle de Fluxo

> *"Até aqui seus scripts foram listas de comandos. Agora eles ganham a capacidade de **decidir** e **repetir** — viram programas."*

**Carga sugerida:** 8–10 h · **Nível:** intermediário · **Pré-requisito:** [Módulo 03](../03-primeiros-scripts/)

## 🎯 Objetivos

- Tomar decisões com `if`/`elif`/`else` e entender o que é "verdadeiro" no shell
- Dominar `[[ ]]` e saber por que é melhor que `[ ]`
- Usar `case` para múltiplas opções limpas
- Repetir com `for`, `while`, `until` e criar menus com `select`
- Controlar laços com `break`, `continue` e `shift`
- Ler um arquivo linha a linha **do jeito certo**

---

## 1. O que é "verdadeiro" no Bash? (código de saída)

Aqui está a ideia que confunde quem vem de outras linguagens: **o `if` do Bash não testa `true`/`false` — ele testa o código de saída de um comando.**

Todo comando, ao terminar, devolve um número de 0 a 255 (o `$?`):
- **0 = sucesso** ("verdadeiro")
- **≠ 0 = falha** ("falso")

É o **oposto** da intuição de C/Python (onde 0 é falso). Aqui, 0 é sucesso porque "há um jeito de dar certo e muitos de dar errado".

```bash
if comando; then
    echo "o comando terminou com 0 (sucesso)"
else
    echo "o comando terminou com código ≠ 0"
fi
```

```bash
if grep -q "erro" log.txt; then      # grep -q sai 0 se ACHOU
    echo "achei erros no log"
fi

if ping -c1 -W1 8.8.8.8 &>/dev/null; then
    echo "tem internet"
fi
```

> 💡 Não existe tipo booleano. `if [[ ... ]]` funciona porque `[[ ]]` **é um comando** que sai 0 (verdadeiro) ou 1 (falso).

## 2. `if`, `elif`, `else`

```bash
if condição; then
    comandos
elif outra; then
    comandos
else
    comandos
fi                      # 'if' ao contrário fecha o bloco
```

### `[ ]` vs `[[ ]]` vs `test`

`[` é literalmente um **comando** (sinônimo de `test`); por isso precisa de espaços e é frágil. `[[ ]]` é uma **palavra reservada** do Bash, mais segura e poderosa.

```bash
[ "$x" = "sim" ]        # POSIX, funciona em sh, mas frágil sem aspas
[[ $x == "sim" ]]       # Bash: mais seguro (não faz word splitting), suporta == com glob e =~
```

| Recurso | `[ ]` | `[[ ]]` |
|---|:---:|:---:|
| Portável ao `sh` | ✅ | ❌ (só Bash/ksh/zsh) |
| Seguro sem aspas | ❌ | ✅ |
| `&&` `\|\|` internos | ❌ | ✅ |
| `==` com glob, `=~` regex | ❌ | ✅ |

> 👉 **Neste curso usamos `[[ ]]`.** Só caímos no `[ ]` quando o alvo é portabilidade POSIX (Módulo 11).

### Os testes (resumo — tabela completa em [referencia/tabela-testes.md](../../referencia/tabela-testes.md))

```bash
# Arquivos
[[ -e cam ]]  # existe     [[ -f cam ]]  # é arquivo    [[ -d cam ]]  # é diretório
[[ -r cam ]]  # legível    [[ -s cam ]]  # não vazio
# Strings
[[ -z "$s" ]] # vazia      [[ -n "$s" ]] # não vazia
[[ "$a" == "$b" ]]         [[ "$a" != "$b" ]]
[[ "$s" =~ ^[0-9]+$ ]]     # casa regex (só dígitos)
# Números (prefira (( )) )
(( a > b ))   (( a == b ))   [[ "$a" -gt "$b" ]]
```

### Operadores lógicos

```bash
if [[ -f "$arq" && -r "$arq" ]]; then ...           # dentro do [[ ]]
if comando1 && comando2; then ...                   # entre comandos
comando && echo "deu certo"                         # só roda se o 1º teve sucesso
comando || echo "falhou"                            # só roda se o 1º falhou
mkdir -p "$dir" || exit 1                            # idioma clássico: "ou morra"
```

## 3. `case` — quando há muitas opções

```bash
case "$1" in
    start)            echo "iniciando" ;;
    stop)             echo "parando" ;;
    restart|reload)   echo "reiniciando" ;;     # | = "ou"
    *.txt)            echo "é um arquivo de texto" ;;   # padrões glob!
    [0-9])            echo "um dígito" ;;
    *)                echo "opção desconhecida"; exit 1 ;;   # * = qualquer coisa
esac
```

Mais limpo que uma escada de `elif` quando se compara **uma** variável contra vários padrões. Os padrões são **globs** (como no Módulo 02), não regex.

## 4. Laços

### `for` — sobre uma lista

```bash
for fruta in maçã banana abacaxi; do
    echo "fruta: $fruta"
done

for arq in *.txt; do          # itera sobre arquivos (glob)
    echo "processando $arq"
done

for i in {1..5}; do           # sequência
    echo "passo $i"
done
```

### `for` estilo C — quando precisa de contador

```bash
for (( i=0; i<10; i++ )); do
    echo "i = $i"
done
```

### `while` e `until`

```bash
contador=0
while (( contador < 3 )); do          # enquanto a condição for verdadeira
    echo "contador = $contador"
    (( contador++ ))
done

until ping -c1 servidor &>/dev/null; do    # até a condição virar verdadeira
    echo "esperando o servidor..."
    sleep 2
done
```

### Lendo um arquivo linha a linha — **o jeito certo**

```bash
while IFS= read -r linha; do
    echo "linha: $linha"
done < arquivo.txt
```

> ⚠️ Esse idioma tem três detalhes que **todos** erram no começo:
> - `IFS=` (vazio) evita que espaços no início/fim da linha sejam cortados.
> - `read -r` evita que `\` seja interpretada.
> - `< arquivo` no **final** do `done` — o arquivo alimenta o laço inteiro.
>
> ❌ **Nunca** use `for linha in $(cat arquivo)`: isso quebra em espaços e expande globs. É o [BashPitfall nº 1](https://mywiki.wooledge.org/BashPitfalls). Veja o exemplo 03.

### `select` — menu interativo rápido

```bash
select opcao in "Backup" "Restaurar" "Sair"; do
    case "$opcao" in
        Backup)    echo "fazendo backup"; break ;;
        Restaurar) echo "restaurando"; break ;;
        Sair)      break ;;
        *)         echo "opção inválida" ;;
    esac
done
```

## 5. `break`, `continue` e `shift`

```bash
for i in {1..10}; do
    (( i == 5 )) && continue    # pula o 5
    (( i == 8 )) && break       # para no 8
    echo "$i"
done
# imprime 1 2 3 4 6 7
```

`shift` "descarta" o primeiro argumento posicional, deslocando os demais — útil para processar argumentos um a um:

```bash
while (( $# > 0 )); do
    echo "processando: $1"
    shift                       # $2 vira $1, $3 vira $2...
done
```

---

## 🧪 Exemplos deste módulo

| Arquivo | Demonstra |
|---|---|
| [01-if-e-testes.sh](exemplos/01-if-e-testes.sh) | Código de saída como "verdade", testes de arquivo/string/número |
| [02-case-e-loops.sh](exemplos/02-case-e-loops.sh) | `case`, `for` (lista, glob, C), `while`, `break`/`continue` |
| [03-ler-arquivo.sh](exemplos/03-ler-arquivo.sh) | O jeito CERTO (`while read`) vs. o errado (`for ... $(cat)`) |

## ⚠️ Armadilhas do módulo

- `for linha in $(cat arq)` — quebra em espaços e expande globs
- Esquecer o `;;` no fim de um ramo do `case`
- Comparar números com `<`/`>` no `[[ ]]` (lá é ordem alfabética!) em vez de `-lt`/`(( ))`
- `while ... | read var` perder a variável (subshell do pipe — Módulo 06)
- Achar que `if` testa booleano (ele testa **código de saída**)

## 🏋️ Exercícios

Veja [exercicios/README.md](exercicios/README.md). Corrija com `./ferramentas/corrigir.sh 04`.

## ✅ Checklist de domínio

- [ ] Explico por que 0 é "verdadeiro" no shell
- [ ] Escolho `[[ ]]` e sei quando cair no `[ ]`
- [ ] Uso `case` com padrões glob
- [ ] Leio arquivos com `while IFS= read -r`
- [ ] Controlo laços com `break`/`continue` e argumentos com `shift`

---

⬅️ [Módulo 03](../03-primeiros-scripts/README.md) · ➡️ [Módulo 05 — Texto e Dados](../05-texto-e-dados/README.md)

<sub>© 2026 Prof. Daniel Santos · Conteúdo [CC BY-NC-SA 4.0](../../LICENSE-CONTEUDO.md) · Código [MIT](../../LICENSE)</sub>
