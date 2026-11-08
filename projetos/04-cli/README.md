# Projeto 4 — CLI profissional (gerenciador de tarefas)

Um `todo` de linha de comando com **subcomandos** (estilo git), cores, `--help` e persistência em arquivo.

## Uso
```bash
export TAREFAS_ARQUIVO=./minhas.txt   # onde guardar (padrão ~/.tarefas.txt)
bash tarefas.sh add "Estudar o Módulo 08"
bash tarefas.sh add "Fazer backup"
bash tarefas.sh list
bash tarefas.sh done 1
bash tarefas.sh rm 2
```

## O que ele ensina
- **Subcomandos** com `case` (o padrão de CLIs como git/docker)
- `getopts` para opções globais + argumentos por subcomando
- **Cores ANSI** só quando a saída é um terminal (`[[ -t 1 ]]`)
- Arquivo de estado e edição segura via `mktemp` + `mv`
- Funções pequenas, uma por responsabilidade
