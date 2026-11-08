# 🏋️ Exercícios — Módulo 09

Corrija com `./ferramentas/corrigir.sh 09`. Soluções em [solucoes/](solucoes/).

### 01 — Config por here-doc · `01-gerar-config.sh`
Recebe um nome de serviço em `$1` e uma porta em `$2`. Usando **here-doc**, imprima no stdout exatamente:
```
[servico]
nome=NOME
porta=PORTA
```

### 02 — Somar via process substitution · `02-somar-seq.sh`
Recebe um número `N` em `$1` e imprime a soma de `1` até `N`, lendo de `seq` com um `while read` alimentado por **process substitution** (`< <(...)`), sem usar pipe. Ex.: `bash 02-somar-seq.sh 10` → `55`.

### 03 — Comparar listas · `03-comparar.sh`
Recebe dois arquivos (`$1`, `$2`) e imprime `iguais` se tiverem o mesmo conteúdo ordenado, ou `diferentes` (status 1) caso contrário. Use `diff <(sort ...) <(sort ...)`.
