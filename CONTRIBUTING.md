# 🤝 Guia de Contribuição

**Junte-se a mim e deixe algo de útil para o próximo.** 🌱 Conhecimento que não é compartilhado morre com quem o guarda. Correções de erros, novos exemplos, exercícios, traduções, scripts da comunidade e melhorias de texto são todos bem-vindos — não importa o tamanho.

## Formas de contribuir

| Quero… | Como |
|---|---|
| **Corrigir um erro** (texto, exemplo, link) | [issue "🐛 Erro"](https://github.com/dsantos-docencia/Bash/issues/new/choose) ou PR direto |
| **Sugerir um exemplo/exercício** | [issue "💡 Sugestão"](https://github.com/dsantos-docencia/Bash/issues/new/choose) |
| **Compartilhar um script meu** | [issue "📜 Enviar um script"](https://github.com/dsantos-docencia/Bash/issues/new/choose) → entra em [`scripts/comunidade/`](scripts/comunidade/) com seu crédito |
| **Traduzir** | veja o [guia de tradução](traducoes/README.md) |

> **Sobre a licença das contribuições:** ao contribuir, você concorda que sua contribuição será publicada sob as licenças do projeto (**uso não comercial** — PolyForm Noncommercial para código, CC BY-NC-SA para conteúdo; veja o [NOTICE](NOTICE.md)), mantendo seu crédito como autor.

## Antes de começar

Este repositório tem uma promessa: **todo código aqui funciona**. Para mantê-la, existe uma verificação automática. Rode-a localmente antes de abrir um Pull Request:

```bash
./ferramentas/verificar-tudo.sh
```

Ela roda, para todo `.sh` (fora de `scripts/`):
1. **Sintaxe** (`bash -n`)
2. **ShellCheck** (instale com `apt install shellcheck`, `brew install shellcheck` ou veja [shellcheck.net](https://www.shellcheck.net))
3. **Execução** de todos os exemplos
4. **Soluções** oficiais contra os testes
5. **Testes** dos projetos

Se passar localmente, passará no [GitHub Actions](.github/workflows/verificar.yml).

## Padrão dos arquivos

### Módulos
```
modulos/NN-nome-do-modulo/
├── README.md                    # teoria: o PORQUÊ antes do COMO
├── exemplos/
│   └── NN-nome.sh               # executável, muito comentado, roda sozinho
└── exercicios/
    ├── README.md                # enunciados
    ├── NN-nome.sh               # esqueleto para o aluno preencher
    ├── solucoes/NN-nome.sh      # solução oficial comentada
    └── testes/NN-nome.teste.sh  # casos de teste (funções teste_*)
```

### Cabeçalho obrigatório em todo `.sh`
```bash
#!/usr/bin/env bash
# ============================================================================
#  Curso de Bash · Módulo NN · <título>
#  Prof. Daniel Santos · github.com/dsantos-docencia/Bash · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  OBJETIVO  ...
#  EXECUTE   ...
# ============================================================================
```

### Regras de ouro para exemplos
- **Devem rodar sem argumentos** e sem travar (`stdin` pode ser `/dev/null`).
- **Não podem alterar o sistema**: se precisam criar/apagar arquivos, use `mktemp -d` e `trap '... EXIT'`.
- Comentários explicam o **porquê**, não só o quê.
- Zero avisos do ShellCheck (ou um `# shellcheck disable=SCxxxx` justificado).

### Escrevendo um teste
Toda função `teste_*` em um arquivo `.teste.sh` é descoberta e rodada isoladamente. Os arquivos `.teste.sh` são *sourced* (não executados), então começam com a diretiva `# shellcheck shell=bash` em vez de shebang. As asserções disponíveis estão documentadas em [`ferramentas/lib/teste.sh`](ferramentas/lib/teste.sh):

```bash
# shellcheck shell=bash
teste_descricao_curta() {
    executar arg1 arg2          # roda o script do aluno
    afirmar_status 0
    afirmar_igual "esperado" "$SAIDA"
    afirmar_contem "trecho" "$SAIDA"
}
```

## Fluxo do Pull Request

1. Faça um fork e crie um branch: `git checkout -b meu-ajuste`
2. Faça as mudanças seguindo o padrão acima
3. Rode `./ferramentas/verificar-tudo.sh` — tudo verde
4. Commit com mensagem clara em português
5. Abra o PR descrevendo **o quê** e **por quê**

## Estilo de Bash adotado

- `#!/usr/bin/env bash` (não `#!/bin/bash`)
- Em scripts de produção: `set -euo pipefail`
- **Sempre** aspas em variáveis: `"$var"`, `"${array[@]}"`
- `[[ ]]` em vez de `[ ]` (estamos em Bash, não POSIX sh)
- Nomes de função e variável em `snake_case`, português é bem-vindo
- `$(...)` em vez de crase `` `...` ``

## Código de conduta

Seja gentil. Estamos aqui para aprender e ensinar. Veja [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).

<sub>© 2026 Prof. Daniel Santos</sub>
