# 📡 Sinais do Unix — tabela de referência

Sinais são "mensagens" enviadas a processos. Você os captura com `trap` (Módulo 07) e os envia com `kill` (Módulo 10).

| Nome | Nº | Padrão | Pode capturar? | Significado / uso típico |
|---|---|---|---|---|
| `SIGHUP` | 1 | termina | sim | Terminal fechou. Daemons usam para **recarregar config** |
| `SIGINT` | 2 | termina | sim | **Ctrl+C**. Interrupção pelo usuário |
| `SIGQUIT` | 3 | core dump | sim | Ctrl+\ . Encerra e gera dump |
| `SIGKILL` | 9 | termina | **não** | Mata na hora, sem chance de limpar. Último recurso |
| `SIGTERM` | 15 | termina | sim | **Pedido educado** para terminar. O padrão do `kill` |
| `SIGSTOP` | 19 | pausa | **não** | Congela o processo |
| `SIGTSTP` | 20 | pausa | sim | **Ctrl+Z**. Suspende para o background |
| `SIGCONT` | 18 | continua | sim | Retoma um processo pausado (`fg`/`bg`) |
| `SIGUSR1` | 10 | termina | sim | Livre para seu uso — sinalizar algo ao seu script |
| `SIGUSR2` | 12 | termina | sim | Idem |
| `SIGCHLD` | 17 | ignora | sim | Um processo filho terminou |
| `SIGPIPE` | 13 | termina | sim | Escreveu num pipe sem leitor (ex.: `... | head`) |
| `SIGALRM` | 14 | termina | sim | Despertador (`alarm()`, `timeout`) |

## Pseudo-sinais do `trap` (só no Bash)

| Nome | Dispara quando… |
|---|---|
| `EXIT` (0) | o script termina, por qualquer motivo — ideal para **limpeza** |
| `ERR` | um comando retorna status ≠ 0 (com `set -e`) |
| `DEBUG` | antes de **cada** comando (depuração) |
| `RETURN` | uma função ou `source` termina |

## Uso

```bash
kill -TERM 1234        # envia SIGTERM ao PID 1234
kill -9 1234           # SIGKILL (força bruta)
kill -l                # lista todos os sinais
pkill -TERM firefox    # por nome
trap 'echo limpando; rm -f "$tmp"' EXIT     # captura a saída
trap 'echo "Ctrl+C ignorado"' INT           # captura o Ctrl+C
```

> 💡 **Regra prática:** sempre tente `SIGTERM` (15) primeiro — o processo pode salvar estado e sair limpo. Só use `SIGKILL` (9) se ele ignorar o pedido. `SIGKILL` e `SIGSTOP` **não podem** ser capturados: são a garantia do kernel de que dá para parar qualquer processo.

<sub>© 2026 Prof. Daniel Santos · CC BY-NC-SA 4.0</sub>
