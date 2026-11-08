# Módulo 07 — Scripts Robustos

> *"A diferença entre um script e uma ferramenta é o que acontece quando algo dá errado. Produção é onde os scripts frágeis vão morrer."*

**Carga sugerida:** 6–8 h · **Nível:** intermediário+ · **Pré-requisito:** [Módulo 06](../06-arrays-e-funcoes/)

## 🎯 Objetivos

- Usar códigos de saída com significado
- Entender e aplicar `set -euo pipefail` (e saber quando **não** usar)
- Capturar sinais e limpar recursos com `trap`
- Depurar scripts com `set -x`, `PS4` e logging
- Escrever o "cabeçalho de segurança" que todo script sério tem

---

## 1. Códigos de saída

Todo comando devolve um número (0–255) acessível em `$?`. **0 = sucesso**, resto = erro.

```bash
grep "x" arquivo
echo "$?"            # 0 se achou, 1 se não achou, 2 se erro de uso
```

No seu script, retorne códigos com significado:

```bash
exit 0      # sucesso
exit 1      # erro genérico
exit 2      # erro de uso (argumentos errados) — convenção comum
exit 127    # "command not found" (o shell usa este)
```

> 💡 Convenção: códigos 1–125 são seus; 126 (não executável), 127 (não encontrado), 128+N (morto pelo sinal N) são reservados pelo shell. Documente os seus no cabeçalho.

```bash
if ! comando_critico; then
    echo "erro: comando_critico falhou" >&2   # erros vão para o stderr!
    exit 1
fi
```

## 2. O "modo estrito": `set -euo pipefail`

Três opções que transformam falhas silenciosas em paradas visíveis. É o começo de quase todo script profissional.

```bash
set -euo pipefail
```

| Opção | Faz | Protege contra |
|---|---|---|
| `set -e` (errexit) | aborta se um comando retorna ≠ 0 | continuar depois de um erro grave |
| `set -u` (nounset) | aborta ao usar variável não definida | `rm -rf "$DIR/"` com `$DIR` vazio e erros de digitação |
| `set -o pipefail` | um pipe falha se **qualquer** parte falhar | `cmd_que_falha \| tee log` esconder o erro |

```bash
#!/usr/bin/env bash
set -euo pipefail

arquivo="$1"           # com set -u, se não vier $1, o script já para aqui
processar "$arquivo"   # com set -e, se 'processar' falhar, para aqui
```

### ⚠️ `set -e` tem armadilhas — saiba as principais

`set -e` é útil, mas tem cantos traiçoeiros:

```bash
# 1. Comandos em teste NÃO abortam (o -e é suspenso em if/while/&&/||):
if comando_que_falha; then ...; fi      # ok, não aborta

# 2. Isto NÃO aborta mesmo com erro (o && "trata" o status):
comando_que_falha && echo "ok"

# 3. Funções e 'local' mascaram o status:
x=$(local v=$(cmd_que_falha))           # o 'local' engole o erro

# 4. Contadores podem te derrubar:
contador=0
(( contador++ ))        # retorna 0 (valor ANTES), status 1 → ABORTA com set -e! 💥
(( ++contador ))        # pré-incremento retorna 1, status 0 → seguro
```

> 💡 Por isso há quem prefira **não** usar `set -e` e checar erros explicitamente com `|| { ... }`. Uma regra equilibrada: use `set -euo pipefail` como padrão, mas conheça essas armadilhas e trate os comandos que "podem falhar de propósito" com `|| true` ou dentro de `if`.

```bash
comando_que_pode_falhar || true     # "não quero que isto aborte o script"
```

## 3. `trap` — capturar sinais e limpar

`trap` registra um comando para rodar quando um sinal chega ou o script termina. O uso nº 1: **garantir limpeza** (arquivos temporários, locks) aconteça o que acontecer.

```bash
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT          # roda ao SAIR, por qualquer motivo
# ... use $tmp à vontade; será apagado mesmo se o script falhar ou for morto
```

| Sinal / evento | Dispara quando… |
|---|---|
| `EXIT` | o script termina (sucesso, erro, ou `exit`) — **o mais usado** |
| `ERR` | um comando falha (com `set -e`) |
| `INT` | Ctrl+C |
| `TERM` | `kill` padrão |
| `HUP` | terminal fechou |

```bash
limpar() {
    echo "limpando recursos..." >&2
    rm -f "$lock"
}
trap limpar EXIT INT TERM           # uma função de limpeza para vários eventos

trap 'echo "recebi Ctrl+C, saindo"; exit 130' INT
```

> 💡 Ponha o `trap ... EXIT` **logo após** criar o recurso temporário, não no fim do script. Assim, se algo falhar no meio, a limpeza já está registrada. (A tabela completa de sinais está em [referencia/tabela-sinais.md](../../referencia/tabela-sinais.md).)

## 4. Depuração

```bash
bash -x script.sh          # mostra cada comando ANTES de executar (trace)
bash -n script.sh          # só checa a sintaxe, sem executar
set -x; comando; set +x    # liga o trace só para um trecho suspeito
```

Personalize o prefixo do trace com `PS4` para ver **onde** está:

```bash
export PS4='+ ${BASH_SOURCE}:${LINENO}: '   # mostra arquivo:linha em cada passo
bash -x script.sh
```

Técnica simples e eficaz — "printf debugging" direcionado ao stderr:
```bash
depurar() { [[ "${DEBUG:-}" == 1 ]] && echo "DEBUG: $*" >&2; }
depurar "valor de x = $x"        # só aparece se você rodar com DEBUG=1 ./script
```

## 5. Logging com timestamp

```bash
log() {
    printf '%(%Y-%m-%d %H:%M:%S)T [%s] %s\n' -1 "${1}" "${2}" >&2
}
log INFO "iniciando backup"
log ERRO "disco cheio"
```

Ou use o `logger` do sistema (vai para o syslog/journald):
```bash
logger -t meu-script "backup concluído"     # aparece em journalctl -t meu-script
```

Redirecionar todo o script para um log, mantendo a tela:
```bash
exec > >(tee -a /var/log/meu-script.log) 2>&1   # tudo vai para tela E arquivo
```

## 6. O cabeçalho de segurança padrão

Comece todo script sério assim:

```bash
#!/usr/bin/env bash
#
# nome-do-script — o que ele faz
# Uso: nome-do-script [opções] <argumento>
#
set -euo pipefail

# Falhar com mensagem e código
erro() { echo "erro: $*" >&2; exit 1; }

# Limpeza garantida
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

# Validação de entrada
[[ $# -ge 1 ]] || erro "uso: $0 <arquivo>"
[[ -f "$1" ]]  || erro "arquivo não encontrado: $1"

# ... o trabalho de verdade ...
```

---

## 🧪 Exemplos deste módulo

| Arquivo | Demonstra |
|---|---|
| [01-modo-estrito.sh](exemplos/01-modo-estrito.sh) | O efeito de `set -e`, `set -u`, `pipefail` (e a armadilha do `(( ))`) |
| [02-trap-limpeza.sh](exemplos/02-trap-limpeza.sh) | `trap ... EXIT` garantindo limpeza mesmo após erro |
| [03-logging-e-debug.sh](exemplos/03-logging-e-debug.sh) | Função de log com timestamp e depuração condicional por `DEBUG` |

## ⚠️ Armadilhas do módulo

- `(( contador++ ))` abortar o script sob `set -e` (use `|| true` ou `++contador`)
- Mandar erros para o stdout em vez do stderr (`>&2`)
- Esquecer o `trap` e deixar lixo temporário (ou locks presos)
- Achar que `set -e` pega **todo** erro (não pega em `if`, `&&`, subshell de `$()`)
- `set -u` derrubar o script num `$1` ausente sem mensagem clara (valide antes)

## 🏋️ Exercícios

Veja [exercicios/README.md](exercicios/README.md). Corrija com `./ferramentas/corrigir.sh 07`.

## ✅ Checklist de domínio

- [ ] Escrevo o cabeçalho de segurança de cor
- [ ] Explico cada letra de `set -euo pipefail` e suas armadilhas
- [ ] Uso `trap ... EXIT` para limpeza logo após criar o recurso
- [ ] Mando erros para o stderr e uso códigos de saída com significado
- [ ] Depuro com `bash -x` e `PS4`

---

⬅️ [Módulo 06](../06-arrays-e-funcoes/README.md) · ➡️ [Módulo 08 — Qualidade e Testes](../08-qualidade-e-testes/README.md)

<sub>© 2026 Prof. Daniel Santos · Conteúdo [CC BY-NC-SA 4.0](../../LICENSE-CONTEUDO.md) · Código [MIT](../../LICENSE)</sub>
