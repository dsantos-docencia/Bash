#!/usr/bin/env bash
# Curso de Bash · Prof. Daniel Santos · github.com/dsantos-docencia/bash · © 2026 (MIT)
# Solução 02.01
gerar() { echo "resultado bom"; echo "deu ruim" >&2; }
# 1>/dev/null descarta o stdout; 2>&1 redireciona o stderr para o stdout
# ANTES de descartá-lo? Não — aqui mandamos stdout ao buraco e deixamos o
# stderr seguir para a tela. Truque: troca de canais.
gerar 2>&1 1>/dev/null
