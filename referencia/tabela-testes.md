# ✅ Tabela de testes condicionais

Operadores para `[[ ... ]]` (strings/arquivos) e `(( ... ))` (números). Veja o [Módulo 04](../modulos/04-controle-de-fluxo/).

## Arquivos

| Teste | Verdadeiro se… |
|---|---|
| `-e arq` | existe (qualquer tipo) |
| `-f arq` | existe e é arquivo comum |
| `-d arq` | existe e é diretório |
| `-L arq` | é link simbólico |
| `-r` / `-w` / `-x` | você pode ler / escrever / executar |
| `-s arq` | existe e **não** está vazio |
| `arq1 -nt arq2` | arq1 mais novo que arq2 (*newer than*) |
| `arq1 -ot arq2` | arq1 mais velho (*older than*) |
| `arq1 -ef arq2` | mesmo arquivo (mesmo inode) |

## Strings (dentro de `[[ ]]`)

| Teste | Verdadeiro se… |
|---|---|
| `-z "$s"` | string **vazia** (zero) |
| `-n "$s"` | string **não** vazia |
| `"$a" == "$b"` | iguais (com `[[ ]]`, o lado direito pode ser padrão glob!) |
| `"$a" == "$b"` com aspas no `$b` | iguais, comparação literal |
| `"$a" != "$b"` | diferentes |
| `"$a" < "$b"` | `a` vem antes alfabeticamente |
| `"$a" =~ regex` | casa a expressão regular (ERE) |

> ⚠️ Em `[[ $x == a* ]]` o `a*` é **glob** (começa com a). Para comparar literalmente, cite: `[[ $x == "a*" ]]`. Para regex use `=~` **sem** aspas no padrão.

## Números (use `(( ))` ou os operadores `-eq` em `[[ ]]`)

| Em `(( ))` | Em `[[ ]]` / `[ ]` | Significado |
|---|---|---|
| `==` | `-eq` | igual |
| `!=` | `-ne` | diferente |
| `<` | `-lt` | menor |
| `<=` | `-le` | menor ou igual |
| `>` | `-gt` | maior |
| `>=` | `-ge` | maior ou igual |

```bash
(( idade >= 18 ))         # preferido para números
[[ "$n" -gt 10 ]]         # também funciona
```

## Combinando

| Em `[[ ]]` | Significado |
|---|---|
| `&&` | E |
| `\|\|` | OU |
| `!` | NÃO |
| `( ... )` | agrupamento |

```bash
[[ -f "$arq" && -r "$arq" ]]        # existe E é legível
[[ -z "$x" || "$x" == "sair" ]]     # vazio OU igual a "sair"
(( a > 0 && a < 100 ))
```

## `[ ]` vs `[[ ]]` vs `test`

| | `[ ]` / `test` | `[[ ]]` |
|---|---|---|
| Padrão | POSIX, portável a `sh` | Só Bash/ksh/zsh |
| Variáveis sem aspas | **perigoso** (quebra com espaços/vazio) | seguro |
| `&&` `\|\|` dentro | não (use `-a`/`-o`, frágeis) | sim |
| `==` com glob, `=~` regex | não | **sim** |
| Recomendação | só para scripts `sh` portáveis | **padrão no Bash** |

<sub>© 2026 Prof. Daniel Santos · CC BY-NC-SA 4.0</sub>
