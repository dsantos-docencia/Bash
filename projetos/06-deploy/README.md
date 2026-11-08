# Projeto 6 — Deploy simples com rollback

Publica uma nova versão via **symlink atômico** + releases datadas, roda um *smoke test* e faz **rollback automático** (com `trap`) se o teste falhar. Mantém só as N versões mais recentes.

## Uso
```bash
# publica ./build em ./producao; se o teste falhar, volta sozinho
bash deploy.sh -t './rodar-testes.sh' -k 5 ./build ./producao

# estrutura criada:
#   producao/releases/20261108_142530/   (cada deploy)
#   producao/atual -> releases/20261108_142530   (symlink atômico)
```

## O que ele ensina
- **Troca atômica** com `ln -sfn` (deploy sem downtime nem estado parcial)
- **Rollback com `trap EXIT`**: registra o desfazer ANTES de mudar nada
- O padrão `sucesso=1` no fim para "desarmar" o rollback
- Rotação de releases e idempotência

## A ideia central
O `trap rollback EXIT` é registrado no começo. Se qualquer etapa falhar (ou o smoke test reprovar), o script sai com erro e o `trap` restaura o symlink anterior e descarta a versão nova — **automaticamente**. Só quando tudo dá certo, `sucesso=1` neutraliza o rollback.
