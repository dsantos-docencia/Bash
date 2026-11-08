# 🏋️ Exercícios — Módulo 01

Corrija com `./ferramentas/corrigir.sh 01`. Soluções comentadas em [solucoes/](solucoes/).

### 01 — Contar por tipo · `01-contar-tipos.sh`
O script recebe **um diretório** como `$1` e imprime **duas linhas**, exatamente:
```
arquivos: N
diretorios: M
```
onde N é o nº de arquivos comuns e M o nº de diretórios **dentro** dele (recursivo, sem contar o próprio). Dica: `find "$1" -type f | wc -l`.

### 02 — Octal para rwx · `02-octal-para-rwx.sh`
Recebe um arquivo em `$1`, aplica `chmod 640` nele e imprime a permissão resultante em formato `rwx` (use `stat -c '%A'`). Saída esperada para um arquivo comum:
```
-rw-r-----
```

### 03 — Maior arquivo · `03-maior-arquivo.sh`
Recebe um diretório em `$1` e imprime **apenas o nome** (caminho) do maior arquivo comum dentro dele (recursivo). Em caso de empate, qualquer um serve. Dica: `find ... -printf '%s %p\n' | sort -n | tail -1`.
