#!/usr/bin/env bash
# ============================================================================
#  Curso de Bash · Módulo 10 · Exemplo 03 — cron explicado
#  Prof. Daniel Santos · github.com/dsantos-docencia/bash · © 2026 (PolyForm-NC · não comercial)
# ----------------------------------------------------------------------------
#  OBJETIVO  Traduzir expressões cron para português e demonstrar, de forma
#            segura, por que scripts falham no cron (ambiente/PATH mínimo).
#  EXECUTE   bash 03-cron-explicado.sh
# ============================================================================
set -uo pipefail

echo "1) Traduzindo expressões cron (min hora dia mês diasem):"
traduzir() {
    printf '   %-16s → %s\n' "$1" "$2"
}
traduzir "0 2 * * *"     "todo dia às 02:00"
traduzir "*/15 * * * *"  "a cada 15 minutos"
traduzir "0 9 * * 1-5"   "às 09:00, de segunda a sexta"
traduzir "0 0 1 * *"     "no dia 1 de cada mês, à meia-noite"
traduzir "30 23 * * 0"   "aos domingos, 23:30"

echo
echo "2) A ARMADILHA DO PATH: o cron roda com um ambiente mínimo."
echo "   Seu terminal tem um PATH rico:"
echo "   PATH atual = $PATH" | cut -c1-70
echo "   ...já o cron costuma ter só: /usr/bin:/bin"
echo
echo "   Demonstração — o MESMO comando com um PATH 'de cron':"
echo "   • No seu terminal, 'date' é encontrado:"
date +'      %H:%M:%S' 2>&1 | head -1

echo "   • Simulando o cron (PATH vazio), um comando não-básico falha:"
env -i PATH="" bash -c 'meu-script-custom 2>&1 || echo "      → command not found (PATH mínimo!)"' 2>/dev/null \
    || echo "      → command not found (PATH mínimo!)"

echo
echo "3) Como blindar um script para o cron:"
cat <<'DICAS' | sed 's/^/   /'
- Use caminhos ABSOLUTOS: /usr/bin/python3, não python3
- Defina o PATH no topo:   export PATH=/usr/local/bin:/usr/bin:/bin
- Carregue seu ambiente:   source /home/user/.profile (se precisar)
- Redirecione a saída:     comando >> /var/log/x.log 2>&1
- Teste como o cron vê:    env -i /caminho/do/script.sh
DICAS
