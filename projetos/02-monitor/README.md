# Projeto 2 — Monitor de sistema

Coleta uso de **disco**, **memória** e **carga**, compara com limites e alerta. Sai com status 1 se algum limite estourar — ideal para cron ou health-check.

## Uso
```bash
bash monitor.sh                      # limites padrão (90%)
bash monitor.sh -d 80 -m 75 -p /var  # disco 80%, memória 75%, checa /var
```

## O que ele ensina
- Extrair números de `df` e `/proc/meminfo` com `awk`
- Comparação numérica e contagem de alertas
- Usar o **código de saída** como sinal (0 = ok, 1 = alerta) para cron/CI

## Agendar (alerta a cada 5 min)
```cron
*/5 * * * * /caminho/monitor.sh -d 85 || echo "servidor sob pressão" | mail -s alerta voce@exemplo.com
```
