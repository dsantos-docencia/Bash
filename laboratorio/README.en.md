# 🧪 Containerized Lab

**🌍 Idioma / Language:** [Português](README.md) · **English**

An **isolated, disposable, identical-for-everyone** environment, so you can practice without fear of messing up your system.

## Why use it?

- **Total isolation**: nothing you do here affects your computer.
- **Reproducible**: Debian 13 with Bash 5, ShellCheck, and Bats already installed — the same for every student.
- **Disposable**: once you leave, it's gone. Come back in, and it's a clean environment.

## Prerequisite

[Docker](https://docs.docker.com/get-docker/) installed.

## Usage

```bash
./laboratorio/entrar.sh
```

The first time, the image is built (a few minutes). After that it's instant. You land in a shell with the repository mounted at `/curso`:

```console
aluno@lab:/curso$ ./ferramentas/corrigir.sh 00
aluno@lab:/curso$ bats modulos/08-qualidade-e-testes/exemplos/*.bats
aluno@lab:/curso$ exit
```

The changes you make to the course files apply on both sides (it's a mounted volume), but **nothing is installed on your system** — it all lives inside the container.

## No Docker?

No problem. The whole course runs directly in your Bash. The container is just a convenience. See the environment options in [Module 00](../modulos/00-boas-vindas-e-fundamentos/README.en.md).

<sub>© 2026 Prof. Daniel Santos and translators · PolyForm NC (noncommercial)</sub>
