#!/usr/bin/env bash
# ============================================================================
#  Curso de Bash · ferramentas/configurar-github.sh
#  Aplica proteção de branch e recursos de segurança num repositório GitHub.
#  Prof. Daniel Santos · github.com/dsantos-docencia/Bash · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  POR QUE EXISTE
#    As configurações administrativas (proteger a branch, ligar secret scanning)
#    não podem ser feitas de dentro de uma sessão automatizada — exigem o SEU
#    acesso de administrador. Este script faz tudo de uma vez, com o 'gh' já
#    autenticado na sua máquina.
#
#  PRÉ-REQUISITOS
#    - gh (GitHub CLI) instalado e autenticado:  gh auth login
#    - você ser ADMIN do repositório
#
#  USO
#    ./ferramentas/configurar-github.sh dsantos-docencia/Bash
#    ./ferramentas/configurar-github.sh dsantos-docencia/power-shell main
#
#  O QUE ELE CONFIGURA
#    Proteção da branch principal:
#      - exige Pull Request (ninguém faz push direto na main)
#      - exige 1 revisão aprovada e revisão do CODEOWNERS (você)
#      - exige o check de CI 'verificar' verde e branch atualizada
#      - descarta aprovações obsoletas; exige conversas resolvidas
#      - histórico linear; bloqueia force-push e exclusão da branch
#      - enforce_admins=false: você (admin) ainda pode fazer merge quando preciso
#    Segurança do repositório:
#      - alertas de vulnerabilidade
#      - correções automáticas do Dependabot
#      - secret scanning + push protection (barra segredos antes do commit)
# ============================================================================
set -euo pipefail

repo="${1:-}"
branch="${2:-main}"
check_ci="${3:-verificar}"     # nome do job de CI exigido

[[ -n "$repo" ]] || { echo "uso: $0 <owner/repo> [branch] [nome-do-check-ci]" >&2; exit 2; }
command -v gh >/dev/null || { echo "erro: instale o GitHub CLI (gh) e rode 'gh auth login'" >&2; exit 1; }

echo "➤ Repositório: $repo   branch: $branch"

echo "① Proteção da branch '$branch'..."
gh api -X PUT "repos/$repo/branches/$branch/protection" \
  -H "Accept: application/vnd.github+json" --input - <<JSON
{
  "required_status_checks": { "strict": true, "contexts": ["$check_ci"] },
  "enforce_admins": false,
  "required_pull_request_reviews": {
    "dismiss_stale_reviews": true,
    "require_code_owner_reviews": true,
    "required_approving_review_count": 1
  },
  "restrictions": null,
  "required_linear_history": true,
  "allow_force_pushes": false,
  "allow_deletions": false,
  "required_conversation_resolution": true
}
JSON
echo "   ✔ branch protegida"

echo "② Alertas de vulnerabilidade..."
gh api -X PUT "repos/$repo/vulnerability-alerts" && echo "   ✔ ligados"

echo "③ Correções automáticas do Dependabot..."
gh api -X PUT "repos/$repo/automated-security-fixes" && echo "   ✔ ligadas"

echo "④ Secret scanning + push protection..."
gh api -X PATCH "repos/$repo" --input - <<'JSON'
{
  "security_and_analysis": {
    "secret_scanning": { "status": "enabled" },
    "secret_scanning_push_protection": { "status": "enabled" }
  }
}
JSON
echo "   ✔ secret scanning ligado"

cat <<FIM

✅ Pronto! Confira em:
   https://github.com/$repo/settings/branches   (regra da branch $branch)
   https://github.com/$repo/settings/security_analysis   (segurança)

Observações:
  • Contribuições externas agora passam obrigatoriamente por Pull Request com
    sua revisão. Você, como admin, ainda consegue fazer merge dos seus próprios
    PRs (enforce_admins=false).
  • Se o check de CI tiver outro nome, rode de novo passando-o como 3º argumento.
FIM
