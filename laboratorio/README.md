# 🧪 Laboratório em container

Um ambiente **isolado, descartável e idêntico para todos**, para você praticar sem medo de bagunçar seu sistema.

## Por que usar?

- **Isolamento total**: nada que você fizer aqui afeta seu computador.
- **Reproduzível**: Debian 13 com Bash 5, ShellCheck e Bats já instalados — igual para todo aluno.
- **Descartável**: saiu, acabou. Entrou de novo, ambiente limpo.

## Pré-requisito

[Docker](https://docs.docker.com/get-docker/) instalado.

## Uso

```bash
./laboratorio/entrar.sh
```

Na primeira vez, a imagem é construída (uns minutos). Depois é instantâneo. Você cai num shell com o repositório montado em `/curso`:

```console
aluno@lab:/curso$ ./ferramentas/corrigir.sh 00
aluno@lab:/curso$ bats modulos/08-qualidade-e-testes/exemplos/*.bats
aluno@lab:/curso$ exit
```

As mudanças que você faz nos arquivos do curso valem dos dois lados (é um volume montado), mas **nada é instalado no seu sistema** — tudo vive dentro do container.

## Sem Docker?

Sem problema. Todo o curso roda direto no seu Bash. O container é só uma conveniência. Veja as opções de ambiente no [Módulo 00](../modulos/00-boas-vindas-e-fundamentos/README.md#5-seu-laboratório-um-lugar-seguro-para-errar).

<sub>© 2026 Prof. Daniel Santos · PolyForm NC (não comercial)</sub>
