#!/usr/bin/env bash
# ============================================================================
#  Curso de Bash · Módulo 09 · Exemplo 01 — Subshell ( ) vs grupo { }
#  Prof. Daniel Santos · github.com/dsantos-docencia/bash · © 2026 (PolyForm-NC · não comercial)
# ----------------------------------------------------------------------------
#  OBJETIVO  Ver que ( ) isola cd/variáveis e { } não.
#  EXECUTE   bash 01-subshell-vs-grupo.sh
# ============================================================================
set -uo pipefail
LAB="$(mktemp -d)"; trap 'rm -rf -- "$LAB"' EXIT
cd "$LAB" || exit 1
mkdir -p sub

echo "Estamos em: $(pwd | sed "s#$LAB#\$LAB#")"
echo

echo "1) Subshell ( ... ): o cd fica CONTIDO"
( cd sub && echo "   dentro do ( ): $(pwd | sed "s#$LAB#\$LAB#")" )
echo "   depois do ( ):  $(pwd | sed "s#$LAB#\$LAB#")   ← não mudou"

echo
echo "2) Variável alterada dentro do ( ) NÃO sobrevive:"
x="original"
( x="mudada no subshell"; echo "   dentro: x=$x" )
echo "   fora:   x=$x   ← intacta"

echo
echo "3) Agrupamento { ...; }: roda no shell ATUAL (afeta tudo)"
y="antes"
{ y="mudada no grupo"; echo "   dentro: y=$y"; }
echo "   fora:   y=$y   ← MUDOU"

echo
echo "4) Uso prático do { }: redirecionar vários comandos de uma vez"
{ echo "=== RELATÓRIO ==="; echo "linha A"; echo "linha B"; } > relatorio.txt
echo "   relatorio.txt ficou com $(wc -l < relatorio.txt) linhas:"
sed 's/^/      /' relatorio.txt

echo
echo "Resumo: ( ) para ISOLAR efeitos; { } para AGRUPAR sem isolar."
