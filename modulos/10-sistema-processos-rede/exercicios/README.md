# 🏋️ Exercícios — Módulo 10

Corrija com `./ferramentas/corrigir.sh 10`. Soluções em [solucoes/](solucoes/).

### 01 — Rodar em paralelo · `01-paralelo.sh`
Recebe N números em `$@`, cada um representando segundos. Deve rodar `sleep` para cada um **em paralelo** e, ao final (após `wait`), imprimir `concluido: N` (N = quantidade). O tempo total deve ser ~o maior sleep, não a soma. (O teste usa valores pequenos.)

### 02 — Validar expressão cron · `02-valida-cron.sh`
Recebe uma string em `$1` e imprime `ok` se ela tiver **exatamente 5 campos** separados por espaço (não valida os valores, só a contagem), senão `invalido` com status 1. Dica: transforme em array com `read -ra` e cheque `${#campos[@]}`.

### 03 — Simular ambiente do cron · `03-precisa-path.sh`
Escreva um script que dependa de um PATH correto: ele deve imprimir a saída de `seq 1 3` (um por linha). O objetivo é que ele funcione mesmo quando chamado via `env -i PATH=/usr/bin:/bin bash 03-precisa-path.sh`. Dica: não dependa de nada exótico; `seq` está em /usr/bin.
