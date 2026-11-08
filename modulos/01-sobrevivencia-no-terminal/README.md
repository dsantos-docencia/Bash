# Módulo 01 — Sobrevivência no Terminal

> *"Antes de automatizar, você precisa conseguir andar pela casa no escuro."*

**Carga sugerida:** 6–8 h · **Nível:** iniciante · **Pré-requisito:** [Módulo 00](../00-boas-vindas-e-fundamentos/)

## 🎯 Objetivos

- Navegar pelo sistema de arquivos com confiança (caminhos absolutos e relativos)
- Criar, copiar, mover e apagar arquivos e diretórios — e entender por que `rm` é perigoso
- Ler o conteúdo de arquivos de várias formas
- Encontrar arquivos com `find` e `locate`
- Entender e manipular **permissões** (o modelo `rwx`) — a causa nº 1 de "permission denied"
- Diferenciar hard links de links simbólicos

---

## 1. O mapa: estrutura de diretórios do Linux

No Linux **tudo é um arquivo** e tudo pendura numa única árvore que começa na raiz `/`. Não há "C:" e "D:"; um pendrive aparece *dentro* da árvore (em `/media`, por exemplo).

```
/
├── bin   → programas essenciais (ls, cp, bash)
├── etc   → arquivos de CONFIGURAÇÃO do sistema (texto puro!)
├── home  → pastas pessoais dos usuários (/home/daniel)
├── root  → pasta pessoal do superusuário (root)
├── tmp   → arquivos temporários (apagados no boot)
├── usr   → programas e dados dos usuários (/usr/bin, /usr/share)
├── var   → dados que VARiam: logs (/var/log), filas, caches
├── dev   → dispositivos (/dev/sda, /dev/null)
├── proc  → "arquivos" virtuais do kernel (/proc/cpuinfo)
└── mnt, /media → pontos de montagem (pendrives, discos)
```

> 💡 Quer saber para que serve cada pasta? `man hier` descreve a hierarquia inteira. É um padrão chamado **FHS** (Filesystem Hierarchy Standard).

## 2. Onde estou e para onde vou

| Comando | Faz | Exemplo |
|---|---|---|
| `pwd` | *print working directory* — mostra onde você está | `/home/daniel` |
| `cd caminho` | entra num diretório | `cd /var/log` |
| `cd` (sozinho) | volta para sua `$HOME` | |
| `cd -` | volta ao diretório **anterior** | alterna entre dois |
| `cd ..` | sobe um nível | |
| `ls` | lista o conteúdo | |

### Caminhos: absoluto vs. relativo

- **Absoluto** começa em `/`: `/home/daniel/projetos` — vale de qualquer lugar.
- **Relativo** parte de onde você está: `projetos/curso` — depende do `pwd`.

| Atalho | Significa |
|---|---|
| `~` | sua pasta pessoal (`/home/daniel`) |
| `.` | o diretório **atual** |
| `..` | o diretório **pai** |
| `-` | o diretório **anterior** (só com `cd`) |

```bash
cd ~/projetos          # /home/daniel/projetos
cd ../documentos       # sobe um e entra em documentos
./meu-script.sh        # "o script AQUI nesta pasta" — o . é obrigatório!
```

> ⚠️ Por que `./script` e não só `script`? Por **segurança**. O shell só procura programas nas pastas do `PATH`. Se o diretório atual estivesse no PATH, um arquivo malicioso chamado `ls` na sua pasta poderia ser executado sem querer. O `./` diz explicitamente "este aqui".

## 3. Listando com `ls` — as opções que importam

```bash
ls              # nomes, em colunas
ls -l           # formato longo: permissões, dono, tamanho, data
ls -a           # mostra ocultos (os que começam com .)
ls -h           # tamanhos legíveis (K, M, G) — combine: ls -lh
ls -t           # ordena por data de modificação (mais novo primeiro)
ls -R           # recursivo (entra nas subpastas)
ls -la          # o combo clássico: tudo, formato longo
```

Lendo uma linha do `ls -l`:
```
-rw-r--r-- 1 daniel daniel 4096 nov  7 23:14 notas.txt
│└┬┘└┬┘└┬┘   └──┬─┘ └──┬─┘  └┬─┘ └────┬────┘ └───┬──┘
│ │  │  │      dono  grupo  tam.    data       nome
│ │  │  └ outros podem: ler
│ │  └ grupo pode: ler
│ └ dono pode: ler, escrever
└ tipo: - arquivo, d diretório, l link
```

## 4. Criando e destruindo

| Comando | Faz | Cuidado |
|---|---|---|
| `mkdir pasta` | cria diretório | `mkdir -p a/b/c` cria a cadeia toda |
| `touch arq` | cria arquivo vazio (ou atualiza a data) | |
| `cp orig dest` | copia | `cp -r` para diretórios; `cp -i` pergunta antes de sobrescrever |
| `mv orig dest` | move **ou renomeia** | `mv -i` pergunta antes de sobrescrever |
| `rm arq` | **apaga** (não vai para lixeira!) | veja abaixo 🔥 |
| `rmdir pasta` | remove diretório **vazio** | seguro, por isso existe |

### 🔥 O perigo do `rm`

No terminal **não existe lixeira**. `rm` apaga para sempre.

```bash
rm arquivo.txt          # apaga o arquivo
rm -r pasta/            # apaga pasta e TODO o conteúdo (recursivo)
rm -f arquivo           # força, sem perguntar
rm -rf pasta/           # recursivo + força = a combinação mais perigosa do Unix
```

> 🔥 **`rm -rf /` ou `rm -rf ~` podem destruir seu sistema inteiro.** Erros clássicos:
> - `rm -rf $PASTA/` com `$PASTA` vazia vira `rm -rf /`
> - Um espaço a mais: `rm -rf / home/lixo` (note o espaço depois de `/`)
>
> **Proteções que todo profissional usa:**
> - `alias rm='rm -i'` no `~/.bashrc` (pergunta antes de cada remoção)
> - Preferir mover para uma lixeira: a ferramenta `trash-cli`
> - **Sempre** testar com `ls` o que o glob vai pegar antes de `rm`: troque `rm` por `echo rm` e veja o que apareceria.

## 5. Lendo arquivos

| Comando | Melhor para |
|---|---|
| `cat arq` | arquivos curtos; junta vários (`cat a b > c`) |
| `less arq` | arquivos longos — navegação com `/`, setas, `q` para sair |
| `head arq` | primeiras 10 linhas (`head -n 5`, `head -c 100`) |
| `tail arq` | últimas 10 linhas |
| `tail -f log` | **acompanha** um log em tempo real (ótimo para `/var/log`) |
| `wc arq` | conta linhas (`-l`), palavras (`-w`), bytes (`-c`) |

```bash
tail -f /var/log/syslog    # vê o log crescer ao vivo — Ctrl+C para parar
wc -l *.txt                # conta linhas de cada .txt
```

## 6. Encontrando arquivos

| Comando | Como funciona | Quando usar |
|---|---|---|
| `find` | **percorre** o disco agora, lento mas preciso e poderoso | buscas por nome, tamanho, data, e **executar** ações |
| `locate` | consulta um **banco pré-indexado**, instantâneo | achar rápido por nome (pode estar desatualizado; `updatedb` atualiza) |
| `which cmd` | onde está o executável de um comando | `which bash` → `/usr/bin/bash` |
| `type cmd` | classifica o comando (builtin? alias? arquivo?) | sempre o 1º passo |

```bash
find . -name "*.log"              # .log a partir da pasta atual (recursivo)
find /etc -type f -name "*.conf"  # só arquivos (-type f), .conf em /etc
find . -type d -name "cache"      # só diretórios
find . -size +10M                 # maiores que 10 MB
find . -mtime -7                  # modificados nos últimos 7 dias
find . -name "*.tmp" -delete      # ACHA e APAGA (cuidado!)
find . -name "*.sh" -exec chmod +x {} \;   # torna executável cada .sh achado
```

> 💡 `find` é um minicanivette suíço. O `{}` é substituído por cada arquivo encontrado, e o `\;` encerra o `-exec`. Teste sempre sem o `-delete`/`-exec` primeiro, só para ver a lista.

## 7. Permissões: o modelo `rwx`

Todo arquivo tem **dono**, **grupo** e permissões para três classes de gente: o **dono** (u), o **grupo** (g) e os **outros** (o).

```
  rwx r-x r--
  └┬┘ └┬┘ └┬┘
 dono grupo outros
```

Cada classe tem 3 bits:
| Letra | Em arquivo | Em diretório |
|---|---|---|
| `r` (read, 4) | ler o conteúdo | listar o conteúdo |
| `w` (write, 2) | alterar o conteúdo | criar/apagar arquivos dentro |
| `x` (execute, 1) | executar | **entrar** (`cd`) nele |

> 💡 Num diretório, `x` sem `r` deixa você entrar mas não listar; `r` sem `x` deixa "ver o nome" mas não usar. Por isso diretórios quase sempre são `rwx` (7) ou `r-x` (5).

### `chmod` — mudando permissões

**Modo octal** (some os valores de cada classe):
```bash
chmod 755 script.sh   # dono rwx(7), grupo r-x(5), outros r-x(5) — típico de programa
chmod 644 nota.txt    # dono rw-(6), grupo r--(4), outros r--(4) — típico de arquivo
chmod 600 segredo     # só o dono lê e escreve — típico de chave/senha
chmod 700 ~/privado   # pasta só sua
```
| Octal | Binário | rwx |
|---|---|---|
| 7 | 111 | rwx |
| 6 | 110 | rw- |
| 5 | 101 | r-x |
| 4 | 100 | r-- |
| 0 | 000 | --- |

**Modo simbólico** (mais legível para mudanças pontuais):
```bash
chmod +x script.sh      # adiciona execução para todos
chmod u+x script.sh     # só para o dono (user)
chmod g-w arquivo       # tira escrita do grupo
chmod o= arquivo        # zera permissões dos outros
chmod a+r arquivo       # all (todos) podem ler
```

### Dono e grupo

```bash
chown daniel arquivo          # muda o dono (precisa de sudo)
chown daniel:dev arquivo      # muda dono e grupo
chgrp dev arquivo             # muda só o grupo
```

> ⚠️ "Permission denied" quase sempre é: (a) falta de `x` num script → `chmod +x`; (b) falta de permissão no arquivo/pasta → confira com `ls -l`; (c) precisa de `sudo` para arquivos do sistema.

## 8. Links: dois nomes para o mesmo dado

```bash
ln arquivo apelido          # HARD link: outro nome para o MESMO dado (mesmo inode)
ln -s alvo atalho           # SOFT link (simbólico): um "atalho" que aponta para um caminho
```

| | Hard link | Soft link (simbólico) |
|---|---|---|
| Aponta para | o **dado** (inode) | um **caminho** (texto) |
| Se o original é apagado | continua funcionando | **quebra** (aponta para o nada) |
| Atravessa sistemas de arquivos | não | sim |
| Pode apontar para diretório | não | sim |
| Uso típico | raro | **atalhos, versões "current"** |

```bash
ls -l atalho     # mostra:  atalho -> alvo
readlink atalho  # mostra para onde o link aponta
```

---

## 🧪 Exemplos deste módulo

| Arquivo | Demonstra |
|---|---|
| [01-navegacao.sh](exemplos/01-navegacao.sh) | `pwd`, `cd`, caminhos absolutos/relativos, `~ . .. -` num lab temporário |
| [02-permissoes.sh](exemplos/02-permissoes.sh) | Octal vs. simbólico, efeito real de cada bit |
| [03-find-na-pratica.sh](exemplos/03-find-na-pratica.sh) | Buscas por nome, tipo, tamanho e `-exec` |

## ⚠️ Armadilhas do módulo

- `rm -rf` com variável vazia ou espaço a mais
- Esquecer `-r` ao copiar/apagar diretórios
- Esquecer `chmod +x` e tomar "permission denied" ao rodar um script
- Confiar em `locate` logo após criar um arquivo (o índice pode estar velho)
- Apagar o original de um **soft link** e quebrar tudo que aponta para ele

## 🏋️ Exercícios

Veja [exercicios/README.md](exercicios/README.md). Corrija com `./ferramentas/corrigir.sh 01`.

## ✅ Checklist de domínio

- [ ] Sei a diferença entre caminho absoluto e relativo
- [ ] Explico cada campo de `ls -l`
- [ ] Converto `rwxr-xr--` para `754` e vice-versa
- [ ] Uso `find` para localizar por nome, tipo e tamanho
- [ ] Sei quando um soft link vai quebrar

---

⬅️ [Módulo 00](../00-boas-vindas-e-fundamentos/README.md) · ➡️ [Módulo 02 — Fluxo de Dados](../02-fluxo-de-dados/README.md)

<sub>© 2026 Prof. Daniel Santos · Conteúdo [CC BY-NC-SA 4.0](../../LICENSE-CONTEUDO.md) · Código [MIT](../../LICENSE)</sub>
