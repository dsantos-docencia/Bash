#!/usr/bin/env bash
# ============================================================================
#  Curso de Bash · Módulo 02 · Exemplo 02 — Pipes e a filosofia Unix
#  Prof. Daniel Santos · github.com/dsantos-docencia/bash · © 2026 (PolyForm-NC · não comercial)
# ----------------------------------------------------------------------------
#  OBJETIVO  Resolver um problema real ("top IPs de um log") montando uma
#            linha de montagem de comandos simples com pipes.
#  EXECUTE   bash 02-pipes-filosofia-unix.sh
# ============================================================================
set -euo pipefail
LAB="$(mktemp -d)"; trap 'rm -rf -- "$LAB"' EXIT
cd "$LAB" || exit 1

# Geramos um "log de acesso" fictício para ter o que analisar.
cat > acesso.log <<'EOF'
10.0.0.5 GET /index
10.0.0.9 GET /login
10.0.0.5 POST /login
10.0.0.5 GET /painel
10.0.0.2 GET /index
10.0.0.9 GET /index
10.0.0.5 GET /sair
10.0.0.2 GET /login
EOF

echo "Pergunta: quais os IPs que mais acessaram, e quantas vezes?"
echo
echo "A linha de montagem, peça por peça:"
echo

echo "  cut -d' ' -f1           → pega só a 1ª coluna (o IP):"
cut -d' ' -f1 acesso.log | sed 's/^/     /'

echo
echo "  ... | sort              → agrupa iguais (uniq exige ordenado):"
cut -d' ' -f1 acesso.log | sort | sed 's/^/     /'

echo
echo "  ... | uniq -c           → conta repetições:"
cut -d' ' -f1 acesso.log | sort | uniq -c | sed 's/^/     /'

echo
echo "  ... | sort -rn | head   → ordena por nº (desc) e pega o topo:"
cut -d' ' -f1 acesso.log | sort | uniq -c | sort -rn | head -3 | sed 's/^/     /'

echo
echo "Tudo numa linha só — a mágica dos pipes:"
echo '  cut -d" " -f1 acesso.log | sort | uniq -c | sort -rn | head -3'
echo
echo "Nenhum desses comandos sabe o que é um 'log'. Cada um faz UMA coisa."
echo "Juntos, respondem a pergunta. Isso é a filosofia Unix."
