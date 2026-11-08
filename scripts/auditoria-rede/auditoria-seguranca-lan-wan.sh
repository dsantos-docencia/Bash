#!/bin/bash
# ============================================================================
# SCRIPT DE AUDITORIA DE SEGURANÇA - Teste Local + Web
# Conteúdo de responsabilidade do Prof. Daniel Santos
# Uso exclusivamente acadêmico e instrucional
# Requer: Kali Linux ou Parrot OS
# Execução: sudo bash security_audit.sh
# ============================================================================


# ============================================================================
# COMPATIBILIDADE E DEPENDÊNCIAS
# ============================================================================
#
# Este script é compatível com:
#   - Kali Linux (todas as versões)
#   - Parrot Security Edition
#   - Parrot Home Edition (pode necessitar instalação de ferramentas)
#   - Qualquer distribuição baseada em Debian com as ferramentas instaladas
#
# Ferramentas utilizadas:
#   nmap          Varredura de portas, serviços, OS e scripts NSE
#   hydra         Teste de credenciais padrão (brute-force controlado)
#   enum4linux    Enumeração SMB/NetBIOS (shares, usuários, sessões nulas)
#   nikto         Scanner de vulnerabilidades web
#   gobuster      Enumeração de diretórios e arquivos ocultos
#   dirb          Alternativa ao gobuster para enumeração de diretórios
#   sslscan       Análise de certificados e cifras SSL/TLS
#   testssl.sh    Teste abrangente de configuração TLS (opcional)
#   openssl       Verificação de certificado e validade
#   wafw00f       Detecção de Web Application Firewall
#   sublist3r     Enumeração de subdomínios
#   amass         Alternativa ao sublist3r para subdomínios (opcional)
#   arp-scan      Descoberta de hosts na rede local
#   dig           Reconhecimento DNS (registros A, MX, NS, TXT, AXFR)
#   whois         Informações de registro do domínio
#   curl          Análise de headers HTTP de segurança
#
# Se alguma ferramenta não estiver instalada, a etapa correspondente
# será ignorada automaticamente e registrada no relatório.
# O script NÃO quebra por ausência de ferramentas.
#
# Para instalar todas as dependências de uma vez:
#   sudo apt update
#   sudo apt install -y nmap hydra enum4linux nikto gobuster dirb \
#       sslscan wafw00f sublist3r dnsutils whois curl openssl arp-scan
#
# ============================================================================

set -uo pipefail

# --- Cores ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# --- Tela de apresentação ---
clear
echo -e "${BOLD}${CYAN}"
cat << 'BANNER'

  ██████╗ ██████╗  ██████╗ ███████╗   ██████╗  █████╗ ███╗   ██╗██╗███████╗██╗
  ██╔══██╗██╔══██╗██╔═══██╗██╔════╝   ██╔══██╗██╔══██╗████╗  ██║██║██╔════╝██║
  ██████╔╝██████╔╝██║   ██║█████╗     ██║  ██║███████║██╔██╗ ██║██║█████╗  ██║
  ██╔═══╝ ██╔══██╗██║   ██║██╔══╝     ██║  ██║██╔══██║██║╚██╗██║██║██╔══╝  ██║
  ██║     ██║  ██║╚██████╔╝██║     ██╗██████╔╝██║  ██║██║ ╚████║██║███████╗███████╗
  ╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚═╝╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝╚══════╝╚══════╝

   ███████╗ █████╗ ███╗   ██╗████████╗ ██████╗ ███████╗
   ██╔════╝██╔══██╗████╗  ██║╚══██╔══╝██╔═══██╗██╔════╝
   ███████╗███████║██╔██╗ ██║   ██║   ██║   ██║███████╗
   ╚════██║██╔══██║██║╚██╗██║   ██║   ██║   ██║╚════██║
   ███████║██║  ██║██║ ╚████║   ██║   ╚██████╔╝███████║
   ╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝   ╚═╝    ╚═════╝ ╚══════╝

BANNER
echo -e "${NC}"

echo -e "${BOLD}${MAGENTA}══════════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${MAGENTA}  SECURITY AUDIT TOOL — Ferramenta de Auditoria de Segurança${NC}"
echo -e "${BOLD}${MAGENTA}══════════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${BOLD}  Responsável:${NC}  Prof. Daniel Santos"
echo -e "${BOLD}  Finalidade:${NC}   Exclusivamente acadêmica e instrucional"
echo -e "${BOLD}  Disciplina:${NC}   Segurança da Informação / Ethical Hacking"
echo ""
echo -e "${DIM}  Este material é parte integrante de atividade didática sob"
echo -e "  supervisão docente. O uso deste script fora do contexto de"
echo -e "  laboratório autorizado é de total responsabilidade do usuário"
echo -e "  e pode configurar infração legal (Lei 12.737/2012 - Marco Civil"
echo -e "  da Internet e Art. 154-A do Código Penal Brasileiro).${NC}"
echo ""
echo -e "${BOLD}${MAGENTA}══════════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${BOLD}${YELLOW}  O QUE ESTE SCRIPT FAZ${NC}"
echo ""
echo -e "${BOLD}  O script executa uma auditoria de segurança dividida em 2 testes:${NC}"
echo ""
echo -e "${CYAN}  ┌─────────────────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}  │${NC} ${BOLD}TESTE 1 — HOST EM REDE LOCAL (IP privado)${NC}                   ${CYAN}│${NC}"
echo -e "${CYAN}  │${NC}                                                             ${CYAN}│${NC}"
echo -e "${CYAN}  │${NC}  1.1  Ping — verifica se o host está online                ${CYAN}│${NC}"
echo -e "${CYAN}  │${NC}  1.2  Nmap TCP SYN — descobre portas abertas, versões de   ${CYAN}│${NC}"
echo -e "${CYAN}  │${NC}       serviços, sistema operacional e executa scripts de    ${CYAN}│${NC}"
echo -e "${CYAN}  │${NC}       vulnerabilidade conhecida (NSE)                       ${CYAN}│${NC}"
echo -e "${CYAN}  │${NC}  1.3  Nmap UDP — varre as 20 portas UDP mais comuns        ${CYAN}│${NC}"
echo -e "${CYAN}  │${NC}  1.4  enum4linux — enumera compartilhamentos SMB,          ${CYAN}│${NC}"
echo -e "${CYAN}  │${NC}       usuários e sessões nulas (NetBIOS/Windows)            ${CYAN}│${NC}"
echo -e "${CYAN}  │${NC}  1.5  Hydra — testa credenciais padrão no SSH              ${CYAN}│${NC}"
echo -e "${CYAN}  │${NC}       (root/admin/test com senhas comuns)                   ${CYAN}│${NC}"
echo -e "${CYAN}  │${NC}  1.6  Nmap NSE vuln — busca CVEs conhecidas em todas       ${CYAN}│${NC}"
echo -e "${CYAN}  │${NC}       as portas abertas                                    ${CYAN}│${NC}"
echo -e "${CYAN}  │${NC}  1.7  arp-scan — descobre todos os hosts da sub-rede       ${CYAN}│${NC}"
echo -e "${CYAN}  └─────────────────────────────────────────────────────────────┘${NC}"
echo ""
echo -e "${CYAN}  ┌─────────────────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}  │${NC} ${BOLD}TESTE 2 — SITE WEB PÚBLICO (URL HTTPS)${NC}                      ${CYAN}│${NC}"
echo -e "${CYAN}  │${NC}                                                             ${CYAN}│${NC}"
echo -e "${CYAN}  │${NC}  2.1  dig — reconhecimento DNS (A, MX, NS, TXT, SPF,       ${CYAN}│${NC}"
echo -e "${CYAN}  │${NC}       DMARC, tentativa de transferência de zona)            ${CYAN}│${NC}"
echo -e "${CYAN}  │${NC}  2.2  whois — informações de registro do domínio           ${CYAN}│${NC}"
echo -e "${CYAN}  │${NC}  2.3  sslscan/testssl/openssl — análise de certificado,    ${CYAN}│${NC}"
echo -e "${CYAN}  │${NC}       protocolos TLS, cifras fracas, validade               ${CYAN}│${NC}"
echo -e "${CYAN}  │${NC}  2.4  curl — verifica 7 headers HTTP de segurança          ${CYAN}│${NC}"
echo -e "${CYAN}  │${NC}       (HSTS, CSP, X-Frame-Options, etc.)                   ${CYAN}│${NC}"
echo -e "${CYAN}  │${NC}  2.5  Nikto — scanner de vulnerabilidades web              ${CYAN}│${NC}"
echo -e "${CYAN}  │${NC}       (misconfigurations, arquivos expostos, XSS, SQLi)     ${CYAN}│${NC}"
echo -e "${CYAN}  │${NC}  2.6  gobuster/dirb — enumeração de diretórios ocultos     ${CYAN}│${NC}"
echo -e "${CYAN}  │${NC}       (.git, .env, /admin, /backup, /phpmyadmin)            ${CYAN}│${NC}"
echo -e "${CYAN}  │${NC}  2.7  Nmap — portas expostas no servidor web               ${CYAN}│${NC}"
echo -e "${CYAN}  │${NC}  2.8  wafw00f — detecta presença de WAF                    ${CYAN}│${NC}"
echo -e "${CYAN}  │${NC}  2.9  sublist3r/amass — enumera subdomínios                ${CYAN}│${NC}"
echo -e "${CYAN}  └─────────────────────────────────────────────────────────────┘${NC}"
echo ""
echo -e "${BOLD}${YELLOW}  FORMATO DA SAÍDA${NC}"
echo ""
echo -e "  Ao final, o script gera uma pasta ${CYAN}audit_report_<timestamp>/${NC} contendo:"
echo ""
echo -e "  ${GREEN}relatorio_final.txt${NC}   Relatório técnico completo com toda a saída"
echo -e "                        de cada ferramenta, linha por linha."
echo ""
echo -e "  ${GREEN}resumo_executivo.txt${NC}  Resumo em linguagem humana contendo:"
echo -e "                        - Lista de ferramentas utilizadas e o que cada uma fez"
echo -e "                        - Contagem de vulnerabilidades, alertas e itens OK"
echo -e "                        - Todas as vulnerabilidades encontradas com explicação"
echo -e "                        - Recomendações de correção passo a passo"
echo -e "                        - Cenários reais de comprometimento (como um atacante"
echo -e "                          exploraria cada falha encontrada)"
echo -e "                        - Classificação de risco (Crítico/Alto/Médio/Baixo)"
echo ""
echo -e "  ${GREEN}Arquivos individuais${NC}  Saída bruta de cada ferramenta (nmap_tcp_local.txt,"
echo -e "                        sslscan.txt, nikto.txt, etc.) para análise aprofundada."
echo ""
echo -e "${BOLD}${YELLOW}  INTENCIONALIDADE PEDAGÓGICA${NC}"
echo ""
echo -e "  Este script foi projetado para que o aluno:"
echo ""
echo -e "  ${CYAN}1.${NC} Compreenda na prática como ferramentas de pentest funcionam"
echo -e "  ${CYAN}2.${NC} Identifique vulnerabilidades reais em ambientes controlados"
echo -e "  ${CYAN}3.${NC} Aprenda a interpretar resultados técnicos de auditoria"
echo -e "  ${CYAN}4.${NC} Desenvolva capacidade de propor correções e melhorias"
echo -e "  ${CYAN}5.${NC} Entenda os riscos reais de cada falha de segurança"
echo -e "  ${CYAN}6.${NC} Pratique documentação profissional de achados de segurança"
echo ""
echo -e "${RED}${BOLD}  AVISO LEGAL${NC}"
echo -e "${RED}  ─────────────────────────────────────────────────────────────${NC}"
echo -e "${RED}  Execute este script SOMENTE em sistemas que você possui ou${NC}"
echo -e "${RED}  tem autorização EXPLÍCITA E DOCUMENTADA para testar.${NC}"
echo -e "${RED}  Testes não autorizados são crime (Lei 12.737/2012).${NC}"
echo -e "${RED}  O Prof. Daniel Santos e a instituição não se responsabilizam${NC}"
echo -e "${RED}  pelo uso indevido desta ferramenta fora do ambiente de aula.${NC}"
echo -e "${RED}  ─────────────────────────────────────────────────────────────${NC}"
echo ""
echo -e "${BOLD}${MAGENTA}══════════════════════════════════════════════════════════════════${NC}"
echo ""

# --- Confirmação para prosseguir ---
echo -e "${BOLD}${YELLOW}  Deseja prosseguir com a auditoria? ${NC}"
echo ""
echo -e "  ${GREEN}[S]${NC} Sim, possuo autorização e desejo continuar"
echo -e "  ${RED}[N]${NC} Não, desejo cancelar"
echo ""
read -rp "  Sua escolha (S/N): " CONFIRM

if [[ ! "$CONFIRM" =~ ^[Ss]$ ]]; then
    echo ""
    echo -e "${YELLOW}  Auditoria cancelada pelo usuário. Nenhuma ação foi realizada.${NC}"
    echo ""
    exit 0
fi

echo ""
echo -e "${GREEN}${BOLD}  Confirmação aceita. Iniciando coleta de informações...${NC}"
echo ""

# --- Configuração ---
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
REPORT_DIR="./audit_report_${TIMESTAMP}"
mkdir -p "$REPORT_DIR"

REPORT_FILE="${REPORT_DIR}/relatorio_final.txt"
SUMMARY_FILE="${REPORT_DIR}/resumo_executivo.txt"

# --- Funções auxiliares ---
log_section() {
    echo -e "\n${BLUE}${BOLD}========================================${NC}"
    echo -e "${BLUE}${BOLD}  $1${NC}"
    echo -e "${BLUE}${BOLD}========================================${NC}\n"
    echo "" >> "$REPORT_FILE"
    echo "========================================" >> "$REPORT_FILE"
    echo "  $1" >> "$REPORT_FILE"
    echo "========================================" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
}

log_info() {
    echo -e "${CYAN}[INFO]${NC} $1"
    echo "[INFO] $1" >> "$REPORT_FILE"
}

log_warn() {
    echo -e "${YELLOW}[ALERTA]${NC} $1"
    echo "[ALERTA] $1" >> "$REPORT_FILE"
}

log_vuln() {
    echo -e "${RED}[VULNERABILIDADE]${NC} $1"
    echo "[VULNERABILIDADE] $1" >> "$REPORT_FILE"
}

log_ok() {
    echo -e "${GREEN}[OK]${NC} $1"
    echo "[OK] $1" >> "$REPORT_FILE"
}

check_tool() {
    if command -v "$1" &>/dev/null; then
        return 0
    else
        echo -e "${YELLOW}[AVISO] Ferramenta '$1' não encontrada. Pulando etapa.${NC}"
        echo "[AVISO] Ferramenta '$1' não encontrada. Etapa ignorada." >> "$REPORT_FILE"
        return 1
    fi
}

append_raw() {
    echo "$1" >> "$REPORT_FILE"
}

# --- Verificação de root ---
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Este script precisa ser executado como root (sudo).${NC}"
    exit 1
fi

# --- Verificação de ferramentas disponíveis ---
echo -e "${BOLD}${CYAN}  Verificando ferramentas instaladas...${NC}"
echo ""

TOOLS_LIST=(nmap hydra enum4linux arp-scan sslscan openssl nikto gobuster dirb wafw00f sublist3r amass dig whois curl testssl.sh)
TOOLS_OK=0
TOOLS_MISSING=0

for tool in "${TOOLS_LIST[@]}"; do
    if command -v "$tool" &>/dev/null; then
        echo -e "  ${GREEN}[OK]${NC} $tool"
        ((TOOLS_OK++))
    else
        echo -e "  ${RED}[--]${NC} $tool ${DIM}(não instalada, etapa será ignorada)${NC}"
        ((TOOLS_MISSING++))
    fi
done

echo ""
echo -e "  ${GREEN}$TOOLS_OK disponíveis${NC} | ${RED}$TOOLS_MISSING ausentes${NC}"
echo ""

# --- Cabeçalho do Relatório ---
cat > "$REPORT_FILE" << HEADER
╔══════════════════════════════════════════════════════════════╗
║          RELATÓRIO DE AUDITORIA DE SEGURANÇA                ║
║          Prof. Daniel Santos — Uso Acadêmico                ║
╚══════════════════════════════════════════════════════════════╝

Data:       $(date '+%Y-%m-%d %H:%M:%S')
Executado:  $(whoami)@$(hostname)
Sistema:    $(uname -a)
Finalidade: Material didático — Segurança da Informação

HEADER

# --- Solicitar alvos ---
echo -e "${BOLD}${CYAN}══════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${CYAN}  CONFIGURAÇÃO DOS ALVOS${NC}"
echo -e "${BOLD}${CYAN}══════════════════════════════════════════════════${NC}"
echo ""

read -rp "  [TESTE 1] IP da rede local (ex: 192.168.1.100): " LOCAL_IP
read -rp "  [TESTE 2] URL pública HTTPS (ex: https://exemplo.com): " PUBLIC_URL

DOMAIN=$(echo "$PUBLIC_URL" | sed -e 's|https\?://||' -e 's|/.*||' -e 's|:.*||')

echo "" >> "$REPORT_FILE"
echo "Alvo local: $LOCAL_IP" >> "$REPORT_FILE"
echo "Alvo web:   $PUBLIC_URL ($DOMAIN)" >> "$REPORT_FILE"

echo ""
echo -e "${GREEN}${BOLD}  Alvos configurados:${NC}"
echo -e "    Teste 1: ${CYAN}$LOCAL_IP${NC}"
echo -e "    Teste 2: ${CYAN}$PUBLIC_URL${NC} (domínio: ${CYAN}$DOMAIN${NC})"
echo ""

# --- Barra de progresso simples ---
TOTAL_STEPS=16
CURRENT_STEP=0

progress() {
    ((CURRENT_STEP++))
    local pct=$((CURRENT_STEP * 100 / TOTAL_STEPS))
    local filled=$((pct / 5))
    local empty=$((20 - filled))
    local bar=$(printf '%0.s█' $(seq 1 $filled 2>/dev/null) 2>/dev/null || echo "")
    local space=$(printf '%0.s░' $(seq 1 $empty 2>/dev/null) 2>/dev/null || echo "")
    echo -e "${CYAN}  [${bar}${space}] ${pct}% — Etapa ${CURRENT_STEP}/${TOTAL_STEPS}: $1${NC}"
}

echo -e "${GREEN}${BOLD}  Iniciando auditoria...${NC}"
echo ""

# ============================================================================
#                    TESTE 1 - REDE LOCAL (IP)
# ============================================================================

log_section "TESTE 1 - AUDITORIA DE HOST LOCAL ($LOCAL_IP)"

# ---------- 1.1 Verificação de conectividade ----------
progress "Verificação de conectividade (ping)"
log_section "1.1 - Verificação de Conectividade"
if ping -c 3 -W 2 "$LOCAL_IP" &>/dev/null; then
    log_ok "Host $LOCAL_IP está respondendo a ping (ICMP ativo)."
else
    log_warn "Host $LOCAL_IP NÃO responde a ping. ICMP pode estar bloqueado ou host offline."
    log_info "Continuando mesmo assim — portas TCP ainda podem estar acessíveis."
fi

# ---------- 1.2 Descoberta de portas (Nmap TCP SYN) ----------
progress "Varredura TCP (nmap SYN scan)"
log_section "1.2 - Varredura de Portas TCP (Top 1000 + comuns)"
if check_tool nmap; then
    log_info "Executando nmap SYN scan em $LOCAL_IP..."
    NMAP_TCP_FILE="${REPORT_DIR}/nmap_tcp_local.txt"

    nmap -sS -sV -O -A --script=default,vuln \
         -p 1-1024,1433,1521,3306,3389,5432,5900,6379,8080,8443,9200,27017 \
         -T4 --open "$LOCAL_IP" -oN "$NMAP_TCP_FILE" 2>/dev/null

    log_info "Resultado salvo em $NMAP_TCP_FILE"
    append_raw "$(cat "$NMAP_TCP_FILE")"

    echo "" >> "$REPORT_FILE"
    echo "--- ANÁLISE DE PORTAS ENCONTRADAS ---" >> "$REPORT_FILE"

    declare -A PORT_RISKS=(
        [21]="FTP - Transferência de arquivos sem criptografia. RISCO: credenciais em texto claro."
        [22]="SSH - Acesso remoto. RISCO: brute-force se senha fraca ou versão desatualizada."
        [23]="Telnet - Acesso remoto SEM criptografia. RISCO CRÍTICO: tudo em texto claro."
        [25]="SMTP - Servidor de e-mail. RISCO: relay aberto, spoofing."
        [53]="DNS - Servidor DNS. RISCO: transferência de zona, amplificação DDoS."
        [80]="HTTP - Web sem criptografia. RISCO: dados interceptáveis."
        [110]="POP3 - E-mail sem criptografia. RISCO: credenciais expostas."
        [135]="MSRPC - RPC Microsoft. RISCO: exploits remotos (EternalBlue)."
        [139]="NetBIOS - Compartilhamento Windows. RISCO: enumeração de shares."
        [443]="HTTPS - Web criptografado. Verificar certificado e cifras."
        [445]="SMB - Compartilhamento de arquivos Windows. RISCO ALTO: EternalBlue, WannaCry."
        [1433]="MSSQL - Banco de dados. RISCO: acesso direto, injeção SQL."
        [3306]="MySQL - Banco de dados. RISCO: acesso sem autenticação."
        [3389]="RDP - Área de trabalho remota. RISCO: BlueKeep, brute-force."
        [5432]="PostgreSQL - Banco de dados. RISCO: acesso externo."
        [5900]="VNC - Controle remoto. RISCO: sem autenticação ou senha fraca."
        [6379]="Redis - Cache/DB. RISCO CRÍTICO: frequentemente sem autenticação."
        [8080]="HTTP alternativo - Proxy ou app web. RISCO: painel admin exposto."
        [9200]="Elasticsearch - RISCO CRÍTICO: acesso sem autenticação."
        [27017]="MongoDB - RISCO CRÍTICO: frequentemente sem autenticação."
    )

    for port in "${!PORT_RISKS[@]}"; do
        if grep -qE "^${port}/tcp\s+open" "$NMAP_TCP_FILE" 2>/dev/null; then
            log_vuln "Porta $port aberta: ${PORT_RISKS[$port]}"
        fi
    done
fi

# ---------- 1.3 Varredura UDP ----------
progress "Varredura UDP (nmap top 20)"
log_section "1.3 - Varredura de Portas UDP (selecionadas)"
if check_tool nmap; then
    log_info "Executando nmap UDP scan (portas selecionadas)..."
    NMAP_UDP_FILE="${REPORT_DIR}/nmap_udp_local.txt"

    nmap -sU -sV --top-ports 20 -T4 --open "$LOCAL_IP" -oN "$NMAP_UDP_FILE" 2>/dev/null

    log_info "Resultado salvo em $NMAP_UDP_FILE"
    append_raw "$(cat "$NMAP_UDP_FILE")"

    if grep -q "open" "$NMAP_UDP_FILE" 2>/dev/null; then
        log_warn "Portas UDP abertas detectadas. Serviços UDP são frequentemente esquecidos e mal configurados."
    fi
fi

# ---------- 1.4 Enumeração SMB ----------
progress "Enumeração SMB (enum4linux)"
log_section "1.4 - Enumeração SMB/NetBIOS"
if check_tool enum4linux; then
    if nmap -p 445 --open "$LOCAL_IP" 2>/dev/null | grep -q "open"; then
        log_info "Porta 445 aberta. Executando enum4linux..."
        ENUM_FILE="${REPORT_DIR}/enum4linux_local.txt"
        enum4linux -a "$LOCAL_IP" > "$ENUM_FILE" 2>/dev/null || true

        if grep -qi "share" "$ENUM_FILE" 2>/dev/null; then
            log_vuln "Compartilhamentos SMB encontrados. Verifique permissões."
            grep -i "share" "$ENUM_FILE" >> "$REPORT_FILE" 2>/dev/null || true
        fi
        if grep -qi "null session" "$ENUM_FILE" 2>/dev/null; then
            log_vuln "Sessão nula SMB permitida — enumeração anônima possível."
        fi
    else
        log_ok "Porta 445 (SMB) não está aberta."
    fi
fi

# ---------- 1.5 Teste de credenciais padrão SSH ----------
progress "Teste de credenciais SSH (hydra)"
log_section "1.5 - Teste de Credenciais Padrão (SSH)"
if check_tool hydra; then
    if nmap -p 22 --open "$LOCAL_IP" 2>/dev/null | grep -q "open"; then
        log_info "Porta 22 aberta. Testando credenciais padrão com Hydra (lista mínima)..."

        USERLIST="${REPORT_DIR}/users_default.txt"
        PASSLIST="${REPORT_DIR}/pass_default.txt"
        cat > "$USERLIST" << 'EOF'
root
admin
user
test
ubuntu
pi
EOF
        cat > "$PASSLIST" << 'EOF'
root
admin
password
123456
toor
1234
test
changeme
EOF

        HYDRA_FILE="${REPORT_DIR}/hydra_ssh.txt"
        hydra -L "$USERLIST" -P "$PASSLIST" -t 4 -f -o "$HYDRA_FILE" \
              ssh://"$LOCAL_IP" 2>/dev/null || true

        if [ -s "$HYDRA_FILE" ] && grep -q "host:" "$HYDRA_FILE" 2>/dev/null; then
            log_vuln "CREDENCIAIS PADRÃO ENCONTRADAS NO SSH! Detalhes:"
            cat "$HYDRA_FILE" >> "$REPORT_FILE"
        else
            log_ok "Nenhuma credencial padrão funcionou no SSH."
        fi

        rm -f "$USERLIST" "$PASSLIST"
    else
        log_ok "Porta 22 (SSH) não está aberta."
    fi
fi

# ---------- 1.6 Verificação de vulnerabilidades conhecidas ----------
progress "Scripts NSE de vulnerabilidade (nmap)"
log_section "1.6 - Scripts NSE de Vulnerabilidade"
if check_tool nmap; then
    log_info "Executando scripts NSE de vulnerabilidade..."
    NMAP_VULN_FILE="${REPORT_DIR}/nmap_vuln_local.txt"

    nmap --script vuln -p- --open -T4 "$LOCAL_IP" -oN "$NMAP_VULN_FILE" 2>/dev/null || true

    if grep -qiE "VULNERABLE|CVE-" "$NMAP_VULN_FILE" 2>/dev/null; then
        log_vuln "Vulnerabilidades conhecidas (CVEs) detectadas!"
        grep -iE "VULNERABLE|CVE-|State:" "$NMAP_VULN_FILE" >> "$REPORT_FILE" 2>/dev/null || true
    else
        log_ok "Nenhuma vulnerabilidade conhecida detectada pelos scripts NSE."
    fi
fi

# ---------- 1.7 ARP e detecção na rede local ----------
progress "Descoberta de hosts (arp-scan)"
log_section "1.7 - Detecção de Hosts na Sub-rede"
if check_tool arp-scan; then
    SUBNET=$(echo "$LOCAL_IP" | sed 's/\.[0-9]*$/.0\/24/')
    log_info "Executando arp-scan na sub-rede $SUBNET..."
    ARP_FILE="${REPORT_DIR}/arp_scan.txt"
    arp-scan --localnet > "$ARP_FILE" 2>/dev/null || true
    HOSTS_COUNT=$(grep -cE "([0-9a-f]{2}:){5}" "$ARP_FILE" 2>/dev/null || echo "0")
    log_info "Hosts detectados na rede: $HOSTS_COUNT"
    append_raw "$(cat "$ARP_FILE")"
fi


# ============================================================================
#                    TESTE 2 - URL PÚBLICA HTTPS
# ============================================================================

log_section "TESTE 2 - AUDITORIA WEB ($PUBLIC_URL)"

# ---------- 2.1 Resolução DNS ----------
progress "Reconhecimento DNS (dig)"
log_section "2.1 - Reconhecimento DNS"
if check_tool dig; then
    log_info "Consultando registros DNS de $DOMAIN..."
    DNS_FILE="${REPORT_DIR}/dns_recon.txt"

    {
        echo "=== Registro A ==="
        dig +short A "$DOMAIN" 2>/dev/null
        echo ""
        echo "=== Registro AAAA ==="
        dig +short AAAA "$DOMAIN" 2>/dev/null
        echo ""
        echo "=== Registro MX ==="
        dig +short MX "$DOMAIN" 2>/dev/null
        echo ""
        echo "=== Registro NS ==="
        dig +short NS "$DOMAIN" 2>/dev/null
        echo ""
        echo "=== Registro TXT (SPF/DKIM/DMARC) ==="
        dig +short TXT "$DOMAIN" 2>/dev/null
        echo ""
        echo "=== DMARC ==="
        dig +short TXT "_dmarc.$DOMAIN" 2>/dev/null
        echo ""
        echo "=== Transferência de Zona ==="
        for ns in $(dig +short NS "$DOMAIN" 2>/dev/null); do
            echo "Tentando AXFR em $ns..."
            dig @"$ns" "$DOMAIN" AXFR +short 2>/dev/null || echo "Negado (bom)."
        done
    } > "$DNS_FILE" 2>/dev/null

    append_raw "$(cat "$DNS_FILE")"

    if grep -qv "Negado" "$DNS_FILE" 2>/dev/null && grep -q "AXFR" "$DNS_FILE" 2>/dev/null; then
        log_vuln "Transferência de zona DNS pode estar habilitada!"
    else
        log_ok "Transferência de zona DNS negada corretamente."
    fi

    if ! dig +short TXT "$DOMAIN" 2>/dev/null | grep -q "v=spf1"; then
        log_warn "Registro SPF não encontrado. E-mails do domínio podem ser falsificados."
    fi
    if ! dig +short TXT "_dmarc.$DOMAIN" 2>/dev/null | grep -q "v=DMARC1"; then
        log_warn "Registro DMARC não encontrado. Proteção contra spoofing de e-mail ausente."
    fi
fi

# ---------- 2.2 Whois ----------
progress "Informações WHOIS"
log_section "2.2 - Informações WHOIS"
if check_tool whois; then
    log_info "Consultando WHOIS de $DOMAIN..."
    WHOIS_FILE="${REPORT_DIR}/whois.txt"
    whois "$DOMAIN" > "$WHOIS_FILE" 2>/dev/null || true
    log_info "Resultado salvo em $WHOIS_FILE"

    if grep -qi "registrant" "$WHOIS_FILE" 2>/dev/null; then
        log_warn "Informações do registrante expostas no WHOIS. Considere proteção de privacidade."
    fi
fi

# ---------- 2.3 SSL/TLS ----------
progress "Análise SSL/TLS (sslscan + openssl)"
log_section "2.3 - Análise de Certificado e Cifras SSL/TLS"

if check_tool sslscan; then
    log_info "Executando sslscan em $DOMAIN..."
    SSL_FILE="${REPORT_DIR}/sslscan.txt"
    sslscan --no-colour "$DOMAIN" > "$SSL_FILE" 2>/dev/null || true
    append_raw "$(cat "$SSL_FILE")"

    if grep -qi "SSLv2\|SSLv3" "$SSL_FILE" 2>/dev/null && grep -qi "Enabled\|Accepted" "$SSL_FILE" 2>/dev/null; then
        log_vuln "Protocolos obsoletos (SSLv2/SSLv3) habilitados! Vulnerável a POODLE/DROWN."
    fi
    if grep -qi "TLSv1.0\|TLSv1.1" "$SSL_FILE" 2>/dev/null && grep -qi "Accepted" "$SSL_FILE" 2>/dev/null; then
        log_warn "TLS 1.0/1.1 ainda aceito. Esses protocolos são considerados inseguros."
    fi
    if grep -qi "RC4\|DES\|NULL\|EXPORT" "$SSL_FILE" 2>/dev/null; then
        log_vuln "Cifras fracas detectadas (RC4/DES/NULL/EXPORT)."
    fi
fi

if check_tool testssl.sh; then
    log_info "Executando testssl.sh para análise completa..."
    TESTSSL_FILE="${REPORT_DIR}/testssl.txt"
    testssl.sh --quiet --color 0 "$DOMAIN" > "$TESTSSL_FILE" 2>/dev/null || true
    log_info "Resultado detalhado salvo em $TESTSSL_FILE"
fi

if check_tool openssl; then
    log_info "Verificando certificado com openssl..."
    CERT_FILE="${REPORT_DIR}/cert_info.txt"

    echo | openssl s_client -connect "$DOMAIN":443 -servername "$DOMAIN" 2>/dev/null | \
        openssl x509 -noout -dates -subject -issuer -ext subjectAltName > "$CERT_FILE" 2>/dev/null || true

    if [ -s "$CERT_FILE" ]; then
        append_raw "$(cat "$CERT_FILE")"
        EXPIRY=$(grep "notAfter" "$CERT_FILE" 2>/dev/null | cut -d= -f2)
        if [ -n "$EXPIRY" ]; then
            EXPIRY_EPOCH=$(date -d "$EXPIRY" +%s 2>/dev/null || echo "0")
            NOW_EPOCH=$(date +%s)
            DAYS_LEFT=$(( (EXPIRY_EPOCH - NOW_EPOCH) / 86400 ))
            if [ "$DAYS_LEFT" -lt 0 ]; then
                log_vuln "Certificado SSL EXPIRADO!"
            elif [ "$DAYS_LEFT" -lt 30 ]; then
                log_warn "Certificado SSL expira em $DAYS_LEFT dias. Renovar urgentemente."
            else
                log_ok "Certificado SSL válido por mais $DAYS_LEFT dias."
            fi
        fi
    fi
fi

# ---------- 2.4 Headers HTTP de segurança ----------
progress "Headers HTTP de segurança (curl)"
log_section "2.4 - Headers HTTP de Segurança"
log_info "Verificando headers de segurança..."
HEADERS_FILE="${REPORT_DIR}/http_headers.txt"
curl -sI -L --max-time 15 "$PUBLIC_URL" > "$HEADERS_FILE" 2>/dev/null || true

if [ -s "$HEADERS_FILE" ]; then
    append_raw "$(cat "$HEADERS_FILE")"

    declare -A SECURITY_HEADERS=(
        ["Strict-Transport-Security"]="HSTS - Força uso de HTTPS. Sem ele, ataques de downgrade são possíveis."
        ["Content-Security-Policy"]="CSP - Previne XSS e injeção de conteúdo. Sem ele, scripts maliciosos podem ser injetados."
        ["X-Content-Type-Options"]="Previne MIME sniffing. Sem ele, arquivos podem ser interpretados incorretamente."
        ["X-Frame-Options"]="Previne clickjacking. Sem ele, o site pode ser embutido em iframes maliciosos."
        ["X-XSS-Protection"]="Filtro XSS do navegador. Camada extra de proteção (legado)."
        ["Referrer-Policy"]="Controla informações enviadas no header Referer."
        ["Permissions-Policy"]="Controla acesso a APIs do navegador (câmera, microfone, etc.)."
    )

    for header in "${!SECURITY_HEADERS[@]}"; do
        if grep -qi "$header" "$HEADERS_FILE" 2>/dev/null; then
            log_ok "Header presente: $header"
        else
            log_vuln "Header AUSENTE: $header — ${SECURITY_HEADERS[$header]}"
        fi
    done

    if grep -qi "^Server:" "$HEADERS_FILE" 2>/dev/null; then
        SERVER_HEADER=$(grep -i "^Server:" "$HEADERS_FILE" | head -1)
        log_warn "Header 'Server' exposto: $SERVER_HEADER — Revela tecnologia do servidor."
    fi
    if grep -qi "^X-Powered-By:" "$HEADERS_FILE" 2>/dev/null; then
        POWERED=$(grep -i "^X-Powered-By:" "$HEADERS_FILE" | head -1)
        log_vuln "Header 'X-Powered-By' exposto: $POWERED — Revela framework/linguagem."
    fi
fi

# ---------- 2.5 Nikto ----------
progress "Scanner web (Nikto)"
log_section "2.5 - Scanner de Vulnerabilidades Web (Nikto)"
if check_tool nikto; then
    log_info "Executando Nikto em $PUBLIC_URL (pode demorar alguns minutos)..."
    NIKTO_FILE="${REPORT_DIR}/nikto.txt"
    nikto -h "$PUBLIC_URL" -output "$NIKTO_FILE" -Format txt -Tuning 1234567890abc \
          -maxtime 300 2>/dev/null || true

    if [ -s "$NIKTO_FILE" ]; then
        NIKTO_FINDINGS=$(grep -c "+" "$NIKTO_FILE" 2>/dev/null || echo "0")
        log_info "Nikto encontrou $NIKTO_FINDINGS itens. Detalhes em $NIKTO_FILE"
        append_raw "$(cat "$NIKTO_FILE")"
    fi
fi

# ---------- 2.6 Enumeração de diretórios ----------
progress "Enumeração de diretórios (gobuster/dirb)"
log_section "2.6 - Enumeração de Diretórios e Arquivos"
if check_tool gobuster; then
    WORDLIST="/usr/share/wordlists/dirb/common.txt"
    if [ -f "$WORDLIST" ]; then
        log_info "Executando gobuster em $PUBLIC_URL..."
        GOBUSTER_FILE="${REPORT_DIR}/gobuster.txt"
        gobuster dir -u "$PUBLIC_URL" -w "$WORDLIST" -t 20 -q --no-error \
                 -o "$GOBUSTER_FILE" --timeout 10s 2>/dev/null || true

        if [ -s "$GOBUSTER_FILE" ]; then
            log_info "Diretórios/arquivos encontrados:"
            append_raw "$(cat "$GOBUSTER_FILE")"

            for path in "admin" "backup" "config" "phpinfo" ".env" ".git" "wp-admin" "phpmyadmin"; do
                if grep -qi "/$path" "$GOBUSTER_FILE" 2>/dev/null; then
                    log_vuln "Caminho sensível acessível: /$path"
                fi
            done
        fi
    else
        log_warn "Wordlist não encontrada em $WORDLIST. Pulando gobuster."
    fi
elif check_tool dirb; then
    log_info "Executando dirb em $PUBLIC_URL..."
    DIRB_FILE="${REPORT_DIR}/dirb.txt"
    dirb "$PUBLIC_URL" -o "$DIRB_FILE" -S -r 2>/dev/null || true
    if [ -s "$DIRB_FILE" ]; then
        append_raw "$(cat "$DIRB_FILE")"
    fi
fi

# ---------- 2.7 Nmap no alvo web ----------
progress "Portas do servidor web (nmap)"
log_section "2.7 - Varredura de Portas no Servidor Web"
if check_tool nmap; then
    log_info "Executando nmap em $DOMAIN..."
    NMAP_WEB_FILE="${REPORT_DIR}/nmap_web.txt"
    nmap -sS -sV -T4 --open -p 1-1024,3306,3389,5432,8080,8443,9200 \
         "$DOMAIN" -oN "$NMAP_WEB_FILE" 2>/dev/null || true
    append_raw "$(cat "$NMAP_WEB_FILE")"

    if grep -qE "(3306|5432|27017|6379|9200)/tcp\s+open" "$NMAP_WEB_FILE" 2>/dev/null; then
        log_vuln "PORTA DE BANCO DE DADOS EXPOSTA PUBLICAMENTE! Risco crítico de acesso não autorizado."
    fi
    if grep -qE "3389/tcp\s+open" "$NMAP_WEB_FILE" 2>/dev/null; then
        log_vuln "RDP (3389) exposto publicamente! Risco de brute-force e exploits."
    fi
fi

# ---------- 2.8 WAF Detection ----------
progress "Detecção de WAF (wafw00f)"
log_section "2.8 - Detecção de WAF (Web Application Firewall)"
if check_tool wafw00f; then
    log_info "Verificando presença de WAF..."
    WAF_FILE="${REPORT_DIR}/waf.txt"
    wafw00f "$PUBLIC_URL" > "$WAF_FILE" 2>/dev/null || true
    append_raw "$(cat "$WAF_FILE")"

    if grep -qi "No WAF\|is not behind" "$WAF_FILE" 2>/dev/null; then
        log_warn "Nenhum WAF detectado. O site não possui camada de proteção contra ataques web."
    else
        log_ok "WAF detectado. O site possui proteção adicional."
    fi
fi

# ---------- 2.9 Subdomain Enumeration ----------
progress "Enumeração de subdomínios (sublist3r)"
log_section "2.9 - Enumeração de Subdomínios"
if check_tool sublist3r; then
    log_info "Enumerando subdomínios de $DOMAIN..."
    SUBDOMAIN_FILE="${REPORT_DIR}/subdomains.txt"
    sublist3r -d "$DOMAIN" -o "$SUBDOMAIN_FILE" 2>/dev/null || true

    if [ -s "$SUBDOMAIN_FILE" ]; then
        SUB_COUNT=$(wc -l < "$SUBDOMAIN_FILE" 2>/dev/null || echo "0")
        log_info "Subdomínios encontrados: $SUB_COUNT"
        append_raw "$(cat "$SUBDOMAIN_FILE")"
    fi
elif check_tool amass; then
    log_info "Enumerando subdomínios com amass..."
    SUBDOMAIN_FILE="${REPORT_DIR}/subdomains.txt"
    amass enum -passive -d "$DOMAIN" -o "$SUBDOMAIN_FILE" 2>/dev/null || true
fi


# ============================================================================
#              RELATÓRIO FINAL - LINGUAGEM HUMANA
# ============================================================================

log_section "RESUMO EXECUTIVO E RECOMENDAÇÕES"

VULN_COUNT=$(grep -c "\[VULNERABILIDADE\]" "$REPORT_FILE" 2>/dev/null || echo "0")
WARN_COUNT=$(grep -c "\[ALERTA\]" "$REPORT_FILE" 2>/dev/null || echo "0")
OK_COUNT=$(grep -c "\[OK\]" "$REPORT_FILE" 2>/dev/null || echo "0")

cat > "$SUMMARY_FILE" << SUMEOF
╔══════════════════════════════════════════════════════════════════╗
║               RESUMO EXECUTIVO DA AUDITORIA                     ║
║               Prof. Daniel Santos — Uso Acadêmico               ║
╠══════════════════════════════════════════════════════════════════╣
║  Data:       $(date '+%Y-%m-%d %H:%M:%S')
║  Alvo Local: $LOCAL_IP
║  Alvo Web:   $PUBLIC_URL
║  Finalidade: Material didático — Segurança da Informação
╚══════════════════════════════════════════════════════════════════╝

  AVISO: Este relatório é conteúdo de responsabilidade do
  Prof. Daniel Santos, destinado exclusivamente a fins acadêmicos
  e instrucionais. O uso indevido é de responsabilidade do usuário.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  FERRAMENTAS UTILIZADAS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Nmap          — Varredura de portas, detecção de serviços/OS, scripts NSE
  Hydra         — Teste de credenciais padrão (brute-force controlado)
  enum4linux    — Enumeração SMB/NetBIOS
  arp-scan      — Descoberta de hosts na rede local
  sslscan       — Análise de certificados e cifras SSL/TLS
  testssl.sh    — Teste abrangente de configuração TLS
  openssl       — Verificação de certificado e validade
  Nikto         — Scanner de vulnerabilidades web
  gobuster/dirb — Enumeração de diretórios e arquivos ocultos
  wafw00f       — Detecção de Web Application Firewall
  sublist3r     — Enumeração de subdomínios
  dig/whois     — Reconhecimento DNS e informações de registro
  curl          — Análise de headers HTTP de segurança

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  CONTAGEM DE ACHADOS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Vulnerabilidades críticas:  $VULN_COUNT
  Alertas/Avisos:             $WARN_COUNT
  Itens OK:                   $OK_COUNT

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  VULNERABILIDADES ENCONTRADAS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

SUMEOF

grep "\[VULNERABILIDADE\]" "$REPORT_FILE" >> "$SUMMARY_FILE" 2>/dev/null || \
    echo "  Nenhuma vulnerabilidade crítica detectada." >> "$SUMMARY_FILE"

cat >> "$SUMMARY_FILE" << 'SUMEOF'

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ALERTAS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

SUMEOF

grep "\[ALERTA\]" "$REPORT_FILE" >> "$SUMMARY_FILE" 2>/dev/null || \
    echo "  Nenhum alerta." >> "$SUMMARY_FILE"

cat >> "$SUMMARY_FILE" << 'SUMEOF'

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  RECOMENDAÇÕES DE CORREÇÃO
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  REDE LOCAL:
  ───────────
  1. Feche portas desnecessárias com firewall (iptables/ufw/Windows Firewall).
  2. Atualize todos os serviços para versões mais recentes.
  3. Altere TODAS as senhas padrão. Use chaves SSH em vez de senhas.
  4. Se SMB não é necessário, desative. Se é, exija autenticação e aplique MS17-010.
  5. RDP: acesse via VPN, nunca exponha direto. Habilite NLA. Aplique BlueKeep patch.
  6. Bancos de dados: bind em 127.0.0.1, acesse via túnel SSH.

  SITE WEB:
  ─────────
  7. Desabilite SSLv2, SSLv3, TLS 1.0/1.1. Use apenas TLS 1.2+ com AES-GCM.
  8. Adicione headers de segurança:
     - Strict-Transport-Security: max-age=31536000; includeSubDomains
     - Content-Security-Policy: default-src 'self'
     - X-Content-Type-Options: nosniff
     - X-Frame-Options: DENY
     - Referrer-Policy: strict-origin-when-cross-origin
     - Permissions-Policy: camera=(), microphone=(), geolocation=()
  9. Remova headers Server e X-Powered-By.
  10. Bloqueie acesso a /admin, /.git, /.env, /backup, /phpmyadmin.
  11. Implemente WAF (ModSecurity, Cloudflare, AWS WAF).
  12. Configure SPF, DKIM e DMARC no DNS.

  CENÁRIOS DE COMPROMETIMENTO:
  ────────────────────────────
  - SSH + senha fraca = acesso root completo
  - SMB sem patch = ransomware (WannaCry, NotPetya)
  - RDP exposto = brute-force -> controle total
  - Banco exposto = roubo/destruição de dados
  - SSL fraco = man-in-the-middle -> roubo de credenciais
  - Headers ausentes = XSS -> roubo de sessão -> contas comprometidas
  - .git exposto = código-fonte vazado -> mais falhas descobertas
  - Sem WAF = ataques automatizados passam livremente

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  CLASSIFICAÇÃO DE RISCO
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  CRÍTICO — Exploração trivial, impacto total (banco exposto, credencial padrão, CVE)
  ALTO    — Exploração viável com ferramentas públicas (RDP, cifras fracas)
  MÉDIO   — Requer condições específicas (headers ausentes, TLS 1.0)
  BAIXO   — Informacional (WHOIS exposto, servidor identificado)

SUMEOF

cat >> "$SUMMARY_FILE" << SUMEOF

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ARQUIVOS GERADOS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
$(ls -la "$REPORT_DIR"/ 2>/dev/null)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  NOTA LEGAL
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Conteúdo de responsabilidade do Prof. Daniel Santos.
  Uso exclusivamente acadêmico e instrucional.
  Testes não autorizados são crime (Lei 12.737/2012).
  Gerado em: $(date '+%Y-%m-%d %H:%M:%S') | Diretório: $REPORT_DIR
SUMEOF

# Exibir resumo na tela
echo ""
echo -e "${BOLD}${GREEN}"
echo "  ╔══════════════════════════════════════════════════╗"
echo "  ║       AUDITORIA CONCLUÍDA COM SUCESSO            ║"
echo "  ╚══════════════════════════════════════════════════╝"
echo -e "${NC}"
echo -e "  ${RED}Vulnerabilidades: $VULN_COUNT${NC}"
echo -e "  ${YELLOW}Alertas: $WARN_COUNT${NC}"
echo -e "  ${GREEN}OK: $OK_COUNT${NC}"
echo ""
echo -e "  ${BOLD}Arquivos em:${NC} $REPORT_DIR/"
echo -e "    relatorio_final.txt  — Relatório técnico completo"
echo -e "    resumo_executivo.txt — Resumo com recomendações"
echo ""
echo -e "  ${YELLOW}Leia o resumo:${NC} cat $SUMMARY_FILE"
echo ""
echo -e "  ${DIM}Prof. Daniel Santos — Material Acadêmico${NC}"
echo ""