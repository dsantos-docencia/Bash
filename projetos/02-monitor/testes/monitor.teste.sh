# shellcheck shell=bash
teste_tudo_ok_com_limites_altos() {
    # limites em 100% dificilmente são ultrapassados → status 0
    executar -d 100 -m 100
    afirmar_status 0
    afirmar_contem "dentro dos limites" "$SAIDA"
}

teste_alerta_com_limite_zero() {
    # limite 0% força o alerta de disco (uso sempre > 0)
    executar -d 0 -m 100
    afirmar_status 1
    afirmar_contem "ALERTA" "$SAIDA"
}

teste_relata_disco_memoria() {
    executar -d 100 -m 100
    afirmar_contem "disco" "$SAIDA"
    afirmar_contem "memória" "$SAIDA"
}

teste_ajuda() { executar -h; afirmar_status 0; afirmar_contem "Uso:" "$SAIDA"; }
