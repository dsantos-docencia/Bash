# 🏋️ Exercícios — Módulo 05

Corrija com `./ferramentas/corrigir.sh 05`. Soluções em [solucoes/](solucoes/).

### 01 — Extrair e-mails · `01-extrair-emails.sh`
Recebe um arquivo em `$1` e imprime **só os endereços de e-mail** que aparecem nele, um por linha. Use `grep -oE`. Um padrão suficiente: `[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]+`.

### 02 — Somar coluna · `02-somar-coluna.sh`
Recebe um arquivo com números na **2ª coluna** (separada por espaço) em `$1` e imprime a soma inteira. Use `awk`.

### 03 — Trocar extensão · `03-trocar-extensao.sh`
Recebe um caminho em `$1` e imprime o mesmo caminho com a extensão trocada para `.bak`, usando **expansão de parâmetro** (sem sed/awk). Ex.: `/a/b/c.txt` → `/a/b/c.bak`. Considere que há exatamente uma extensão.
