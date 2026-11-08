# 🔧 Tabela de expansões de parâmetros

A "expansão de parâmetros" é a superpotência do Bash para manipular strings **sem chamar programas externos** (nada de `sed`/`cut` para coisas simples). Veja o [Módulo 05](../modulos/05-texto-e-dados/).

Base para os exemplos: `arquivo="/home/daniel/foto.backup.jpg"` · `vazia=""` · `nome="Daniel Santos"`

## Valores padrão

| Expansão | O que faz | Exemplo → resultado |
|---|---|---|
| `${v:-pad}` | usa `pad` se `v` vazia/indefinida (não altera `v`) | `${vazia:-sem nome}` → `sem nome` |
| `${v:=pad}` | idem **e atribui** `pad` a `v` | `${vazia:=X}` → `X` (e agora `vazia=X`) |
| `${v:?msg}` | aborta com erro `msg` se vazia/indefinida | `${vazia:?faltou}` → erro |
| `${v:+alt}` | usa `alt` **se** `v` tiver valor | `${nome:+ok}` → `ok` |

## Comprimento e fatias

| Expansão | Resultado |
|---|---|
| `${#nome}` | `14` (número de caracteres) |
| `${nome:0:6}` | `Daniel` (do índice 0, 6 chars) |
| `${nome:7}` | `Santos` (do índice 7 até o fim) |
| `${nome: -6}` | `Santos` (espaço antes do `-`: últimos 6) |

## Remover prefixo / sufixo (ótimo para caminhos)

| Expansão | Remove | Exemplo → resultado |
|---|---|---|
| `${arquivo#*/}` | **menor** prefixo que casa `*/` | `home/daniel/foto.backup.jpg` |
| `${arquivo##*/}` | **maior** prefixo — vira o **basename** | `foto.backup.jpg` |
| `${arquivo%.*}` | **menor** sufixo `.* ` — tira a última extensão | `/home/daniel/foto.backup` |
| `${arquivo%%.*}` | **maior** sufixo — tira **todas** as extensões | `/home/daniel/foto` |
| `${arquivo%/*}` | tira do último `/` — vira o **dirname** | `/home/daniel` |

> 💡 Mnemônico: `#` fica à **esquerda** do `$` no teclado (mexe no **início**); `%` fica à **direita** (mexe no **fim**). Dobrar o símbolo = guloso (casa o máximo).

## Substituir

| Expansão | O que faz |
|---|---|
| `${v/a/b}` | troca a **primeira** ocorrência de `a` por `b` |
| `${v//a/b}` | troca **todas** |
| `${v/#a/b}` | troca só se `a` estiver no **começo** |
| `${v/%a/b}` | troca só se `a` estiver no **fim** |
| `${v//a/}` | **remove** todas as ocorrências de `a` |

## Maiúsculas / minúsculas (Bash 4+)

| Expansão | Resultado para `nome="Daniel Santos"` |
|---|---|
| `${nome^^}` | `DANIEL SANTOS` |
| `${nome,,}` | `daniel santos` |
| `${nome^}` | `Daniel Santos` (só a 1ª letra) |
| `${nome,}` | `daniel Santos` |

## Indireção e listagem

| Expansão | O que faz |
|---|---|
| `${!prefixo*}` | nomes de variáveis que começam com `prefixo` |
| `ref=nome; ${!ref}` | valor da variável **cujo nome** está em `ref` (indireção) |

## Exemplo prático: trocar extensão

```bash
arq="relatorio.txt"
echo "${arq%.txt}.pdf"      # relatorio.pdf  (sem sed!)

caminho="/var/log/sys.log"
echo "${caminho##*/}"       # sys.log   (basename)
echo "${caminho%/*}"        # /var/log  (dirname)
nome="${caminho##*/}"; echo "${nome%.*}"   # sys  (sem pasta, sem extensão)
```

<sub>© 2026 Prof. Daniel Santos · CC BY-NC-SA 4.0</sub>
