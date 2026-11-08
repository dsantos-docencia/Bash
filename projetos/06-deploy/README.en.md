# Project 6 — Simple deploy with rollback

**🌍 Idioma / Language:** [Português](README.md) · **English**

Publishes a new version via an **atomic symlink** + dated releases, runs a *smoke test*, and does **automatic rollback** (with `trap`) if the test fails. Keeps only the N most recent versions.

## Usage
```bash
# publishes ./build into ./producao; if the test fails, it reverts on its own
bash deploy.sh -t './rodar-testes.sh' -k 5 ./build ./producao

# structure created:
#   producao/releases/20261108_142530/   (each deploy)
#   producao/atual -> releases/20261108_142530   (atomic symlink)
```

## What it teaches
- **Atomic swap** with `ln -sfn` (deploy with no downtime or partial state)
- **Rollback with `trap EXIT`**: registers the undo BEFORE changing anything
- The `sucesso=1` pattern at the end to "disarm" the rollback
- Release rotation and idempotency

## The core idea
The `trap rollback EXIT` is registered at the start. If any step fails (or the smoke test fails), the script exits with an error and the `trap` restores the previous symlink and discards the new version — **automatically**. Only when everything succeeds does `sucesso=1` neutralize the rollback.

<sub>© 2026 Prof. Daniel Santos and translators · Code [PolyForm NC](../../LICENSE) · Content [CC BY-NC-SA 4.0](../../LICENSE-CONTEUDO.md)</sub>
