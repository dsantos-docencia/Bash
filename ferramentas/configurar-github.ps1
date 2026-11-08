<#
============================================================================
  Curso de Bash · ferramentas/configurar-github.ps1
  Aplica proteção de branch e segurança num repositório GitHub (via gh).
  Prof. Daniel Santos · github.com/dsantos-docencia/Bash · © 2026 (PolyForm-NC)
----------------------------------------------------------------------------
  POR QUE EXISTE
    Configurações administrativas (proteger a branch, ligar secret scanning) não
    podem ser feitas de dentro de uma sessão automatizada — exigem o SEU acesso
    de administrador. Este script faz tudo com o 'gh' já autenticado na sua máquina.
    Versão PowerShell do configurar-github.sh (para quem administra via Windows/pwsh).

  PRÉ-REQUISITOS
    - GitHub CLI instalado e autenticado:  gh auth login
    - você ser ADMIN do repositório

  USO (no PowerShell, de qualquer pasta)
    ./ferramentas/configurar-github.ps1 -Repo dsantos-docencia/Bash
    ./ferramentas/configurar-github.ps1 -Repo dsantos-docencia/Bash
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string]$Repo,
    [string]$Branch = 'main',
    [string]$CheckCI = 'verificar'   # nome do job de CI exigido
)

$ErrorActionPreference = 'Stop'

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host "erro: instale o GitHub CLI (gh) e rode 'gh auth login'." -ForegroundColor Red
    exit 1
}

Write-Host "➤ Repositório: $Repo   branch: $Branch" -ForegroundColor Cyan

Write-Host "① Proteção da branch '$Branch'..."
$protecao = @"
{
  "required_status_checks": { "strict": true, "contexts": ["$CheckCI"] },
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
"@
$protecao | gh api -X PUT "repos/$Repo/branches/$Branch/protection" -H "Accept: application/vnd.github+json" --input -
Write-Host "   ✔ branch protegida" -ForegroundColor Green

Write-Host "② Alertas de vulnerabilidade..."
gh api -X PUT "repos/$Repo/vulnerability-alerts"
Write-Host "   ✔ ligados" -ForegroundColor Green

Write-Host "③ Correções automáticas do Dependabot..."
gh api -X PUT "repos/$Repo/automated-security-fixes"
Write-Host "   ✔ ligadas" -ForegroundColor Green

Write-Host "④ Secret scanning + push protection..."
'{"security_and_analysis":{"secret_scanning":{"status":"enabled"},"secret_scanning_push_protection":{"status":"enabled"}}}' |
    gh api -X PATCH "repos/$Repo" --input -
Write-Host "   ✔ secret scanning ligado" -ForegroundColor Green

Write-Host ""
Write-Host "✅ Pronto! Confira em:" -ForegroundColor Green
Write-Host "   https://github.com/$Repo/settings/branches"
Write-Host "   https://github.com/$Repo/settings/security_analysis"
Write-Host ""
Write-Host "Obs.: contribuições externas passam a exigir Pull Request com sua revisão."
Write-Host "Você (admin) ainda faz merge dos seus próprios PRs (enforce_admins=false)."
