# 🎴 Cheat Sheet de Bash

Referência rápida de bolso. Para o porquê de cada item, veja o módulo indicado.

## Variáveis e expansões — Módulos 03, 05

```bash
nome="valor"              # sem espaços ao redor do =
echo "$nome" "${nome}"    # referência; chaves quando grudado: "${nome}_x"
nome=$(comando)           # saída de comando vira valor
readonly PI=3.14          # constante
unset nome                # apaga a variável
```

| Expansão de parâmetro | Resultado |
|---|---|
| `${var:-padrão}` | `var`, ou "padrão" se vazia/indefinida |
| `${var:=padrão}` | idem, e **atribui** o padrão a `var` |
| `${var:?msg}` | erro com "msg" se vazia/indefinida |
| `${var:+alt}` | "alt" se `var` **tiver** valor |
| `${#var}` | comprimento |
| `${var#pre}` / `${var##pre}` | remove menor/maior prefixo que casa `pre` |
| `${var%suf}` / `${var%%suf}` | remove menor/maior sufixo |
| `${var/a/b}` / `${var//a/b}` | troca 1ª / todas ocorrências |
| `${var^^}` / `${var,,}` | MAIÚSCULAS / minúsculas |
| `${var:offset:tam}` | fatia (substring) |

## Variáveis especiais — Módulo 03

| Var | Significado |
|---|---|
| `$0` | nome do script |
| `$1`…`$9`, `${10}` | argumentos posicionais |
| `$#` | quantidade de argumentos |
| `"$@"` | todos os argumentos, **cada um** entre aspas (quase sempre o certo) |
| `"$*"` | todos juntos num só texto |
| `$?` | código de saída do último comando |
| `$$` | PID do script |
| `$!` | PID do último comando em background |

## Testes — Módulo 04

```bash
[[ -e arq ]]   # existe        [[ -f arq ]]  # é arquivo comum
[[ -d dir ]]   # é diretório   [[ -r/-w/-x ]]# leg./grav./exec.
[[ -s arq ]]   # existe e não vazio
[[ -z "$s" ]]  # string vazia  [[ -n "$s" ]] # string não vazia
[[ "$a" == "$b" ]]  [[ "$a" != "$b" ]]   [[ "$a" < "$b" ]]  # ordem alfabética
[[ "$a" =~ ^re+gex$ ]]            # casa regex (ERE)
(( a == b ))  (( a < b ))  (( a++ ))     # aritmética e comparação numérica
```

Numéricos no `[[ ]]`/`[ ]`: `-eq -ne -lt -le -gt -ge`. Lógicos: `&&` `||` `!`.

## Condicionais e laços — Módulo 04

```bash
if comando; then ...; elif outro; then ...; else ...; fi

case "$x" in
    a|b) ... ;;
    *)   ... ;;     # padrão
esac

for i in a b c; do ...; done
for ((i=0; i<10; i++)); do ...; done
while comando; do ...; done
until comando; do ...; done
while IFS= read -r linha; do ...; done < arquivo   # ler arquivo linha a linha
```
`break` sai do laço · `continue` pula para a próxima iteração.

## Funções — Módulo 06

```bash
minha_func() {
    local x="$1"           # 'local' evita vazar para fora
    echo "resultado"       # "retorna" valor via stdout
    return 0               # retorna CÓDIGO DE SAÍDA (0–255)
}
valor=$(minha_func arg)
```

## Arrays — Módulo 06

```bash
arr=(a b c)                # indexado
arr[3]="d";  arr+=("e")    # atribuir / acrescentar
"${arr[0]}"  "${arr[@]}"   # elemento / todos
"${#arr[@]}" "${!arr[@]}"  # quantidade / índices

declare -A mapa            # associativo
mapa[chave]="valor"
"${mapa[chave]}"  "${!mapa[@]}"  "${mapa[@]}"
```

## Redirecionamento e pipes — Módulo 02

```bash
cmd > arq        # stdout sobrescreve        cmd >> arq   # acrescenta
cmd < arq        # stdin vem do arquivo
cmd 2> err       # stderr para arquivo
cmd > tudo 2>&1  # stdout e stderr juntos
cmd &> tudo      # idem (atalho Bash)
cmd 2>/dev/null  # descarta erros
a | b | c        # pipe: stdout de um vira stdin do próximo
cmd | tee arq    # vê na tela E grava
```

## Modo robusto — Módulo 07

```bash
set -euo pipefail          # erro para o script; variável indefinida é erro; pipe falha propaga
trap 'rm -rf "$tmp"' EXIT  # limpeza garantida ao sair
tmp=$(mktemp -d)           # diretório temporário seguro
```

## Avançado — Módulos 09–10

```bash
<(cmd)   >(cmd)            # process substitution (arquivo virtual)
cmd <<EOF ... EOF          # here-document
cmd <<< "texto"           # here-string
exec 3< arq               # abre descritor 3 para leitura
cmd &                     # roda em background
jobs; fg %1; bg %1; wait  # controle de jobs
kill -TERM "$pid"         # envia sinal
timeout 10 cmd            # mata se passar de 10s
```

---
Veja também: [tabela-testes.md](tabela-testes.md) · [tabela-expansoes.md](tabela-expansoes.md) · [tabela-sinais.md](tabela-sinais.md)

<sub>© 2026 Prof. Daniel Santos · CC BY-NC-SA 4.0</sub>
