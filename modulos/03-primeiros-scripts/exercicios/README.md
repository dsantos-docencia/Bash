# 🏋️ Exercícios — Módulo 03

Corrija com `./ferramentas/corrigir.sh 03`. Soluções em [solucoes/](solucoes/).

### 01 — Saudação com argumento · `01-saudacao.sh`
Recebe um nome em `$1` e imprime `Olá, NOME!`. Se **nenhum** argumento for passado, imprima `Olá, visitante!` e termine normalmente (status 0). Dica: `${1:-visitante}`.

### 02 — Contador de argumentos · `02-quantos.sh`
Imprime exatamente: `Você passou N argumento(s).` onde N é a quantidade recebida.

### 03 — Recibo formatado · `03-recibo.sh`
Recebe um produto em `$1` e um preço em `$2` e imprime, com `printf`, uma linha: o produto alinhado à esquerda em **15 colunas** (`%-15s`), depois `R$ ` e o preço com **largura 6 e 2 casas** (`%6.2f`):
```console
$ bash 03-recibo.sh Mel 4.5
Mel             R$   4.50
```
> Dica: `printf` conta **bytes**, então teste com produtos sem acento para prever o alinhamento.
