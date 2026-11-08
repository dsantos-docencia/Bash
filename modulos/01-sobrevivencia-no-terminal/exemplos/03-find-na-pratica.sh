#!/usr/bin/env bash
# ============================================================================
#  Curso de Bash · Módulo 01 · Exemplo 03 — find na prática
#  Prof. Daniel Santos · github.com/dsantos-docencia/bash · © 2026 (MIT)
# ----------------------------------------------------------------------------
#  OBJETIVO  Buscar por nome, tipo, tamanho e executar ações com -exec.
#  EXECUTE   bash 03-find-na-pratica.sh
#  SEGURO    Monta uma árvore de teste e opera só nela.
# ============================================================================
set -euo pipefail
LAB="$(mktemp -d)"; trap 'rm -rf -- "$LAB"' EXIT
cd "$LAB"

# Monta uma mini-árvore de arquivos de vários tipos e tamanhos.
mkdir -p projeto/src projeto/logs projeto/tmp
echo "codigo" > projeto/src/app.sh
echo "codigo" > projeto/src/util.sh
: > projeto/logs/ontem.log
: > projeto/logs/hoje.log
head -c 2000000 /dev/zero > projeto/tmp/grande.bin   # ~2 MB
: > projeto/tmp/lixo.tmp

echo "1) Todos os .sh (recursivo, a partir daqui):"
find projeto -name "*.sh" | sed 's/^/   /'

echo
echo "2) Só DIRETÓRIOS:"
find projeto -type d | sed 's/^/   /'

echo
echo "3) Só ARQUIVOS .log:"
find projeto -type f -name "*.log" | sed 's/^/   /'

echo
echo "4) Arquivos maiores que 1 MB:"
find projeto -type f -size +1M | sed 's/^/   /'

echo
echo "5) -exec: tornar cada .sh executável (e conferir):"
find projeto -name "*.sh" -exec chmod +x {} \;
find projeto -name "*.sh" -exec stat -c '   %A %n' {} \;

echo
echo "6) Padrão SEGURO: ver antes de apagar."
echo "   Estes .tmp SERIAM apagados por 'find ... -delete':"
find projeto -name "*.tmp" | sed 's/^/   (apagaria) /'
# Agora sim, apagamos de verdade (estamos no lab):
find projeto -name "*.tmp" -delete
echo "   Depois do -delete, sobraram .tmp? →" "$(find projeto -name '*.tmp' | wc -l)"
