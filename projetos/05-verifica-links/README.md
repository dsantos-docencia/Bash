# Projeto 5 — Verificador de links em Markdown

Extrai os links `[texto](destino)` de arquivos Markdown e verifica se os **links locais** apontam para arquivos que existem. Reporta os quebrados e sai com status 1 se houver — perfeito para um check de documentação no CI.

## Uso
```bash
bash checar-links.sh README.md
bash checar-links.sh -v docs/*.md        # -v mostra também os OK e externos
```

## O que ele ensina
- Extrair padrões com `grep -oE` + `sed`
- Resolver **caminhos relativos** a partir da pasta do arquivo
- Tratar casos (externos `http`, âncoras `#secao`) com `case`
- Usar o **código de saída** como veredito para automação

## Ideia de uso real
Rode nos `.md` deste repositório para garantir que nenhuma documentação tem link morto:
```bash
find . -name '*.md' -not -path './scripts/*' -exec bash checar-links.sh {} +
```
