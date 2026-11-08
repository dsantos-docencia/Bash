#!/usr/bin/env bash
# ============================================================================
#  Curso de Bash · Módulo 09 · Exemplo 03 — Here-docs, here-strings e fd
#  Prof. Daniel Santos · github.com/dsantos-docencia/bash · © 2026 (PolyForm-NC · não comercial)
# ----------------------------------------------------------------------------
#  OBJETIVO  Here-doc com/sem expansão, here-string e descritores de arquivo.
#  EXECUTE   bash 03-heredoc-e-fd.sh
# ============================================================================
set -uo pipefail
LAB="$(mktemp -d)"; trap 'rm -rf -- "$LAB"' EXIT
cd "$LAB" || exit 1

porta=8080
echo "1) Here-doc COM expansão (<<FIM): variáveis e comandos viram valores"
cat <<FIM | sed 's/^/   /'
porta configurada: $porta
gerado em: $(date +%Y)
FIM

echo
echo "2) Here-doc SEM expansão (<<'FIM'): texto cru (ótimo para gerar scripts)"
cat <<'FIM' | sed 's/^/   /'
este $cifrao e este $(comando) saem literais
FIM

echo
echo "3) Gerando um arquivo de config com here-doc:"
cat > app.conf <<CONF
porta=$porta
log=/var/log/app.log
CONF
echo "   app.conf:"; sed 's/^/      /' app.conf

echo
echo "4) Here-string (<<<): alimenta o stdin com uma linha"
tamanho=$(wc -c <<< "contagem")      # conta os bytes da string (+1 do \n)
echo "   'contagem' tem $(( tamanho - 1 )) caracteres"
read -ra campos <<< "um dois tres"
echo "   dividido em ${#campos[@]} campos: ${campos[1]} é o do meio"

echo
echo "5) Descritor extra (fd 3): manter um log aberto durante o script"
exec 3> eventos.log            # abre o fd 3 apontando para o arquivo
echo "evento A" >&3
echo "evento B" >&3
exec 3>&-                      # fecha o fd 3
echo "   eventos.log recebeu $(wc -l < eventos.log) linhas via fd 3"
