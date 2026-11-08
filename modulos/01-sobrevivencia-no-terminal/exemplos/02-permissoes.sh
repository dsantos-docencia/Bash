#!/usr/bin/env bash
# ============================================================================
#  Curso de Bash · Módulo 01 · Exemplo 02 — Permissões na prática
#  Prof. Daniel Santos · github.com/dsantos-docencia/bash · © 2026 (MIT)
# ----------------------------------------------------------------------------
#  OBJETIVO  Ver o efeito REAL de chmod (octal e simbólico) e de cada bit rwx.
#  EXECUTE   bash 02-permissoes.sh
#  SEGURO    Opera só em arquivos temporários.
# ============================================================================
set -euo pipefail
LAB="$(mktemp -d)"; trap 'rm -rf -- "$LAB"' EXIT
cd "$LAB"

# %a imprime as permissões em octal; %A em rwx. Ótimo para enxergar os dois.
mostrar() { stat -c '   %A (octal %a)  %n' "$1"; }

echo "Criando arquivos e aplicando permissões:"
touch nota.txt script.sh segredo.key

chmod 644 nota.txt      # rw-r--r-- : arquivo comum
chmod 755 script.sh     # rwxr-xr-x : programa que todos rodam
chmod 600 segredo.key   # rw------- : só o dono

mostrar nota.txt
mostrar script.sh
mostrar segredo.key

echo
echo "Modo SIMBÓLICO faz ajustes pontuais:"
chmod +x nota.txt;  echo "   chmod +x nota.txt  →"; mostrar nota.txt
chmod g-r,o-r segredo.key >/dev/null; echo "   (segredo continua só do dono)"; mostrar segredo.key

echo
echo "Octal é a SOMA dos bits:  r=4  w=2  x=1"
printf '   7=rwx  6=rw-  5=r-x  4=r--  0=---\n'
printf '   Ex.: 754 = rwx(7) r-x(5) r--(4)\n'

echo
echo "Num DIRETÓRIO, x significa 'posso entrar (cd)':"
mkdir cofre && chmod 700 cofre
mostrar cofre
echo "   700 = só o dono entra, lista e cria lá dentro."
