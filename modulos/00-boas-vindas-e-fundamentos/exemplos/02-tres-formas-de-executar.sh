#!/usr/bin/env bash
# ============================================================================
#  Curso de Bash · Módulo 00 · Exemplo 02 — Três formas de executar um script
#  Prof. Daniel Santos · github.com/dsantos-docencia/bash · © 2026 (PolyForm-NC · não comercial)
# ----------------------------------------------------------------------------
#  OBJETIVO  Entender por que `bash x.sh`, `./x.sh` e `source x.sh` NÃO são
#            a mesma coisa — a diferença está em QUEM executa o código.
#  EXECUTE   bash 02-tres-formas-de-executar.sh
#  OBSERVE   Só a forma `source` consegue alterar variáveis do shell que chamou.
# ============================================================================

# Para demonstrar sem mexer no seu sistema, criamos um mini-script num
# diretório temporário. mktemp -d cria uma pasta com nome único; o `trap`
# garante que ela seja apagada quando este script terminar (Módulo 08).
LAB="$(mktemp -d)"
trap 'rm -rf -- "$LAB"' EXIT

cat > "$LAB/define-cor.sh" <<'FIM'
#!/usr/bin/env bash
COR="azul"
echo "    (dentro do mini-script: COR=$COR)"
FIM
chmod +x "$LAB/define-cor.sh"

COR="vermelho"
echo "Antes de tudo, aqui fora: COR=$COR"
echo

echo "1) bash define-cor.sh  → um NOVO processo Bash lê o arquivo"
bash "$LAB/define-cor.sh"
echo "   aqui fora continua: COR=$COR"
echo

echo "2) ./define-cor.sh     → o kernel lê o shebang e inicia um NOVO processo"
"$LAB/define-cor.sh"
echo "   aqui fora continua: COR=$COR"
echo

echo "3) source define-cor.sh → o shell ATUAL lê e executa as linhas"
# shellcheck source=/dev/null
source "$LAB/define-cor.sh"
echo "   aqui fora agora é: COR=$COR   ← mudou!"
echo

cat <<'RESUMO'
Resumo:
  bash x.sh   não precisa de chmod +x; ignora o shebang; processo filho
  ./x.sh      precisa de chmod +x; respeita o shebang; processo filho
  source x.sh (ou ". x.sh") roda no shell atual — é assim que o ~/.bashrc
              é carregado e que "bibliotecas" de funções são importadas.
RESUMO
