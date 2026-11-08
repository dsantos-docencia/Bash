# Laboratório do Curso de Bash — ambiente isolado e reproduzível
# Imagem pequena, mas com as ferramentas usadas ao longo do curso.
FROM debian:13-slim

# DEBIAN_FRONTEND evita prompts interativos durante o build.
ENV DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8

RUN apt-get update && apt-get install -y --no-install-recommends \
        bash \
        coreutils findutils grep sed gawk \
        less nano vim-tiny \
        shellcheck \
        bats \
        curl ca-certificates \
        procps \
        git \
    && rm -rf /var/lib/apt/lists/*

# Usuário sem privilégios: aprender como root é um mau hábito (Módulo 11).
RUN useradd -m -s /bin/bash aluno
USER aluno
WORKDIR /curso

# O repositório é montado como volume em /curso (veja entrar.sh),
# então o conteúdo sempre reflete o seu diretório local.
CMD ["bash"]
