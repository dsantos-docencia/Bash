# 🏋️ Exercícios — Módulo 00

Edite os arquivos `.sh` desta pasta e corrija com:

```bash
./ferramentas/corrigir.sh 00        # todos do módulo
./ferramentas/corrigir.sh 00 01     # só o exercício 01
```

Travou? As soluções comentadas estão em [solucoes/](solucoes/). Tente pelo menos 15 minutos antes de abrir — o esforço de lembrar é o que fixa o conhecimento.

---

### 01 — Olá, mundo · `01-ola-mundo.sh`
Faça o script imprimir exatamente:
```
Olá, mundo!
```

### 02 — Versão em duas partes · `02-versao.sh`
Usando o array `BASH_VERSINFO` (posições `0` e `1`), imprima a versão no formato:
```
Bash 5.2
```
(com os números da **sua** versão). Não use `bash --version` — leia a variável.

### 03 — Classificador · `03-classificador.sh`
O script recebe **um** nome de comando como argumento (`$1`) e imprime apenas a categoria devolvida por `type -t`. Se o comando não existir, imprima `desconhecido` e termine com código de saída `1`.
```console
$ bash 03-classificador.sh cd
builtin
$ bash 03-classificador.sh xyz
desconhecido
```

<sub>© 2026 Prof. Daniel Santos · CC BY-NC-SA 4.0</sub>
