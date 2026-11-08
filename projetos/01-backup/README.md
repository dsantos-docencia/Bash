# Projeto 1 — Backup inteligente

Compacta um diretório em `.tar.gz` com data no nome, mantém só as N cópias mais recentes e registra tudo.

## Uso
```bash
bash backup.sh -o /caminho/backups -k 5 /pasta/importante
bash backup.sh --help
```
| Opção | Faz |
|---|---|
| `-o DESTINO` | onde salvar (padrão `./backups`) |
| `-k MANTER` | quantas cópias manter (padrão 5) |
| `-q` | silencioso |

## O que ele ensina
- Criar arquivos com `tar -czf` e nome com `date`
- **Rotação**: listar por data (`find -printf '%T@'`) e apagar o excesso
- Logging com timestamp e `set -euo pipefail`
- Validação de entrada antes de agir

## Agendar no cron (exemplo)
```cron
0 2 * * *  /caminho/backup.sh -q -o /backups -k 7 /dados >> /var/log/backup.log 2>&1
```

## Testar
```bash
./ferramentas/verificar-tudo.sh   # inclui os testes deste projeto
```
