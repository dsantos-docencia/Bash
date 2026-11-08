# 🚀 Projetos Práticos

Aqui a teoria vira ferramenta. Cada projeto é um script **completo e funcional**, com código comentado, tratamento de erro e **testes automatizados** — exatamente como você escreveria no trabalho.

> Diferente dos exemplos (que ilustram um conceito), os projetos resolvem um problema real de ponta a ponta. Leia o código, rode, quebre, melhore.

## Os projetos

| # | Projeto | Conceitos aplicados | Módulos |
|---|---|---|---|
| 1 | [Backup inteligente](01-backup/) | `tar`, data no nome, rotação, log, `trap` | 05, 07, 10 |
| 2 | [Monitor de sistema](02-monitor/) | `awk` sobre `/proc`, limites, alertas | 05, 07 |
| 3 | [Processamento em lote](03-lote/) | renomear em massa, relatório, idempotência | 04, 05, 06 |
| 4 | [CLI profissional](04-cli/) | `getopts`, cores, `--help`, subcomandos | 06, 08 |
| 5 | [Verificador de links](05-verifica-links/) | leitura de arquivo, paralelismo, códigos de saída | 06, 10 |
| 6 | [Deploy simples com rollback](06-deploy/) | `trap` para rollback, etapas, idempotência | 07, 10 |

## Como rodar e testar

Cada projeto tem seu `README.md`, o script principal, e uma pasta `testes/` com testes no mini-framework do curso:

```bash
# rodar o projeto
bash projetos/01-backup/backup.sh --help

# rodar os testes de um projeto (via corretor, que também cobre projetos)
./ferramentas/verificar-tudo.sh      # inclui os testes dos projetos
```

Todos os projetos são **seguros para rodar**: operam em diretórios temporários ou exigem que você aponte explicitamente o alvo, e nenhum acessa a rede real nos testes.

<sub>© 2026 Prof. Daniel Santos · Código [MIT](../LICENSE) · Conteúdo [CC BY-NC-SA 4.0](../LICENSE-CONTEUDO.md)</sub>
