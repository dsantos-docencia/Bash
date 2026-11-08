# Módulo 10 — Sistema, Processos e Rede

> *"Agora o Bash deixa de brincar com texto e passa a controlar o servidor: processos, agendamento e a rede."*

**Carga sugerida:** 8–10 h · **Nível:** avançado · **Pré-requisito:** [Módulo 09](../09-bash-avancado/)

## 🎯 Objetivos

- Gerenciar processos: `ps`, `top`/`htop`, `kill`, sinais
- Controlar jobs: `&`, `jobs`, `fg`, `bg`, `nohup`, `disown`, `wait`
- Agendar tarefas com `cron`, `at` e `systemd` timers
- Interagir com a rede: `curl`, `wget`, `ssh`, `scp`, `rsync`
- Executar coisas em paralelo e esperar o resultado

---

## 1. Processos e sinais

```bash
ps aux                   # todos os processos (dono, PID, CPU, memória, comando)
ps aux | grep nginx      # filtra
pgrep -f nginx           # só os PIDs que casam
top                      # monitor interativo (q sai); htop é a versão melhorada
```

**Sinais** são mensagens enviadas a processos (tabela completa em [referencia/tabela-sinais.md](../../referencia/tabela-sinais.md)):

```bash
kill 1234                # envia SIGTERM (15): "termine, por favor"
kill -TERM 1234          # o mesmo, explícito
kill -9 1234             # SIGKILL: mata na marra (último recurso — não limpa)
kill -HUP 1234           # SIGHUP: muitos daemons recarregam config
pkill -f "python app"    # mata por nome/linha de comando
killall nginx            # mata todos os processos com esse nome
```

> ⚠️ Prefira **sempre** `SIGTERM` (15) antes de `SIGKILL` (9). O `TERM` deixa o processo salvar estado e sair limpo; o `KILL` corta a energia — pode corromper dados. Só use `-9` quando o processo ignora o `-15`.

Capturar sinais no seu script (revisão do Módulo 07):
```bash
trap 'echo "recebi SIGTERM, encerrando"; limpar; exit 0' TERM
trap 'echo "ignorando Ctrl+C"' INT
```

## 2. Controle de jobs (background/foreground)

```bash
comando_longo &          # roda em BACKGROUND; devolve o controle na hora
echo "$!"                # PID do último processo em background
jobs                     # lista os jobs desta sessão
fg %1                    # traz o job 1 para o FOREGROUND
bg %1                    # retoma o job 1 em background
# Ctrl+Z                 # SUSPENDE o job em foreground (depois: bg ou fg)
wait                     # espera TODOS os jobs em background terminarem
wait "$pid"              # espera um PID específico
```

### Sobreviver ao fechamento do terminal

Quando você fecha o terminal, seus processos recebem `SIGHUP` e morrem. Para evitar:

```bash
nohup comando_longo &            # ignora o HUP; saída vai para nohup.out
comando & disown                 # remove o job da lista (não recebe HUP)
```

> 💡 Para tarefas realmente longas, o profissional usa `tmux` ou `screen` (multiplexadores de terminal): a sessão continua no servidor mesmo se sua conexão SSH cair. `nohup`/`disown` são a solução rápida.

### Paralelismo simples

```bash
# Dispara 3 tarefas ao mesmo tempo e espera todas:
for alvo in servidor1 servidor2 servidor3; do
    verificar "$alvo" &          # cada uma em background
done
wait                             # só continua quando todas terminarem
echo "todas verificadas"
```

Para paralelismo com controle (N por vez), a ferramenta é o `xargs -P` ou o GNU `parallel`:
```bash
printf '%s\n' *.jpg | xargs -P4 -I{} convert {} {}.png   # 4 conversões por vez
```

## 3. Agendamento

### `cron` — tarefas recorrentes

```bash
crontab -e               # edita suas tarefas agendadas
crontab -l               # lista
```

Formato de uma linha do cron (5 campos de tempo + comando):
```
┌── minuto (0-59)
│ ┌── hora (0-23)
│ │ ┌── dia do mês (1-31)
│ │ │ ┌── mês (1-12)
│ │ │ │ ┌── dia da semana (0-7, 0 e 7 = domingo)
│ │ │ │ │
* * * * *  comando
```
```bash
0 2 * * *      /opt/backup.sh           # todo dia às 02:00
*/15 * * * *   /opt/checar.sh           # a cada 15 minutos
0 9 * * 1-5    /opt/relatorio.sh        # 09:00, de segunda a sexta
```

> ⚠️ **A armadilha nº 1 do cron: o PATH.** O cron roda com um ambiente **mínimo** (`PATH` curto, sem suas variáveis). Um script que "funciona no meu terminal" falha no cron porque não acha um comando ou uma variável. **Soluções:** use caminhos absolutos (`/usr/bin/python3`), defina `PATH` no topo do script, e redirecione a saída para um log (`>> /var/log/x.log 2>&1`) para enxergar os erros.

### `at` — uma vez só

```bash
echo "/opt/tarefa.sh" | at 22:00        # roda hoje às 22h, uma única vez
at now + 1 hour <<< "comando"           # daqui a 1 hora
atq                                     # lista; atrm N remove
```

### `systemd` timers — a alternativa moderna

Em sistemas com systemd, timers substituem o cron com vantagens (logs no journald, dependências, execução perdida recuperável). Precisam de dois arquivos: um `.service` (o que rodar) e um `.timer` (quando). Visão geral:

```ini
# /etc/systemd/system/backup.timer
[Timer]
OnCalendar=*-*-* 02:00:00
Persistent=true
[Install]
WantedBy=timers.target
```
```bash
systemctl enable --now backup.timer
systemctl list-timers
journalctl -u backup.service     # logs da execução
```

## 4. Rede

```bash
curl -fsSL https://api.exemplo.com/status     # baixa/consulta (f=falha em erro,
                                              # s=silencioso, S=mostra erro, L=segue redirect)
curl -o arq.zip https://.../arq.zip           # salva num arquivo
curl -X POST -d '{"a":1}' -H 'Content-Type: application/json' url   # POST
wget https://.../arquivo                      # baixa (bom para arquivos grandes, retoma com -c)

ssh usuario@servidor 'comando'                # roda um comando remoto
ssh usuario@servidor < script.sh              # roda um script local no servidor
scp arquivo usuario@servidor:/destino/        # copia via SSH
rsync -avz --progress origem/ usuario@servidor:/destino/   # sincroniza (só o que mudou)
```

> 💡 `rsync` só transfere o que mudou — é a ferramenta certa para backups e deploys. `-a` preserva permissões/datas, `-v` é verboso, `-z` comprime, `--delete` espelha (remove no destino o que sumiu na origem — cuidado).

> ⚠️ Em `curl` dentro de scripts, use `-fsS`: sem `-f`, um erro HTTP (404/500) ainda "tem sucesso" (status 0) e você baixa uma página de erro achando que é o dado.

---

## 🧪 Exemplos deste módulo

| Arquivo | Demonstra |
|---|---|
| [01-jobs-e-paralelo.sh](exemplos/01-jobs-e-paralelo.sh) | Background `&`, `wait`, paralelismo e tempo economizado |
| [02-sinais-e-trap.sh](exemplos/02-sinais-e-trap.sh) | Enviar e capturar sinais entre processos |
| [03-cron-explicado.sh](exemplos/03-cron-explicado.sh) | Decodifica expressões cron e mostra a armadilha do PATH |

> Os exemplos **não** acessam a rede nem agendam nada de verdade — simulam localmente para rodar em qualquer lugar, inclusive no CI.

## ⚠️ Armadilhas do módulo

- `kill -9` por reflexo (corrompe dados; tente `-15` antes)
- Script do cron falhar por `PATH`/variáveis ausentes
- `curl` sem `-f` baixar página de erro como se fosse dado
- `rsync --delete` apagando o destino por engano
- Esquecer `wait` e o script terminar antes dos jobs em background

## 🏋️ Exercícios

Veja [exercicios/README.md](exercicios/README.md). Corrija com `./ferramentas/corrigir.sh 10`.

## ✅ Checklist de domínio

- [ ] Mando `SIGTERM` antes de `SIGKILL` e sei a diferença
- [ ] Rodo tarefas em background e espero com `wait`
- [ ] Leio e escrevo uma expressão cron
- [ ] Sei por que um script falha no cron e como corrigir (PATH, caminhos absolutos)
- [ ] Uso `curl -fsSL` e `rsync -avz` com consciência

---

⬅️ [Módulo 09](../09-bash-avancado/README.md) · ➡️ [Módulo 11 — Segurança e Portabilidade](../11-seguranca-e-portabilidade/README.md)

<sub>© 2026 Prof. Daniel Santos · Conteúdo [CC BY-NC-SA 4.0](../../LICENSE-CONTEUDO.md) · Código [PolyForm NC](../../LICENSE)</sub>
