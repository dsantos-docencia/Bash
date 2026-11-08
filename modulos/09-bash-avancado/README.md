# Módulo 09 — Bash Avançado

> *"Aqui estão os recursos que separam quem 'sabe Bash' de quem 'domina Bash'. Raramente necessários — mas quando são, nada mais resolve tão bem."*

**Carga sugerida:** 8–10 h · **Nível:** avançado · **Pré-requisito:** [Módulo 08](../08-qualidade-e-testes/)

## 🎯 Objetivos

- Entender subshells `( )` vs. agrupamento `{ }`
- Usar **process substitution** `<(...)` e `>(...)`
- Dominar **here-documents** e **here-strings**
- Manipular **descritores de arquivo** (fd 3–9) diretamente
- Criar **FIFOs** (named pipes) com `mkfifo`

---

## 1. Subshell `( )` vs. agrupamento `{ }`

Ambos agrupam comandos, mas com uma diferença crucial de **ambiente**:

```bash
( cd /tmp; pwd )        # subshell: roda num processo FILHO
pwd                     # ← você continua na pasta original! o cd não "vazou"

{ cd /tmp; pwd; }       # agrupamento: roda no shell ATUAL
pwd                     # ← agora você ESTÁ em /tmp
```

| | `( ... )` | `{ ...; }` |
|---|---|---|
| Processo | **novo** (subshell) | o atual |
| `cd`, variáveis | ficam contidos | afetam o shell |
| Sintaxe | parênteses | chaves + **`;`** antes do `}` e espaços internos |
| Uso | isolar efeitos | agrupar redirecionamentos sem isolar |

```bash
# Redirecionar a saída de VÁRIOS comandos de uma vez:
{ echo "cabeçalho"; cat dados; echo "rodapé"; } > relatorio.txt
```

> 💡 Toda vez que você usa `$(...)` ou um pipe, há subshells envolvidos. É por isso que variáveis alteradas lá dentro não sobrevivem (a armadilha do Módulo 06).

## 2. Process substitution `<(...)` e `>(...)`

Transforma a **saída de um comando** num "arquivo" temporário que outro comando pode ler — sem criar arquivo de verdade.

```bash
# Comparar a saída de dois comandos sem arquivos intermediários:
diff <(ls dir1) <(ls dir2)

# Alimentar um 'while read' sem o subshell do pipe (Módulo 06):
while read -r linha; do
    echo ">> $linha"
done < <(grep erro log.txt)          # note: < <(...) com espaço

# >(...) manda a saída PARA um comando:
echo "mensagem" > >(logger -t meuapp)
comando 2> >(grep -v ruido >&2)      # filtra o stderr ao vivo
```

> 💡 `<(cmd)` vira um caminho tipo `/dev/fd/63` que contém a saída de `cmd`. É o jeito elegante de passar "saída de comando" onde se espera "arquivo", e a forma correta de evitar o subshell do `|` num `while read`.

## 3. Here-documents e here-strings

### Here-document `<<` — blocos de texto

```bash
cat <<FIM
Linha 1
Usuário atual: $USER        ← variáveis expandem
Data: $(date +%F)           ← comandos expandem
FIM

cat <<'FIM'
Aqui NADA expande: $USER e $(date) saem literais.
(aspas simples no delimitador = texto cru)
FIM

cat <<-FIM
	As tabulações iniciais são removidas (só TABs, não espaços),
	permitindo indentar o here-doc junto com o código.
	FIM
```

| Forma | Expande variáveis? | Uso |
|---|---|---|
| `<<FIM` | ✅ sim | gerar config/texto com valores |
| `<<'FIM'` | ❌ não (literal) | texto que tem `$` de verdade (ex.: outro script) |
| `<<-FIM` | depende | permite indentar com TABs |

Uso típico: gerar arquivos de configuração dentro de um script.
```bash
cat > /etc/meuapp.conf <<CONF
porta=$PORTA
log=/var/log/meuapp.log
CONF
```

### Here-string `<<<` — uma linha só

```bash
grep "x" <<< "$variavel"        # alimenta o stdin com o conteúdo da variável
read -ra campos <<< "a b c"     # divide uma string
bc <<< "2 + 2"                  # 4
```

## 4. Descritores de arquivo (fd)

Você já conhece 0 (stdin), 1 (stdout), 2 (stderr). O Bash deixa você abrir mais (3 a 9) para I/O avançado.

```bash
exec 3> saida.log          # abre o fd 3 para ESCRITA no arquivo
echo "só no log" >&3       # escreve via fd 3
exec 3>&-                  # fecha o fd 3

exec 4< entrada.txt        # abre o fd 4 para LEITURA
read -r linha <&4          # lê uma linha do fd 4
exec 4<&-                  # fecha

# Trocar/duplicar canais:
comando 3>&1 1>&2 2>&3 3>&-   # troca stdout e stderr
```

> 💡 Descritores extras são úteis quando você precisa ler de um arquivo **e** interagir com o usuário ao mesmo tempo, ou manter um log aberto durante todo o script sem reabrir a cada escrita.

```bash
# Ler um arquivo linha a linha mantendo o stdin livre para perguntar ao usuário:
exec 3< lista.txt
while read -r item <&3; do
    read -rp "Processar $item? [s/n] " resp   # usa o stdin normal (teclado)
    [[ "$resp" == s ]] && echo "ok: $item"
done
exec 3<&-
```

## 5. FIFOs (named pipes)

Um pipe `|` é anônimo e some ao fim do comando. Um **FIFO** é um pipe com **nome** no sistema de arquivos — dois processos independentes podem se comunicar por ele.

```bash
mkfifo /tmp/meu_cano            # cria o FIFO
# Terminal 1:
cat < /tmp/meu_cano            # bloqueia, esperando dados
# Terminal 2:
echo "olá pelo cano" > /tmp/meu_cano   # o Terminal 1 recebe e imprime
rm /tmp/meu_cano               # é um arquivo; remova quando terminar
```

Uso real: desacoplar um produtor de um consumidor, ou implementar filas simples entre scripts. Combine com `trap ... EXIT` para remover o FIFO ao sair.

---

## 🧪 Exemplos deste módulo

| Arquivo | Demonstra |
|---|---|
| [01-subshell-vs-grupo.sh](exemplos/01-subshell-vs-grupo.sh) | `( )` isola, `{ }` não — efeito no `cd` e em variáveis |
| [02-process-substitution.sh](exemplos/02-process-substitution.sh) | `diff <(...) <(...)` e `while read < <(...)` |
| [03-heredoc-e-fd.sh](exemplos/03-heredoc-e-fd.sh) | Here-doc com/sem expansão, here-string e descritores |

## ⚠️ Armadilhas do módulo

- Esquecer o `;` antes do `}` no agrupamento `{ ...; }`
- Confundir `( )` (isola) com `{ }` (não isola) e perder um `cd`
- `< <(...)` sem o espaço entre `<` e `<(` (vira here-doc malformado)
- Deixar um FIFO órfão no disco (use `trap` para remover)
- Esquecer de fechar descritores (`exec 3>&-`)

## 🏋️ Exercícios

Veja [exercicios/README.md](exercicios/README.md). Corrija com `./ferramentas/corrigir.sh 09`.

## ✅ Checklist de domínio

- [ ] Explico quando usar `( )` e quando usar `{ }`
- [ ] Comparo saídas com `diff <(...) <(...)`
- [ ] Gero um arquivo de config com here-doc
- [ ] Abro, uso e fecho um descritor extra
- [ ] Sei o que é um FIFO e quando usá-lo

---

⬅️ [Módulo 08](../08-qualidade-e-testes/README.md) · ➡️ [Módulo 10 — Sistema, Processos e Rede](../10-sistema-processos-rede/README.md)

<sub>© 2026 Prof. Daniel Santos · Conteúdo [CC BY-NC-SA 4.0](../../LICENSE-CONTEUDO.md) · Código [PolyForm NC](../../LICENSE)</sub>
