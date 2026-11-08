# 🏋️ Exercícios — Módulo 02

Corrija com `./ferramentas/corrigir.sh 02`. Soluções em [solucoes/](solucoes/).

### 01 — Só os erros · `01-so-os-erros.sh`
O script roda um comando que fala nos dois canais. Faça-o imprimir **apenas** o conteúdo do **stderr** do comando abaixo (descarte o stdout). Use o comando interno fornecido:
```bash
gerar() { echo "resultado bom"; echo "deu ruim" >&2; }
```
Saída esperada:
```
deu ruim
```

### 02 — Top 3 palavras · `02-top-palavras.sh`
Recebe um arquivo de texto em `$1` e imprime as **3 palavras mais frequentes**, uma por linha, da mais para a menos frequente, **só a palavra** (sem a contagem). Considere palavras separadas por espaço; não precisa tratar pontuação. Dica: `tr ' ' '\n' | sort | uniq -c | sort -rn`.

### 03 — Criar em lote · `03-criar-lote.sh`
Usando **expansão de chaves**, crie no diretório atual os arquivos `nota-01.md` até `nota-05.md` e imprima quantos arquivos `.md` existem agora:
```
5
```
