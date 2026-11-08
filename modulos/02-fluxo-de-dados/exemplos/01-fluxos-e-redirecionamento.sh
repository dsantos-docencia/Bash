#!/usr/bin/env bash
# ============================================================================
#  Curso de Bash · Módulo 02 · Exemplo 01 — Fluxos e redirecionamento
#  Prof. Daniel Santos · github.com/dsantos-docencia/bash · © 2026 (PolyForm-NC · não comercial)
# ----------------------------------------------------------------------------
#  OBJETIVO  Ver, lado a lado, stdout e stderr, e cada operador de redireção.
#  EXECUTE   bash 01-fluxos-e-redirecionamento.sh
# ============================================================================
set -euo pipefail
LAB="$(mktemp -d)"; trap 'rm -rf -- "$LAB"' EXIT
cd "$LAB" || exit 1

# Uma mini-função que fala nos DOIS canais ao mesmo tempo.
tagarela() {
    echo "isto é saída normal (stdout)"
    echo "isto é uma mensagem de erro (stderr)" >&2   # >&2 = manda para o fd 2
}

echo "1) Sem redirecionar: os dois aparecem juntos na tela:"
tagarela

echo
echo "2) Separando os canais em arquivos diferentes:"
tagarela > saida.txt 2> erros.txt
echo "   saida.txt  →  $(cat saida.txt)"
echo "   erros.txt  →  $(cat erros.txt)"

echo
echo "3) >> acrescenta em vez de sobrescrever:"
echo "linha 1" >  acumula.txt
echo "linha 2" >> acumula.txt
echo "   acumula.txt tem $(wc -l < acumula.txt) linhas"

echo
echo "4) 2>/dev/null descarta só os erros (fica só a saída):"
tagarela 2>/dev/null

echo
echo "5) &> junta tudo num arquivo só:"
tagarela &> tudo.log
echo "   tudo.log tem $(wc -l < tudo.log) linhas (saída + erro)"

echo
echo "6) < alimenta o stdin a partir de um arquivo:"
printf 'maçã\nbanana\nabacaxi\n' > frutas.txt
echo "   nº de frutas (wc -l lendo do arquivo via <): $(wc -l < frutas.txt)"
