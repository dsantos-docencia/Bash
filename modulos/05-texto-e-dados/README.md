# Módulo 05 — Manipulação de Texto e Dados

> *"No Unix, dados são texto, e texto é onde o Bash brilha. Logs, CSVs, configs — tudo é fluxo de caracteres esperando ser filtrado."*

**Carga sugerida:** 10–12 h · **Nível:** intermediário · **Pré-requisito:** [Módulo 04](../04-controle-de-fluxo/)

## 🎯 Objetivos

- Dominar o **trio de ouro**: `grep`, `sed`, `awk`
- Usar expressões regulares (ERE/PCRE) com segurança
- Fatiar e montar texto com `cut`, `paste`, `tr`, `sort`, `uniq`, `wc`
- Fazer manipulação de strings **sem sair do Bash** (expansão de parâmetros)
- Saber **quando** usar cada ferramenta (performance e legibilidade)

---

## 1. Expressões regulares em 5 minutos

Uma regex descreve um **padrão** de texto. É outra linguagem, diferente do glob do shell.

| Padrão | Casa |
|---|---|
| `.` | qualquer **um** caractere |
| `*` | zero ou mais do **anterior** |
| `+` | um ou mais (ERE) |
| `?` | zero ou um (ERE) |
| `^` | início da linha |
| `$` | fim da linha |
| `[abc]` | um entre a, b, c |
| `[^abc]` | um que **não** seja a, b, c |
| `[0-9]` | um dígito |
| `\{2,5\}` / `{2,5}` | de 2 a 5 repetições (BRE / ERE) |
| `\|` / `\|` | alternativa "ou" (ERE) |
| `( )` | agrupamento (ERE) |

> ⚠️ Há **dois dialetos**: BRE (básico, o padrão do `grep`/`sed`, exige `\` antes de `+ ? { } ( ) |`) e ERE (estendido, com `grep -E`/`sed -E`, sem as barras). **Dica:** use sempre `-E`; a sintaxe fica muito mais limpa.

```bash
grep -E '^[0-9]{3}-[0-9]{4}$' contatos   # linhas que são exatamente 123-4567
grep -E 'erro|falha|warn'      log        # qualquer uma das três palavras
```

## 2. `grep` — encontrar linhas

```bash
grep "texto" arquivo          # linhas que contêm "texto"
grep -i "erro" log            # ignora maiúsc/minúsc
grep -v "debug" log           # INVERTE: linhas que NÃO contêm
grep -n "TODO" *.sh           # mostra o número da linha
grep -r "função" src/         # recursivo em diretórios
grep -c "erro" log            # só conta quantas linhas casaram
grep -o 'https://[^ ]*' pág   # imprime só a PARTE que casou
grep -E 'cat|dog' arq         # regex estendida
grep -q "x" arq && echo achou # -q: silencioso, só o código de saída (para if)
```

| Opção | Faz |
|---|---|
| `-i` | ignora caixa |
| `-v` | inverte (não casa) |
| `-n` | número da linha |
| `-r` / `-R` | recursivo |
| `-c` | conta linhas |
| `-o` | só o trecho casado |
| `-E` | regex estendida (ERE) |
| `-q` | quieto (para usar em `if`) |
| `-w` | palavra inteira |

## 3. `sed` — editor de fluxo (substituir e editar)

O `sed` transforma texto que passa por ele. O uso mais comum (95%) é a substituição:

```bash
sed 's/antigo/novo/'  arq     # troca a 1ª ocorrência por linha
sed 's/antigo/novo/g' arq     # g = todas as ocorrências da linha
sed 's/erro/ERRO/gi'  arq     # g=todas, i=ignora caixa
sed -n '10,20p'       arq     # -n cala tudo; p imprime só linhas 10–20
sed '/debug/d'        arq     # apaga (d) linhas que casam /debug/
sed -E 's/([0-9]+)/[\1]/g'    # \1 = o que o 1º grupo () capturou
sed -i 's/v1/v2/g'    arq     # -i edita o arquivo NO LUGAR (cuidado!)
sed -i.bak 's/v1/v2/g' arq    # -i.bak edita e guarda backup arq.bak
```

> ⚠️ `sed -i` **altera o arquivo** sem pedir confirmação. Sempre teste sem o `-i` primeiro (vê o resultado na tela), e prefira `-i.bak` para ter uma rede de segurança.

> 💡 O separador do `s///` não precisa ser `/`. Para mexer em caminhos, use outro: `sed 's#/usr/local#/opt#g'` — evita escapar cada barra.

## 4. `awk` — processar colunas e relatórios

O `awk` é uma linguagem inteira, mas 90% do uso é: "para cada linha, faça algo com as colunas". Ele divide cada linha em campos `$1`, `$2`, … (`$0` é a linha toda).

```bash
awk '{print $1}'            arq   # 1ª coluna de cada linha
awk '{print $1, $3}'       arq   # 1ª e 3ª (a vírgula vira espaço)
awk -F: '{print $1}'  /etc/passwd # -F: usa ":" como separador
awk '$3 > 100'             arq   # linhas cuja 3ª coluna é > 100
awk 'NR==1 {print}'        arq   # NR = número da linha (só a 1ª)
awk 'END {print NR}'       arq   # ao final, imprime o total de linhas
awk '{soma += $2} END {print soma}' arq   # soma a 2ª coluna
awk -F, '{print $2}'       dados.csv       # CSV simples
```

| Variável do awk | É |
|---|---|
| `$1`, `$2`… | campos (colunas) |
| `$0` | a linha inteira |
| `NF` | número de campos na linha |
| `NR` | número da linha atual |
| `FS` / `-F` | separador de campos (entrada) |
| `BEGIN{}` / `END{}` | bloco antes / depois de processar tudo |

> 💡 **grep vs sed vs awk — qual usar?**
> - **grep**: só quero *filtrar* linhas (achar/excluir). O mais rápido.
> - **sed**: quero *transformar* texto (substituir, apagar linhas).
> - **awk**: quero trabalhar com *colunas*, *calcular*, gerar *relatório*.
> Para somar uma coluna de um arquivo grande, `awk` é muito mais rápido e legível que um `while read` em Bash.

## 5. Os utilitários de apoio

```bash
cut -d: -f1 /etc/passwd       # recorta: delimitador ":", campo 1
cut -c1-10 arq                # caracteres 1 a 10 de cada linha
sort arq                      # ordena (alfabético)
sort -n arq                   # numérico
sort -rn arq                  # numérico reverso
sort -u arq                   # ordena e remove duplicatas
uniq arq                      # remove duplicatas ADJACENTES (precisa sort antes)
uniq -c arq                   # conta ocorrências
tr 'a-z' 'A-Z' < arq          # traduz caracteres (minúsc → maiúsc)
tr -d ' ' < arq               # deleta caracteres (remove espaços)
tr -s ' ' < arq               # "squeeze": colapsa espaços repetidos
paste a.txt b.txt             # junta arquivos lado a lado (colunas)
tee arq                       # copia o stdin para a tela E para arq
wc -l arq                     # conta linhas (-w palavras, -c bytes)
```

O combo clássico de ranking (você já viu no Módulo 02):
```bash
cut -d' ' -f1 acesso.log | sort | uniq -c | sort -rn | head
```

## 6. Manipulação de strings **nativa** (sem chamar programas)

Para operações simples, a expansão de parâmetros do Bash é mais rápida que chamar `sed`/`cut` (não cria processo). Tabela completa em [referencia/tabela-expansoes.md](../../referencia/tabela-expansoes.md).

```bash
arq="/home/daniel/foto.jpg"
echo "${arq##*/}"      # foto.jpg      (basename — remove maior prefixo até /)
echo "${arq%/*}"       # /home/daniel  (dirname — remove do último / ao fim)
echo "${arq%.jpg}.png" # troca extensão → /home/daniel/foto.png
echo "${#arq}"         # comprimento

texto="Olá Mundo"
echo "${texto^^}"      # OLÁ MUNDO
echo "${texto,,}"      # olá mundo
echo "${texto/Mundo/Bash}"   # Olá Bash
echo "${texto:4:5}"    # fatia a partir do índice 4
```

> 💡 Regra prática: **uma troca simples num valor** → expansão de parâmetro. **Transformar um fluxo/arquivo inteiro** → `sed`/`awk`. Não chame `echo "$x" | sed ...` para algo que `${x/.../...}` resolve.

## 7. Globbing avançado (`shopt`)

```bash
shopt -s nullglob     # glob sem match vira VAZIO (em vez de literal)
shopt -s dotglob      # * passa a incluir arquivos ocultos (.algo)
shopt -s globstar     # ** casa recursivamente: **/*.sh
shopt -s extglob      # habilita padrões estendidos: ?(..) *(..) +(..) @(..) !(..)
```

```bash
shopt -s globstar
for f in **/*.sh; do echo "$f"; done   # todos os .sh em toda a árvore
```

---

## 🧪 Exemplos deste módulo

| Arquivo | Demonstra |
|---|---|
| [01-grep-sed-awk.sh](exemplos/01-grep-sed-awk.sh) | O trio de ouro resolvendo o mesmo log de três ângulos |
| [02-relatorio-csv.sh](exemplos/02-relatorio-csv.sh) | `awk` gerando um relatório a partir de um CSV |
| [03-strings-nativas.sh](exemplos/03-strings-nativas.sh) | Expansão de parâmetros vs. chamar `sed`/`cut` |

## ⚠️ Armadilhas do módulo

- Misturar dialetos de regex (BRE vs ERE) — prefira `-E` sempre
- `uniq` sem `sort` antes (ele só remove duplicatas **adjacentes**)
- `sed -i` sem backup destruindo um arquivo
- Chamar `sed`/`awk` para algo que `${var/.../...}` faz nativo
- Esquecer `shopt -s nullglob` e um glob virar texto literal

## 🏋️ Exercícios

Veja [exercicios/README.md](exercicios/README.md). Corrija com `./ferramentas/corrigir.sh 05`.

## ✅ Checklist de domínio

- [ ] Escrevo uma regex ERE simples (âncoras, classes, quantificadores)
- [ ] Escolho entre grep/sed/awk pelo tipo de tarefa
- [ ] Faço um relatório somando uma coluna com `awk`
- [ ] Extraio basename/dirname/extensão com expansão de parâmetro
- [ ] Uso `shopt` quando preciso (nullglob, globstar)

---

⬅️ [Módulo 04](../04-controle-de-fluxo/README.md) · ➡️ [Módulo 06 — Arrays e Funções](../06-arrays-e-funcoes/README.md)

<sub>© 2026 Prof. Daniel Santos · Conteúdo [CC BY-NC-SA 4.0](../../LICENSE-CONTEUDO.md) · Código [MIT](../../LICENSE)</sub>
