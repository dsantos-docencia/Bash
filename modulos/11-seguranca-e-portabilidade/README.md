# Módulo 11 — Segurança e Portabilidade

> *"O último passo para virar profissional: escrever scripts que não são apenas corretos, mas **seguros** e que **rodam em qualquer lugar**."*

**Carga sugerida:** 6–8 h · **Nível:** avançado · **Pré-requisito:** [Módulo 10](../10-sistema-processos-rede/)

## 🎯 Objetivos

- Reconhecer e evitar as armadilhas clássicas que destroem dados
- Escrever scripts **seguros**: validar entrada, evitar `eval`, usar `mktemp`
- Entender injeção de comandos e como preveni-la
- Saber a diferença entre Bash, POSIX `sh` e zsh
- Escrever scripts portáveis quando necessário

Este módulo é sobre **defesa**: proteger o sistema de erros seus e proteger seu script de entradas maliciosas ou inesperadas.

---

## 1. As armadilhas clássicas (e como escapar delas)

### 1.1 Espaços em nomes de arquivo

```bash
# ❌ quebra se um arquivo tiver espaço no nome:
for f in $(ls *.txt); do rm $f; done

# ✔ use glob diretamente e cite:
for f in *.txt; do rm -- "$f"; done
```

### 1.2 `for f in $(ls)` — nunca

`ls` é para humanos. Para programas, use glob ou `find -print0`:
```bash
# ✔ nomes com qualquer caractere, inclusive quebra de linha:
find . -name '*.log' -print0 | while IFS= read -r -d '' f; do
    echo "processando: $f"
done
```

### 1.3 `rm -rf` com variável vazia 🔥

```bash
# 🔥 se $DIR estiver vazia, isto vira 'rm -rf /' !
rm -rf "$DIR/"

# ✔ proteções em camadas:
set -u                              # variável indefinida aborta o script
dir="${DIR:?a variável DIR é obrigatória}"   # aborta com mensagem se vazia
[[ -n "$dir" && -d "$dir" ]] || { echo "dir inválido" >&2; exit 1; }
rm -rf -- "$dir"
```

> 💡 O `--` diz "acabaram as opções": protege contra arquivos cujo nome começa com `-` (ex.: um arquivo chamado `-rf`).

### 1.4 `cd` que falha silenciosamente

```bash
# 🔥 se o cd falhar, os comandos seguintes rodam na pasta ERRADA:
cd "$dir"
rm -rf *

# ✔ pare se o cd falhar:
cd "$dir" || exit 1
rm -rf -- *
```

### 1.5 Variáveis não citadas em `[ ]`

```bash
# ❌ quebra se $resposta for vazia ou tiver espaço:
if [ $resposta = sim ]; then ...

# ✔ cite (ou use [[ ]], que é seguro):
if [[ "$resposta" == sim ]]; then ...
```

> 💡 O [ShellCheck](../08-qualidade-e-testes/) (Módulo 08) pega **todas** essas armadilhas automaticamente. Rode-o sempre. E a lista completa, canônica, está em [BashPitfalls](https://mywiki.wooledge.org/BashPitfalls).

## 2. Segurança em scripts

### 2.1 Nunca confie em entrada sem validar

Toda entrada (argumentos, variáveis de ambiente, conteúdo de arquivos, resposta de API) pode ser maliciosa ou simplesmente inesperada.

```bash
# Valide formato ANTES de usar:
[[ "$id" =~ ^[0-9]+$ ]]        || erro "id deve ser numérico"
[[ "$email" =~ ^[^@]+@[^@]+$ ]] || erro "email inválido"
[[ "$arquivo" != *..* ]]       || erro "caminho suspeito"   # evita path traversal
```

### 2.2 Injeção de comandos — a vulnerabilidade nº 1

Interpolar entrada do usuário dentro de um comando é como injeção de SQL:

```bash
# 🔥 PERIGOSO: se o usuário digitar  ; rm -rf ~  isso É EXECUTADO
nome="$1"
eval "echo Olá $nome"           # NUNCA faça isso com entrada externa

# 🔥 Também perigoso — montar comando por string:
comando="ls $diretorio_do_usuario"
$comando                        # word splitting + glob na entrada
```

```bash
# ✔ Trate dados como DADOS, não como código:
echo "Olá $nome"                # sem eval; a variável é só texto
ls -- "$diretorio_do_usuario"   # citado, com --
```

> ⚠️ **Regra:** entrada do usuário é **dado**, nunca **código**. Se você se pegar montando uma string de comando com dados externos, pare e repense.

### 2.3 Evite `eval`

`eval` executa uma string como código. 99% das vezes há uma alternativa melhor (arrays, nameref, `case`). Quando parece inevitável, provavelmente o desenho pode mudar.

```bash
# Em vez de eval para "variável dinâmica":
eval "valor=\$$nome_da_var"        # frágil e perigoso
# use indireção:
valor="${!nome_da_var}"            # seguro
# ou arrays associativos:
declare -A config; valor="${config[$chave]}"
```

### 2.4 Arquivos temporários seguros

```bash
# ❌ previsível: outro processo pode adivinhar/atacar o nome (race condition)
tmp="/tmp/meuscript.$$"

# ✔ mktemp cria um nome único e imprevisível, com permissões restritas:
tmp="$(mktemp)"                    # arquivo
tmpdir="$(mktemp -d)"              # diretório
trap 'rm -rf "$tmp" "$tmpdir"' EXIT
```

### 2.5 Menor privilégio e permissões

```bash
umask 077                          # arquivos novos só para o dono (rw-------)
chmod 600 "$arquivo_de_senha"      # restrinja segredos
# Rode como root só o estritamente necessário; valide antes:
[[ $EUID -eq 0 ]] && erro "não rode este script como root"
```

## 3. Bash vs. POSIX `sh` vs. zsh

| | Bash | POSIX `sh` (dash) | zsh |
|---|---|---|---|
| `[[ ]]`, `=~` | ✅ | ❌ | ✅ |
| Arrays | ✅ | ❌ | ✅ (mas índice começa em **1**!) |
| `local` | ✅ | ❌ (use só variáveis) | ✅ |
| `<<<`, `<(...)` | ✅ | ❌ | ✅ |
| `${var^^}` | ✅ | ❌ | diferente |
| Onipresença | muito alta | **universal** | média |

> ⚠️ **Por que isso importa:** em muitos sistemas `/bin/sh` **não é** o Bash (no Debian/Ubuntu é o `dash`, bem mais enxuto). Um script com `#!/bin/sh` que usa `[[ ]]` ou arrays **falha** nesses sistemas. E no macOS, o zsh tem diferenças sutis (arrays começam em 1).

## 4. Escrevendo scripts portáveis (POSIX)

Quando o script precisa rodar em **qualquer** Unix (containers Alpine, BSD, roteadores), escreva POSIX:

```sh
#!/bin/sh
# Portável: evite recursos só-do-Bash

# Use [ ] em vez de [[ ]], citando SEMPRE:
if [ "$x" = "sim" ]; then ...; fi

# Sem arrays — use parâmetros posicionais ou listas separadas por espaço:
set -- item1 item2 item3
for i in "$@"; do echo "$i"; done

# Sem <<<; use here-doc ou echo | :
grep x <<EOF
$variavel
EOF
```

O que **evitar** para portabilidade: `[[ ]]`, arrays, `local`, `<<<`, `<(...)`, `${var^^}`, `source` (use `.`), `function nome {`.

```bash
# Verifique a portabilidade com ShellCheck apontando o shell alvo:
shellcheck --shell=sh script.sh
set -o posix          # dentro do Bash, aproxima o comportamento POSIX
```

> 💡 **Regra prática:** se o script é seu e roda num ambiente que você controla (servidores Linux com Bash) → use Bash e aproveite `[[ ]]`, arrays etc. Se ele precisa rodar em qualquer lugar (distribuído, containers mínimos) → escreva POSIX `sh` e valide com `shellcheck --shell=sh`.

---

## 🧪 Exemplos deste módulo

| Arquivo | Demonstra |
|---|---|
| [01-armadilhas.sh](exemplos/01-armadilhas.sh) | Os erros clássicos lado a lado com a versão segura |
| [02-validar-entrada.sh](exemplos/02-validar-entrada.sh) | Validação e por que entrada é dado, não código |
| [03-portabilidade.sh](exemplos/03-portabilidade.sh) | O mesmo objetivo em Bash e em POSIX sh |

## ⚠️ Armadilhas do módulo

- `rm -rf "$DIR/"` com `$DIR` vazia (use `set -u` + `${DIR:?}`)
- `eval` ou `$comando` com entrada do usuário (injeção)
- Arquivo temporário com nome previsível (use `mktemp`)
- `#!/bin/sh` usando recursos do Bash (falha no dash)
- Esquecer o `--` e um arquivo chamado `-rf` virar opção

## 🏋️ Exercícios

Veja [exercicios/README.md](exercicios/README.md). Corrija com `./ferramentas/corrigir.sh 11`.

## ✅ Checklist de domínio

- [ ] Protejo `rm -rf` com `set -u`, validação e `--`
- [ ] Valido toda entrada antes de usar; trato dado como dado
- [ ] Evito `eval`; uso indireção/arrays no lugar
- [ ] Crio temporários com `mktemp` + `trap`
- [ ] Sei quando escrever Bash e quando escrever POSIX `sh`

---

⬅️ [Módulo 10](../10-sistema-processos-rede/README.md) · ➡️ [Projetos práticos](../../projetos/) · [Referência](../../referencia/)

<sub>© 2026 Prof. Daniel Santos · Conteúdo [CC BY-NC-SA 4.0](../../LICENSE-CONTEUDO.md) · Código [MIT](../../LICENSE)</sub>
