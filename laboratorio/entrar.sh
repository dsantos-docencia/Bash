#!/usr/bin/env bash
# ============================================================================
#  Curso de Bash — laboratorio/entrar.sh
#  Abre um shell dentro do container do curso, com o repositório montado.
#  Prof. Daniel Santos · github.com/dsantos-docencia/bash · © 2026 (PolyForm-NC · não comercial)
# ============================================================================
set -euo pipefail

RAIZ="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
IMAGEM="curso-bash:lab"

if ! command -v docker >/dev/null; then
    cat >&2 <<'MSG'
Docker não encontrado. Instale a partir de https://docs.docker.com/get-docker/
Sem Docker, você ainda pode usar o curso direto no seu Bash — o container é
apenas uma conveniência para ter um ambiente idêntico e descartável.
MSG
    exit 1
fi

# Constrói a imagem na primeira vez (ou se o Dockerfile mudou).
if ! docker image inspect "$IMAGEM" >/dev/null 2>&1; then
    echo "Construindo a imagem do laboratório (só na primeira vez)…"
    docker build -t "$IMAGEM" "$RAIZ/laboratorio"
fi

echo "Entrando no laboratório. O repositório está em /curso. Digite 'exit' para sair."
# --rm: o container é descartado ao sair (estado sempre limpo).
# -v: monta o repositório; mudanças nos arquivos refletem dos dois lados.
exec docker run --rm -it -v "$RAIZ:/curso" "$IMAGEM" bash
