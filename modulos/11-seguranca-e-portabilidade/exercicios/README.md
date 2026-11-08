# 🏋️ Exercícios — Módulo 11

Corrija com `./ferramentas/corrigir.sh 11`. Soluções em [solucoes/](solucoes/).

### 01 — Remoção segura · `01-remocao-segura.sh`
Recebe um caminho em `$1`. Deve **recusar** (imprimir `recusado` no stderr e sair com 1) se o argumento estiver ausente/vazio, for `/`, ou contiver `..`. Caso contrário, imprima `ok: removeria CAMINHO` (não remova nada de verdade — é um exercício de validação).
```console
$ bash 01-remocao-segura.sh /tmp/x   → ok: removeria /tmp/x
$ bash 01-remocao-segura.sh ""       → (stderr) recusado   [status 1]
$ bash 01-remocao-segura.sh /        → (stderr) recusado   [status 1]
$ bash 01-remocao-segura.sh ../etc   → (stderr) recusado   [status 1]
```

### 02 — Validar inteiro · `02-so-inteiro.sh`
Recebe `$1` e imprime `numero` se for um inteiro (com sinal opcional), senão `nao` com status 1. Use `[[ =~ ]]` com a âncora correta (sem usar programas externos).

### 03 — Normalizar para maiúsculas (portável) · `03-maiusc-portavel.sh`
Recebe `$1` e imprime em MAIÚSCULAS **sem** usar `${var^^}` (que não é POSIX) — use `tr`. Assim o script funcionaria até em `#!/bin/sh`. Ex.: `bash 03-maiusc-portavel.sh bash` → `BASH`.
