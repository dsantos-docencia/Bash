# Projeto 3 — Processamento em lote (renomear)

Renomeia em massa os arquivos de uma pasta: minúsculas, espaços → `_`, prefixo opcional. **Seguro por padrão**: simula (dry-run) e só age com `-x`.

## Uso
```bash
bash renomear.sh pasta/           # SIMULA (mostra o que faria)
bash renomear.sh -x pasta/        # aplica de verdade
bash renomear.sh -x -p 2026_ fotos/   # ainda acrescenta um prefixo
```

## O que ele ensina
- Transformar strings com expansão de parâmetros (`${v,,}`, `${v// /_}`)
- O padrão **dry-run** (simular antes de agir) — essencial em automação destrutiva
- **Idempotência**: rodar de novo não causa dano (nomes já ok ficam inalterados)
- `shopt -s nullglob` para pastas vazias
