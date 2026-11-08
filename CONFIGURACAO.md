# ⚙️ Configuração administrativa do repositório

Algumas configurações (proteger a branch, ligar segurança) exigem **acesso de administrador** e precisam ser aplicadas por você. Há um script pronto que faz tudo de uma vez.

## Pré-requisitos
- [GitHub CLI](https://cli.github.com) instalado e autenticado: `gh auth login`
- Você ser admin do repositório

## Rodar
```bash
./ferramentas/configurar-github.sh dsantos-docencia/Bash
```

Isso aplica:

**Proteção da branch `main`**
- exige Pull Request (sem push direto na main)
- exige 1 revisão aprovada + revisão do CODEOWNERS (você)
- exige o CI (`verificar`) verde e a branch atualizada
- descarta aprovações obsoletas; exige conversas resolvidas
- histórico linear; bloqueia force-push e exclusão
- `enforce_admins=false`: você ainda faz merge dos seus próprios PRs quando precisar

**Segurança**
- alertas de vulnerabilidade
- correções automáticas do Dependabot
- secret scanning + push protection (barra segredos antes do commit)

> Por que não foi aplicado automaticamente? Configurações administrativas do GitHub não podem ser alteradas de dentro da sessão automatizada — elas dependem do seu token de admin. Daí o script, que você roda com um comando.

<sub>© 2026 Prof. Daniel Santos</sub>
