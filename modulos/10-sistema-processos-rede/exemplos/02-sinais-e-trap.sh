#!/usr/bin/env bash
# ============================================================================
#  Curso de Bash · Módulo 10 · Exemplo 02 — Sinais e trap entre processos
#  Prof. Daniel Santos · github.com/dsantos-docencia/bash · © 2026 (PolyForm-NC · não comercial)
# ----------------------------------------------------------------------------
#  OBJETIVO  Ver um processo capturar sinais (TERM, USR1) enviados por outro.
#  EXECUTE   bash 02-sinais-e-trap.sh
# ============================================================================
set -uo pipefail
LAB="$(mktemp -d)"; trap 'rm -rf -- "$LAB"' EXIT

# Criamos um "trabalhador" que fica rodando e reage a sinais.
cat > "$LAB/trabalhador.sh" <<'FIM'
#!/usr/bin/env bash
set -uo pipefail
evento() { echo "   [trabalhador] recebi SIGUSR1 — recarregando config"; }
saida()  { echo "   [trabalhador] recebi SIGTERM — encerrando limpo"; exit 0; }
trap evento USR1        # sinal "do usuário": nós damos o significado
trap saida  TERM        # pedido educado de término
echo "   [trabalhador] no ar (PID $$), aguardando sinais..."
while true; do sleep 0.2; done
FIM

bash "$LAB/trabalhador.sh" &
pid=$!
sleep 0.4

echo "1) Enviando SIGUSR1 (ex.: 'recarregue sua configuração'):"
kill -USR1 "$pid"; sleep 0.4

echo
echo "2) Enviando outro SIGUSR1:"
kill -USR1 "$pid"; sleep 0.4

echo
echo "3) Enviando SIGTERM (término educado):"
kill -TERM "$pid"
wait "$pid" 2>/dev/null
echo "   trabalhador saiu com status $?"

echo
echo "Lição: daemons de verdade usam SIGHUP/SIGUSR1 para recarregar config"
echo "sem reiniciar, e SIGTERM para encerrar salvando o estado."
