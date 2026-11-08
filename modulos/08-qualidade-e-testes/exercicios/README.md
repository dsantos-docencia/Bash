# 🏋️ Exercícios — Módulo 08

Corrija com `./ferramentas/corrigir.sh 08`. Soluções em [solucoes/](solucoes/).

### 01 — Opções com getopts · `01-saudacao-opts.sh`
Aceite as opções:
- `-n NOME` → nome a saudar (padrão: `mundo`)
- `-u` → saída em MAIÚSCULAS
- `-h` → imprime `uso: ...` e sai com 0

Comportamento:
```console
$ bash 01-saudacao-opts.sh            → Oi, mundo
$ bash 01-saudacao-opts.sh -n Ana     → Oi, Ana
$ bash 01-saudacao-opts.sh -u -n Ana  → OI, ANA
```

### 02 — Validador de CPF (formato) · `02-valida-formato.sh`
Recebe uma string em `$1` e imprime `valido` se ela casar o formato `000.000.000-00` (só o formato, não o dígito verificador), senão `invalido` com status 1. Use `[[ =~ ]]`.

### 03 — Escrevendo um teste · `03-soma.bats` (+ `03-soma.sh`)
Já fornecemos `03-soma.sh` (soma dois números). **Complete** o arquivo de testes Bats `03-soma.bats` com pelo menos 2 casos. (Este exercício é conferido por inspeção/execução do bats, não pelo corretor automático.)
