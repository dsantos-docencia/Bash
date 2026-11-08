# Módulo 06 — Arrays e Funções

> *"Quando um script passa de 50 linhas, funções deixam de ser luxo e viram necessidade. E arrays são como você guarda listas sem recorrer a gambiarras com strings."*

**Carga sugerida:** 6–8 h · **Nível:** intermediário · **Pré-requisito:** [Módulo 05](../05-texto-e-dados/)

## 🎯 Objetivos

- Usar **arrays indexados** e **associativos** (dicionários)
- Escrever **funções** com parâmetros, retorno e escopo correto (`local`)
- Entender por que `echo x | read var` não funciona (o problema do subshell)
- Organizar scripts grandes em funções pequenas e testáveis

---

## 1. Arrays indexados

Um array guarda vários valores sob um nome só, acessados por índice numérico (começa em **0**).

```bash
frutas=(maçã banana abacaxi)      # cria
frutas[3]="manga"                 # atribui posição
frutas+=(uva pera)                # acrescenta no fim

echo "${frutas[0]}"               # maçã   (um elemento — chaves obrigatórias!)
echo "${frutas[@]}"               # todos os elementos
echo "${#frutas[@]}"              # 5+1=6  → quantidade de elementos
echo "${!frutas[@]}"              # 0 1 2 3 4 5 → os índices
echo "${frutas[@]:1:2}"           # fatia: 2 elementos a partir do índice 1
```

> ⚠️ **Sempre `"${arr[@]}"` com aspas e `@`.** Sem aspas, elementos com espaço se quebram. Com `*` em vez de `@`, tudo vira uma string só. A forma correta para iterar preservando cada elemento é `for x in "${arr[@]}"`.

```bash
for f in "${frutas[@]}"; do
    echo "fruta: $f"
done
```

### Preenchendo arrays a partir de comandos

```bash
mapfile -t linhas < arquivo.txt       # cada linha vira um elemento (sem \n)
# ou:  readarray -t linhas < arquivo.txt   (é o mesmo comando)

arquivos=( *.txt )                    # glob direto numa array
IFS=',' read -ra campos <<< "a,b,c"   # divide uma string por vírgula
```

> 💡 `mapfile -t` é a forma **correta** de ler um arquivo para uma array (o `-t` remove a quebra de linha de cada elemento). Esqueça `arr=($(cat arquivo))`, que quebra em espaços.

## 2. Arrays associativos (dicionários)

Chaves são strings, não números. Precisam ser **declarados** com `declare -A`.

```bash
declare -A idade                  # OBRIGATÓRIO declarar antes
idade[ana]=30
idade[bia]=25
idade["caio silva"]=40            # chave com espaço, ok

echo "${idade[ana]}"              # 30
echo "${!idade[@]}"               # as chaves: ana bia "caio silva"
echo "${idade[@]}"               # os valores: 30 25 40
echo "${#idage[@]}"              # ⚠️ erro de digitação não avisa! (cuidado)

for chave in "${!idade[@]}"; do
    echo "$chave tem ${idade[$chave]} anos"
done
```

> 💡 Arrays associativos são perfeitos para **contar** (histogramas) e **mapear** (de → para). O exemplo de relatório do Módulo 05 (`awk`) tem equivalente em Bash puro com `declare -A`.

## 3. Funções

```bash
# Duas sintaxes equivalentes:
saudar() { echo "Olá, $1"; }
function saudar { echo "Olá, $1"; }     # estilo com 'function' (menos portável)

saudar "Daniel"                          # chamada: argumentos como num script
```

Dentro da função, os parâmetros são `$1`, `$2`, `$#`, `"$@"` — **igual a um script**. Não há "assinatura" declarada; você recebe o que vier.

### Retorno: `return` (código) vs. `echo` (valor)

Esta é a parte que confunde quem vem de outras linguagens:

```bash
# return devolve um CÓDIGO DE SAÍDA (0–255), não um valor!
eh_par() {
    (( $1 % 2 == 0 ))      # a própria expressão já define o código de saída
}
if eh_par 4; then echo "par"; fi

# Para "retornar" um VALOR, imprima no stdout e capture com $(...)
dobro() {
    echo $(( $1 * 2 ))
}
resultado=$(dobro 21)     # resultado=42
```

| Para devolver… | Use | Capture com |
|---|---|---|
| sucesso/fracasso (0–255) | `return N` | `if funcao; then` / `$?` |
| um valor (texto/número) | `echo`/`printf` | `var=$(funcao)` |

### Escopo: `local` é quase obrigatório

Por padrão, **todas as variáveis são globais** no Bash — até dentro de funções. Isso causa bugs silenciosos. Use `local`:

```bash
contador() {
    local i                   # 'i' só existe dentro da função
    for (( i=0; i<3; i++ )); do echo "$i"; done
}
i="importante"
contador
echo "$i"                     # ainda "importante" — a função não o estragou
```

> ⚠️ **Sem `local`, uma variável `i` dentro de uma função sobrescreve a `i` de fora.** Em scripts grandes isso vira um pesadelo de depuração. Regra: **toda** variável interna de função é `local`.

> 💡 Idioma para "retornar por referência" (evita subshell): passe o **nome** de uma variável e use `local -n` (nameref, Bash 4.3+):
> ```bash
> preencher() { local -n ref=$1; ref="valor"; }
> preencher resultado; echo "$resultado"
> ```

## 4. A armadilha do subshell (pipe + while/read)

Um dos bugs mais famosos do Bash:

```bash
contador=0
echo -e "a\nb\nc" | while read -r linha; do
    (( contador++ ))           # incrementa... mas num SUBSHELL
done
echo "$contador"               # imprime 0!  😱
```

**Por quê?** Cada lado de um `|` roda num **subshell** separado. O `while` altera `contador` dentro do subshell, que morre ao fim do pipe, levando a mudança junto.

**Soluções:**
```bash
# 1. Redirecionar em vez de usar pipe (sem subshell):
contador=0
while read -r linha; do (( contador++ )); done < <(echo -e "a\nb\nc")
echo "$contador"               # 3 ✔   (o < <(...) é "process substitution", Módulo 09)

# 2. Ler de um arquivo/here-string:
while read -r linha; do (( contador++ )); done <<< $'a\nb\nc'
```

## 5. Boas práticas de funções

- **Pequenas**: uma função, uma responsabilidade.
- **Nomes claros**: `validar_email`, não `check`.
- **`local` em tudo**: sem vazamento de variáveis.
- **Documente**: um comentário dizendo o que entra (`$1`, `$2`) e o que sai.
- **Retorne cedo**: `[[ -z "$1" ]] && return 1` no topo evita aninhamento.

```bash
# Valida um CEP no formato 00000-000. Retorna 0 se válido.
validar_cep() {
    local cep="$1"
    [[ "$cep" =~ ^[0-9]{5}-[0-9]{3}$ ]]
}
```

---

## 🧪 Exemplos deste módulo

| Arquivo | Demonstra |
|---|---|
| [01-arrays.sh](exemplos/01-arrays.sh) | Indexados e associativos: criar, iterar, contar, fatiar |
| [02-funcoes.sh](exemplos/02-funcoes.sh) | Parâmetros, `return` vs `echo`, `local`, nameref |
| [03-armadilha-subshell.sh](exemplos/03-armadilha-subshell.sh) | O bug do `pipe \| while read` e as duas soluções |

## ⚠️ Armadilhas do módulo

- `${arr[@]}` sem aspas quebrando elementos com espaço
- Esquecer `declare -A` num array associativo (vira indexado!)
- Confundir `return` (código) com "retornar valor" (é `echo`)
- Não usar `local` e uma função estragar variável de fora
- `cmd | while read` e perder as alterações (subshell)

## 🏋️ Exercícios

Veja [exercicios/README.md](exercicios/README.md). Corrija com `./ferramentas/corrigir.sh 06`.

## ✅ Checklist de domínio

- [ ] Itero um array com `for x in "${arr[@]}"`
- [ ] Uso `declare -A` e conto ocorrências com array associativo
- [ ] Sei quando usar `return` e quando usar `echo` numa função
- [ ] Marco variáveis internas como `local` por reflexo
- [ ] Explico por que `cmd | while read var` perde `var`

---

⬅️ [Módulo 05](../05-texto-e-dados/README.md) · ➡️ [Módulo 07 — Scripts Robustos](../07-scripts-robustos/README.md)

<sub>© 2026 Prof. Daniel Santos · Conteúdo [CC BY-NC-SA 4.0](../../LICENSE-CONTEUDO.md) · Código [PolyForm NC](../../LICENSE)</sub>
