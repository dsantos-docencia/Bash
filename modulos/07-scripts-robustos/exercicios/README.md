# 🏋️ Exercícios — Módulo 07

Corrija com `./ferramentas/corrigir.sh 07`. Soluções em [solucoes/](solucoes/).

### 01 — Validar argumento · `01-validar.sh`
Deve exigir **exatamente 1** argumento. Se não vier (ou vier mais de um), imprima no **stderr** `uso: 01-validar.sh <nome>` e termine com código **2**. Se vier certo, imprima `Olá, NOME` no stdout e termine com 0.

### 02 — Divisão segura · `02-divisao.sh`
Recebe dois números (`$1` e `$2`) e imprime `$1 / $2` (inteiro). Se `$2` for `0`, imprima no stderr `erro: divisao por zero` e saia com código **1** (sem travar). Caso contrário, imprima o resultado.

### 03 — Soma robusta · `03-soma-robusta.sh`
Com `set -euo pipefail` no topo, some todos os argumentos numéricos e imprima o total. **Atenção à armadilha**: o incremento/soma não pode abortar o script sob `set -e`. Ex.: `bash 03-soma-robusta.sh 3 4 5` → `12`. Sem argumentos → `0`.
