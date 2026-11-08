#!/usr/bin/env bash
# ============================================================================
#  Curso de Bash · Módulo 05 · Exemplo 01 — O trio de ouro: grep, sed, awk
#  Prof. Daniel Santos · github.com/dsantos-docencia/bash · © 2026 (PolyForm-NC · não comercial)
# ----------------------------------------------------------------------------
#  OBJETIVO  Resolver tarefas sobre o MESMO log com cada ferramenta, vendo
#            onde cada uma é a escolha natural.
#  EXECUTE   bash 01-grep-sed-awk.sh
# ============================================================================
set -uo pipefail
LAB="$(mktemp -d)"; trap 'rm -rf -- "$LAB"' EXIT
cd "$LAB" || exit 1

cat > app.log <<'EOF'
2026-11-07 10:01 INFO  usuario=ana acao=login
2026-11-07 10:02 ERRO  usuario=bia acao=pagamento valor=150
2026-11-07 10:03 INFO  usuario=ana acao=logout
2026-11-07 10:04 ERRO  usuario=caio acao=pagamento valor=300
2026-11-07 10:05 WARN  usuario=ana acao=senha
EOF

echo "Log de teste:"; sed 's/^/   /' app.log

echo
echo "== grep: FILTRAR linhas =="
echo "grep ERRO (só os erros):"
grep ERRO app.log | sed 's/^/   /'
echo "grep -c ERRO (quantos erros):   $(grep -c ERRO app.log)"
echo "grep -oE 'valor=[0-9]+' (só o trecho):"
grep -oE 'valor=[0-9]+' app.log | sed 's/^/   /'

echo
echo "== sed: TRANSFORMAR texto =="
echo "Mascarar os usuários (usuario=XXX):"
sed -E 's/usuario=[a-z]+/usuario=***/' app.log | sed 's/^/   /'
echo "Só as linhas 2 a 3 (sed -n '2,3p'):"
sed -n '2,3p' app.log | sed 's/^/   /'

echo
echo "== awk: COLUNAS e CÁLCULO =="
echo "3ª coluna (o nível) de cada linha:"
awk '{print $3}' app.log | sort -u | tr '\n' ' '; echo
echo "Somar os 'valor=' dos pagamentos (awk com regex e split):"
total=$(awk -F'valor=' '/valor=/{s+=$2} END{print s+0}' app.log)
echo "   total gasto = $total"
echo "Contar linhas por nível (relatório):"
awk '{c[$3]++} END{for (n in c) printf "   %-5s %d\n", n, c[n]}' app.log | sort
