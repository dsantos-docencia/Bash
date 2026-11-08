#!/bin/bash
# -----------------------------------------------------------------------------
# Script de Instalação e Configuração de Controlador de Domínio Samba AD
# com DNS BIND9_DLZ, DHCP Server, OUs, usuários, grupos, diretórios,
# permissões e script de logon para mapeamento automático.
# -----------------------------------------------------------------------------
# Autor: Daniel Santos / danielsantos@grupoiconne.net
# Versão: 1.0
# Data: 2026-04-02
# Sistema-alvo: Debian 13 "trixie"
# Base de referência: Debian 13 estável (13.4 em 14/03/2026), lançado
# inicialmente em 09/08/2025, conforme documentação oficial do Debian.
# Homologação pretendida: laboratório em VirtualBox com duas NICs
# (WAN/NAT + LAN interna).
# -----------------------------------------------------------------------------
# OBJETIVO
# Este script prepara um servidor Debian 13 para atuar como:
#   - Controlador de Domínio Samba AD
#   - DNS com backend BIND9_DLZ
#   - Servidor DHCP
#   - Servidor de arquivos com permissões por setor
#   - Estrutura inicial de OUs, grupos e usuários
#   - Script de login para mapeamento automático de unidades de rede
# -----------------------------------------------------------------------------
# IMPORTANTE
# 1. Este script foi desenhado para LABORATÓRIO e estudo.
# 2. Execute em instalação limpa do Debian 13.
# 3. O script faz alterações estruturais de rede, Kerberos, Samba, BIND e DHCP.
# 4. Sempre valide em VM antes de qualquer adaptação para produção.
# -----------------------------------------------------------------------------

set -u
export DEBIAN_FRONTEND=noninteractive
umask 027

# ===============================
# CORES E ESTILO DE SAÍDA
# ===============================
VERMELHO='\033[0;31m'
VERDE='\033[0;32m'
AMARELO='\033[1;33m'
AZUL='\033[0;34m'
ROXO='\033[0;35m'
CIANO='\033[0;36m'
NC='\033[0m'

# =========================================================
# VALIDAÇÃO E CORREÇÃO DE PERMISSÃO SUDO (DEBIAN 13)
# =========================================================

echo -e "\n${AZUL}Verificando permissões administrativas (sudo)...${NC}"

USUARIO_ATUAL=$(whoami)

# Se já for root, apenas informa
if [ "$USUARIO_ATUAL" = "root" ]; then
    echo -e "${VERDE}✔ Script está sendo executado como root.${NC}"
else
    echo -e "${AMARELO}Usuário atual: $USUARIO_ATUAL${NC}"

    # Garantir que o grupo sudo existe antes de qualquer teste
    if ! getent group sudo >/dev/null 2>&1; then
        echo -e "${AMARELO}Grupo sudo não encontrado. Criando...${NC}"
        su - -c "groupadd sudo"
    fi

    # Verifica se usuário está no grupo sudo
    if groups "$USUARIO_ATUAL" | grep -qw sudo; then
        echo -e "${VERDE}✔ Usuário já pertence ao grupo sudo.${NC}"
    else
        echo -e "${AMARELO}⚠ Usuário NÃO está no grupo sudo. Corrigindo...${NC}"

        # Tentar adicionar ao grupo sudo
        su - -c "usermod -aG sudo $USUARIO_ATUAL"

        if [ $? -eq 0 ]; then
            echo -e "${VERDE}✔ Usuário adicionado ao grupo sudo com sucesso.${NC}"
        else
            echo -e "${VERMELHO}ERRO: Falha ao adicionar usuário ao grupo sudo.${NC}"
            echo -e "${VERMELHO}Execute manualmente como root:${NC}"
            echo -e "usermod -aG sudo $USUARIO_ATUAL"
            exit 1
        fi
    fi

    # Garantir regra no sudoers com validação
    if ! su - -c "grep -q '^%sudo' /etc/sudoers"; then
        echo -e "${AMARELO}Corrigindo arquivo /etc/sudoers...${NC}"
        if ! su - -c "echo '%sudo ALL=(ALL:ALL) ALL' >> /etc/sudoers && visudo -cf /etc/sudoers"; then
            echo -e "${VERMELHO}ERRO: Falha ao validar /etc/sudoers.${NC}"
            exit 1
        fi
    fi

    # Teste sudo
    echo -e "${AZUL}Testando sudo...${NC}"
    if sudo -n true 2>/dev/null; then
        echo -e "${VERDE}✔ Sudo já funcional.${NC}"
    else
        echo -e "${AMARELO}⚠ Sessão atual ainda não reconhece as permissões sudo.${NC}"
        echo -e "${AMARELO}Faça logout/login novamente, ou entre com 'su - $USUARIO_ATUAL', e depois execute o script outra vez.${NC}"
        sleep 5
        exit 0
    fi
fi

sleep 5

# ===============================
# VARIÁVEIS GERAIS DO AMBIENTE
# ===============================
SCRIPT_NOME="debian13_samba_bind9_dlz_dhcp_v1.sh"
SCRIPT_VERSAO="1.0"
LOG_DIR="/var/log/samba-ad-setup"
LOG_FILE="$LOG_DIR/execucao.log"

# Rede informada pelo usuário
REDE="192.168.25.0/24"
REDE_BASE="192.168.25.0"
MASCARA="255.255.255.0"
CIDR="24"
FAIXA_FIXA_INICIO="192.168.25.1"
FAIXA_FIXA_FIM="192.168.25.10"
IP_SERVIDOR="192.168.25.2"
GATEWAY="192.168.25.1"
DNS_FORWARDER="8.8.8.8"
DNS_ALTERNATIVO="1.1.1.1"

# Identidade do servidor e domínio
HOSTNAME_DC="srv02"
DOMINIO_DNS="empresa.local"
DOMINIO_NETBIOS="EMPRESA"
REALM="EMPRESA.LOCAL"
ADMIN_SAMBA="administrator"

# DHCP
DHCP_RANGE_START="192.168.25.100"
DHCP_RANGE_END="192.168.25.200"
DHCP_BROADCAST="192.168.25.255"
LEASE_DEFAULT="600"
LEASE_MAX="7200"

# Timezone
TIMEZONE="America/Sao_Paulo"

# Estrutura de diretórios
BASE_SHARE="/srv/compartilhado"
DIR_FINANCEIRO="$BASE_SHARE/Financeiro"
DIR_RH="$BASE_SHARE/RH"
DIR_DIRETORIA="$BASE_SHARE/Diretoria"
DIR_COMERCIAL="$BASE_SHARE/Comercial"
DIR_PUBLICO="$BASE_SHARE/Publico"
DIR_COMUM="$BASE_SHARE/Comum"

# OUs
OU_BASE="OU=Empresa"
OU_USUARIOS="OU=Usuarios,$OU_BASE"
OU_GRUPOS="OU=Grupos,$OU_BASE"
OU_COMPUTADORES="OU=Computadores,$OU_BASE"
OU_FINANCEIRO="OU=Financeiro,$OU_USUARIOS"
OU_RH="OU=RH,$OU_USUARIOS"
OU_DIRETORIA="OU=Diretoria,$OU_USUARIOS"
OU_COMERCIAL="OU=Comercial,$OU_USUARIOS"
OU_PUBLICO="OU=Publico,$OU_USUARIOS"

# Grupos
GRP_FINANCEIRO_RW="GG_Financeiro_Gerentes"
GRP_FINANCEIRO_RO="GG_Financeiro_Assistentes"
GRP_RH_RW="GG_RH_Gerentes"
GRP_RH_RO="GG_RH_Assistentes"
GRP_DIRETORIA_RW="GG_Diretoria_Gerentes"
GRP_DIRETORIA_RO="GG_Diretoria_Assistentes"
GRP_COMERCIAL_RW="GG_Comercial_Gerentes"
GRP_COMERCIAL_RO="GG_Comercial_Assistentes"
GRP_PUBLICO_RW="GG_Publico_Gerentes"
GRP_PUBLICO_RO="GG_Publico_Assistentes"
GRP_TODOS="GG_Todos_Colaboradores"
GRP_DIRETORES_GLOBAIS="GG_Diretores_Acesso_Global"

# Usuários de exemplo
USR_FIN_GER="fin_ger01"
USR_FIN_AST="fin_ast01"
USR_RH_GER="rh_ger01"
USR_RH_AST="rh_ast01"
USR_DIR_GER="dir_ger01"
USR_DIR_AST="dir_ast01"
USR_COM_GER="com_ger01"
USR_COM_AST="com_ast01"
USR_PUB_GER="pub_ger01"
USR_PUB_AST="pub_ast01"

# Senhas iniciais dos usuários de exemplo (lab)
PWD_PADRAO="Troque@123"
PWD_DIR_GER="Diretoria@123"

# Interfaces (serão detectadas)
WAN_IF=""
LAN_IF=""

# Serviços esperados
SERVICOS=(chrony networking bind9 samba-ad-dc isc-dhcp-server)

# Pacotes
PACOTES=(
  acl attr dnsutils bind9 bind9utils krb5-user krb5-config samba smbclient
  winbind libnss-winbind libpam-winbind smbldap-tools chrony isc-dhcp-server
  policycoreutils python3-ldb python3-samba rsync sed grep gawk net-tools iproute2
)

# ===============================
# FUNÇÕES UTILITÁRIAS
# ===============================
log() {
  mkdir -p "$LOG_DIR"
  echo "[$(date '+%F %T')] $*" >> "$LOG_FILE"
}

msg() {
  echo -e "$*"
  log "$(echo -e "$*" | sed 's/\x1b\[[0-9;]*m//g')"
}

pause_msg() {
  local titulo="$1"
  local corpo="$2"
  clear
  msg "${AZUL}================================================================${NC}"
  msg "${ROXO}${titulo}${NC}"
  msg "${AZUL}================================================================${NC}"
  msg "${AMARELO}${corpo}${NC}"
  msg "${VERDE}Aguardando 15 segundos para leitura...${NC}"
  sleep 15
}

status_msg() {
  local texto="$1"
  msg "${CIANO}${texto}${NC}"
  sleep 15
}

run_cmd() {
  local descricao="$1"
  shift
  msg "${AZUL}>> ${descricao}${NC}"
  if "$@" >> "$LOG_FILE" 2>&1; then
    msg "${VERDE}OK:${NC} ${descricao}"
    return 0
  fi
  msg "${VERMELHO}FALHA:${NC} ${descricao}"
  return 1
}

run_retry() {
  local descricao="$1"
  shift
  local tentativa=1
  local max=3
  while [ $tentativa -le $max ]; do
    msg "${AZUL}>> ${descricao} (tentativa ${tentativa}/${max})${NC}"
    if "$@" >> "$LOG_FILE" 2>&1; then
      msg "${VERDE}OK:${NC} ${descricao}"
      return 0
    fi
    msg "${AMARELO}Aviso:${NC} tentativa ${tentativa} falhou em: ${descricao}"
    tentativa=$((tentativa + 1))
    sleep 5
  done
  msg "${VERMELHO}ERRO:${NC} não foi possível concluir: ${descricao}"
  return 1
}

restart_service_safely() {
  local srv="$1"
  systemctl stop "$srv" >> "$LOG_FILE" 2>&1 || true
  sleep 5
  systemctl start "$srv" >> "$LOG_FILE" 2>&1 || true
  sleep 10
}

test_service() {
  local srv="$1"
  if systemctl is-active --quiet "$srv"; then
    msg "${VERDE}Serviço ativo:${NC} $srv"
    return 0
  fi
  msg "${AMARELO}Serviço não está ativo:${NC} $srv. Tentando corrigir..."
  systemctl daemon-reload >> "$LOG_FILE" 2>&1 || true
  restart_service_safely "$srv"
  if systemctl is-active --quiet "$srv"; then
    msg "${VERDE}Serviço recuperado:${NC} $srv"
    return 0
  fi
  msg "${VERMELHO}Falha persistente no serviço:${NC} $srv"
  return 1
}

confirmar_prosseguimento() {
  msg "${AMARELO}Digite SIM para continuar com a transformação deste Debian em servidor:${NC}"
  read -r CONFIRMA_FINAL
  if [ "$CONFIRMA_FINAL" != "SIM" ]; then
    msg "${VERMELHO}Operação cancelada pelo usuário.${NC}"
    exit 1
  fi
}

prompt_senha_segura() {
  msg "${AMARELO}Informe a senha do usuário com privilégio sudo.${NC}"
  read -r -s SENHA_SUDO
  echo
  if ! echo "$SENHA_SUDO" | sudo -S true >> "$LOG_FILE" 2>&1; then
    msg "${VERMELHO}Senha sudo inválida.${NC}"
    exit 1
  fi
  msg "${VERDE}Credencial sudo validada com sucesso.${NC}"

  msg "${AMARELO}Informe a senha do administrador do domínio Samba (ex.: Administrator).${NC}"
  read -r -s SENHA_ADMIN_SAMBA
  echo
  if [ ${#SENHA_ADMIN_SAMBA} -lt 8 ]; then
    msg "${VERMELHO}A senha do administrador Samba deve ter ao menos 8 caracteres.${NC}"
    exit 1
  fi
}

sudo_run() {
  echo "$SENHA_SUDO" | sudo -S "$@" >> "$LOG_FILE" 2>&1
}

ensure_root_context() {
  if [ "$EUID" -eq 0 ]; then
    msg "${VERDE}Script executado como root.${NC}"
  else
    msg "${AMARELO}Script executado como usuário comum com sudo autorizado.${NC}"
  fi
}

# ===============================
# ROTINAS DE REDE
# ===============================
detectar_interfaces() {
  pause_msg "ETAPA PRELIMINAR - ANÁLISE DE INTERFACES DE REDE" \
"Nesta etapa o script identifica as placas de rede, verifica se existem pelo menos duas NICs, tenta inferir qual interface possui internet e qual será a rede interna do laboratório VirtualBox."

  mapfile -t IFACES < <(ip -o link show | awk -F': ' '{print $2}' | grep -v '^lo$')
  local qtd=${#IFACES[@]}

  msg "${AZUL}Interfaces detectadas:${NC}"
  ip -br addr show | tee -a "$LOG_FILE"

  if [ "$qtd" -lt 2 ]; then
    msg "${VERMELHO}Foram detectadas menos de 2 interfaces. O laboratório espera pelo menos 2 NICs.${NC}"
    exit 1
  fi

  for iface in "${IFACES[@]}"; do
    ip link set "$iface" up >> "$LOG_FILE" 2>&1 || true
  done

  WAN_IF=$(ip route | awk '/default/ {print $5; exit}')
  if [ -z "$WAN_IF" ]; then
    msg "${AMARELO}Não foi possível inferir automaticamente a interface WAN via rota padrão.${NC}"
    msg "${AMARELO}Informe manualmente a interface WAN (NAT/Internet):${NC}"
    read -r WAN_IF
  fi

  for iface in "${IFACES[@]}"; do
    if [ "$iface" != "$WAN_IF" ]; then
      LAN_IF="$iface"
      break
    fi
  done

  msg "${VERDE}WAN sugerida:${NC} $WAN_IF"
  msg "${VERDE}LAN sugerida:${NC} $LAN_IF"
  msg "${AMARELO}Confirme a interface WAN [${WAN_IF}] ou digite outra:${NC}"
  read -r WAN_TMP
  [ -n "$WAN_TMP" ] && WAN_IF="$WAN_TMP"
  msg "${AMARELO}Confirme a interface LAN [${LAN_IF}] ou digite outra:${NC}"
  read -r LAN_TMP
  [ -n "$LAN_TMP" ] && LAN_IF="$LAN_TMP"

  status_msg "Interfaces definidas: WAN=${WAN_IF} | LAN=${LAN_IF}"
}

exibir_estado_rede() {
  pause_msg "ETAPA PRELIMINAR - ESTADO ATUAL DA REDE" \
"Aqui o script mostra IPs, status das placas, rota padrão e resolução DNS atual para permitir revisão antes da configuração automática."
  ip -br addr show | tee -a "$LOG_FILE"
  echo | tee -a "$LOG_FILE"
  ip route show | tee -a "$LOG_FILE"
  echo | tee -a "$LOG_FILE"
  cat /etc/resolv.conf | tee -a "$LOG_FILE" || true
  status_msg "Resumo de rede exibido."
}

configurar_rede_interfaces() {
  pause_msg "ETAPA 1 - CONFIGURAÇÃO BASE DE REDE" \
"Nesta etapa o script corrige repositórios, prepara o sistema para uso sem interação, ajusta a interface LAN com IP fixo do controlador de domínio e mantém a interface WAN apta a acessar a internet para baixar pacotes."

  mkdir -p /etc/network/interfaces.d

  cat > /etc/network/interfaces <<EOF_INTERFACES
# Arquivo gerado por $SCRIPT_NOME
source /etc/network/interfaces.d/*

auto lo
iface lo inet loopback

auto $WAN_IF
allow-hotplug $WAN_IF
iface $WAN_IF inet dhcp

auto $LAN_IF
allow-hotplug $LAN_IF
iface $LAN_IF inet static
    address $IP_SERVIDOR/$CIDR
    gateway $GATEWAY
    dns-nameservers 127.0.0.1 $DNS_FORWARDER $DNS_ALTERNATIVO
EOF_INTERFACES

  systemctl restart networking >> "$LOG_FILE" 2>&1 || ifdown "$LAN_IF" && ifup "$LAN_IF" >> "$LOG_FILE" 2>&1 || true
  sleep 10

  ip -4 addr show "$LAN_IF" | tee -a "$LOG_FILE"
  ip route show | tee -a "$LOG_FILE"
}

validar_rede_antes_instalacao() {
  pause_msg "ETAPA 2 - VALIDAÇÃO DE CONECTIVIDADE" \
"Antes de atualizar o Debian, o script valida IP, gateway, internet e DNS. Se algum item falhar, ele tenta corrigir de forma automática em até 3 tentativas."

  run_retry "Teste de IP na LAN" ip -4 addr show "$LAN_IF"

  if ! ip route | grep -q '^default '; then
    msg "${AMARELO}Rota padrão ausente. Tentando adicionar gateway padrão via $WAN_IF...${NC}"
    ip route add default via "$GATEWAY" dev "$WAN_IF" >> "$LOG_FILE" 2>&1 || true
  fi

  run_retry "Ping ao gateway informado" ping -c 2 "$GATEWAY"
  run_retry "Teste de conectividade externa 8.8.8.8" ping -c 2 8.8.8.8
  run_retry "Teste de resolução DNS para deb.debian.org" getent ahostsv4 deb.debian.org
  status_msg "Validação de rede concluída."
}

corrigir_sources_list() {
  pause_msg "ETAPA 3 - CORREÇÃO DE REPOSITÓRIOS" \
"Esta etapa remove entradas problemáticas de dvd-rom no sources.list e ajusta os repositórios para Debian 13 estável. Isso evita erros comuns de atualização em VMs recém-instaladas."

  sed -i '/^deb cdrom:/d' /etc/apt/sources.list || true
  cat > /etc/apt/sources.list <<EOF_SOURCES
# Repositórios oficiais Debian 13 trixie

deb http://deb.debian.org/debian trixie main contrib non-free non-free-firmware
deb http://security.debian.org/debian-security trixie-security main contrib non-free non-free-firmware
deb http://deb.debian.org/debian trixie-updates main contrib non-free non-free-firmware
EOF_SOURCES

  grep -v '^#' /etc/apt/sources.list | tee -a "$LOG_FILE"
  status_msg "Repositórios ajustados."
}

atualizar_sistema_inicial() {
  pause_msg "ETAPA 4 - ATUALIZAÇÃO INICIAL DO SISTEMA" \
"Agora o script atualiza índices de pacotes e aplica upgrades iniciais para garantir base limpa antes da instalação de Samba, BIND9, Kerberos e DHCP."

  run_retry "apt update" apt update
  run_retry "apt full-upgrade -y" apt full-upgrade -y
  run_retry "apt autoremove -y" apt autoremove -y
  status_msg "Atualização inicial concluída."
}

checklist_geral_pre_prosseguimento() {
  pause_msg "CHECKLIST GERAL ANTES DA CONFIGURAÇÃO DO SERVIDOR" \
"Aqui o script mostra um resumo do estado atual: hostname, interfaces, IP, rota, DNS, repositórios e data/hora. Em seguida, você confirma conscientemente que deseja prosseguir."

  echo "Hostname atual: $(hostname)" | tee -a "$LOG_FILE"
  echo "Data/hora atual: $(date)" | tee -a "$LOG_FILE"
  echo "WAN: $WAN_IF" | tee -a "$LOG_FILE"
  echo "LAN: $LAN_IF" | tee -a "$LOG_FILE"
  echo "IP do servidor desejado: $IP_SERVIDOR/$CIDR" | tee -a "$LOG_FILE"
  echo "Gateway previsto: $GATEWAY" | tee -a "$LOG_FILE"
  echo "Domínio DNS: $DOMINIO_DNS" | tee -a "$LOG_FILE"
  echo "NetBIOS: $DOMINIO_NETBIOS" | tee -a "$LOG_FILE"
  echo "Realm: $REALM" | tee -a "$LOG_FILE"
  echo "Timezone previsto: $TIMEZONE" | tee -a "$LOG_FILE"
  echo | tee -a "$LOG_FILE"
  ip -br addr show | tee -a "$LOG_FILE"
  echo | tee -a "$LOG_FILE"
  ip route show | tee -a "$LOG_FILE"
  echo | tee -a "$LOG_FILE"
  cat /etc/resolv.conf | tee -a "$LOG_FILE"
  echo | tee -a "$LOG_FILE"
  confirmalabel="A partir daqui o Debian será transformado em servidor Samba AD + BIND9_DLZ + DHCP."
  msg "${AMARELO}${confirmalabel}${NC}"
  confirmar_prosseguimento
}

instalar_pacotes() {
  pause_msg "ETAPA 5 - INSTALAÇÃO DOS PACOTES NECESSÁRIOS" \
"Esta etapa instala Samba, Bind9, Kerberos, DHCP, utilitários de DNS, bibliotecas de integração e ferramentas auxiliares."

  debconf-set-selections <<EOF_KRB
krb5-config krb5-config/default_realm string $REALM
krb5-config krb5-config/kerberos_servers string $HOSTNAME_DC.$DOMINIO_DNS
krb5-config krb5-config/admin_server string $HOSTNAME_DC.$DOMINIO_DNS
EOF_KRB

  run_retry "Instalação dos pacotes base" apt install -y "${PACOTES[@]}"
  run_retry "Correção de dependências" apt --fix-broken install -y
  run_retry "Atualização pós-instalação" apt update
  run_retry "Upgrade pós-instalação" apt full-upgrade -y

  dpkg -l samba bind9 isc-dhcp-server krb5-user chrony | tee -a "$LOG_FILE"
  status_msg "Pacotes instalados e conferidos."
}

configuracao_base_sistema() {
  pause_msg "ETAPA 6 - CONFIGURAÇÃO BASE DO SISTEMA" \
"Nesta fase o script ajusta hostname, /etc/hosts, timezone, sincronização de horário e resolução local. Isso é crítico para funcionamento de Kerberos e Samba AD."

  hostnamectl set-hostname "$HOSTNAME_DC"

  cat > /etc/hosts <<EOF_HOSTS
127.0.0.1       localhost
$IP_SERVIDOR    $HOSTNAME_DC.$DOMINIO_DNS $HOSTNAME_DC
EOF_HOSTS

  timedatectl set-timezone "$TIMEZONE"
  systemctl stop systemd-timesyncd >> "$LOG_FILE" 2>&1 || true
  apt install -y chrony >> "$LOG_FILE" 2>&1 || true
  cat > /etc/chrony/chrony.conf <<EOF_CHRONY
pool pool.ntp.org iburst
makestep 1.0 3
rtcsync
allow 192.168.25.0/24
local stratum 8
EOF_CHRONY
  restart_service_safely chrony

  date | tee -a "$LOG_FILE"
  timedatectl status | tee -a "$LOG_FILE"
  status_msg "Configuração base do sistema concluída."
}

configurar_kerberos() {
  pause_msg "ETAPA 7 - CONFIGURAÇÃO DO KERBEROS" \
"O Kerberos será configurado para autenticação centralizada do domínio. O arquivo krb5.conf será alinhado com o realm do Samba AD."

  cat > /etc/krb5.conf <<EOF_KRB5
[libdefaults]
    default_realm = $REALM
    dns_lookup_realm = false
    dns_lookup_kdc = true
    ticket_lifetime = 24h
    renew_lifetime = 7d
    forwardable = true

[realms]
    $REALM = {
        kdc = $HOSTNAME_DC.$DOMINIO_DNS
        admin_server = $HOSTNAME_DC.$DOMINIO_DNS
    }

[domain_realm]
    .$DOMINIO_DNS = $REALM
    $DOMINIO_DNS = $REALM
EOF_KRB5

  cat /etc/krb5.conf | tee -a "$LOG_FILE"
  status_msg "Kerberos configurado."
}

provisionar_samba_ad_bind9_dlz() {
  pause_msg "ETAPA 8 - PROVISIONAMENTO DO SAMBA AD COM BIND9_DLZ" \
"Agora o servidor será promovido a Controlador de Domínio. O provisionamento usará backend DNS BIND9_DLZ, alinhado ao pedido do laboratório."

  systemctl stop smbd nmbd winbind bind9 samba-ad-dc >> "$LOG_FILE" 2>&1 || true
  sleep 10

  [ -f /etc/samba/smb.conf ] && mv /etc/samba/smb.conf /etc/samba/smb.conf.pre-ad.$(date +%F-%H%M%S) || true

  if ! samba-tool domain provision \
      --use-rfc2307 \
      --realm="$REALM" \
      --domain="$DOMINIO_NETBIOS" \
      --server-role=dc \
      --dns-backend=BIND9_DLZ \
      --adminpass="$SENHA_ADMIN_SAMBA" \
      >> "$LOG_FILE" 2>&1; then
    msg "${VERMELHO}Falha no provisionamento do domínio.${NC}"
    exit 1
  fi

  cp /var/lib/samba/private/krb5.conf /etc/krb5.conf

  mkdir -p /var/lib/samba/bind-dns/dns
  chown -R root:bind /var/lib/samba/bind-dns /var/lib/samba/private || true
  chmod -R 750 /var/lib/samba/bind-dns /var/lib/samba/private || true

  cat > /etc/bind/named.conf.options <<EOF_BINDOPT
options {
    directory "/var/cache/bind";
    forwarders { $DNS_FORWARDER; $DNS_ALTERNATIVO; };
    dnssec-validation no;
    listen-on { any; };
    listen-on-v6 { none; };
    allow-query { any; };
    recursion yes;
    tkey-gssapi-keytab "/var/lib/samba/bind-dns/dns.keytab";
};
EOF_BINDOPT

  cat > /etc/bind/named.conf.local <<EOF_BINDLOCAL
include "/var/lib/samba/bind-dns/named.conf";
EOF_BINDLOCAL

  if [ -f /etc/default/bind9 ]; then
    sed -i 's/^OPTIONS=.*/OPTIONS="-u bind -4"/' /etc/default/bind9 || true
  fi

  named-checkconf >> "$LOG_FILE" 2>&1 || true
  restart_service_safely bind9
  restart_service_safely samba-ad-dc

  echo "nameserver 127.0.0.1" > /etc/resolv.conf
  echo "search $DOMINIO_DNS" >> /etc/resolv.conf

  test_service bind9
  test_service samba-ad-dc

  host -t SRV _ldap._tcp.$DOMINIO_DNS 127.0.0.1 | tee -a "$LOG_FILE"
  host -t A $HOSTNAME_DC.$DOMINIO_DNS 127.0.0.1 | tee -a "$LOG_FILE"
  kinit "$ADMIN_SAMBA@$REALM" <<EOF_KINIT >> "$LOG_FILE" 2>&1 || true
$SENHA_ADMIN_SAMBA
EOF_KINIT
  klist | tee -a "$LOG_FILE" || true
  status_msg "Provisionamento Samba AD + BIND9_DLZ concluído."
}

configurar_dhcp() {
  pause_msg "ETAPA 9 - CONFIGURAÇÃO DO DHCP SERVER" \
"Nesta etapa o ISC DHCP Server será configurado para a rede interna, entregando IP, gateway e DNS do domínio aos clientes."

  cat > /etc/default/isc-dhcp-server <<EOF_DHCP_DEFAULT
INTERFACESv4="$LAN_IF"
EOF_DHCP_DEFAULT

  cat > /etc/dhcp/dhcpd.conf <<EOF_DHCP
option domain-name "$DOMINIO_DNS";
option domain-name-servers $IP_SERVIDOR;
default-lease-time $LEASE_DEFAULT;
max-lease-time $LEASE_MAX;
authoritative;

subnet $REDE_BASE netmask $MASCARA {
  range $DHCP_RANGE_START $DHCP_RANGE_END;
  option routers $GATEWAY;
  option subnet-mask $MASCARA;
  option broadcast-address $DHCP_BROADCAST;
}
EOF_DHCP

  dhcpd -t -cf /etc/dhcp/dhcpd.conf >> "$LOG_FILE" 2>&1 || true
  restart_service_safely isc-dhcp-server
  test_service isc-dhcp-server
  systemctl status isc-dhcp-server --no-pager | tee -a "$LOG_FILE" || true
  status_msg "DHCP configurado e testado."
}

criar_ous_grupos_usuarios() {
  pause_msg "ETAPA 10 - CRIAÇÃO DE OUs, GRUPOS E USUÁRIOS" \
"Agora será criada a estrutura lógica do domínio: OUs para organização, grupos de segurança por setor e 10 usuários de exemplo."

  samba-tool ou create "$OU_BASE" >> "$LOG_FILE" 2>&1 || true
  samba-tool ou create "$OU_USUARIOS" >> "$LOG_FILE" 2>&1 || true
  samba-tool ou create "$OU_GRUPOS" >> "$LOG_FILE" 2>&1 || true
  samba-tool ou create "$OU_COMPUTADORES" >> "$LOG_FILE" 2>&1 || true
  samba-tool ou create "$OU_FINANCEIRO" >> "$LOG_FILE" 2>&1 || true
  samba-tool ou create "$OU_RH" >> "$LOG_FILE" 2>&1 || true
  samba-tool ou create "$OU_DIRETORIA" >> "$LOG_FILE" 2>&1 || true
  samba-tool ou create "$OU_COMERCIAL" >> "$LOG_FILE" 2>&1 || true
  samba-tool ou create "$OU_PUBLICO" >> "$LOG_FILE" 2>&1 || true

  for grp in \
    "$GRP_FINANCEIRO_RW" "$GRP_FINANCEIRO_RO" "$GRP_RH_RW" "$GRP_RH_RO" \
    "$GRP_DIRETORIA_RW" "$GRP_DIRETORIA_RO" "$GRP_COMERCIAL_RW" "$GRP_COMERCIAL_RO" \
    "$GRP_PUBLICO_RW" "$GRP_PUBLICO_RO" "$GRP_TODOS" "$GRP_DIRETORES_GLOBAIS"; do
    samba-tool group add "$grp" --groupou="$OU_GRUPOS" >> "$LOG_FILE" 2>&1 || true
  done

  samba-tool user create "$USR_FIN_GER" "$PWD_PADRAO" --userou="$OU_FINANCEIRO" --given-name="Financeiro" --surname="Gerente" >> "$LOG_FILE" 2>&1 || true
  samba-tool user create "$USR_FIN_AST" "$PWD_PADRAO" --userou="$OU_FINANCEIRO" --given-name="Financeiro" --surname="Assistente" >> "$LOG_FILE" 2>&1 || true
  samba-tool user create "$USR_RH_GER" "$PWD_PADRAO" --userou="$OU_RH" --given-name="RH" --surname="Gerente" >> "$LOG_FILE" 2>&1 || true
  samba-tool user create "$USR_RH_AST" "$PWD_PADRAO" --userou="$OU_RH" --given-name="RH" --surname="Assistente" >> "$LOG_FILE" 2>&1 || true
  samba-tool user create "$USR_DIR_GER" "$PWD_DIR_GER" --userou="$OU_DIRETORIA" --given-name="Diretoria" --surname="Gerente" >> "$LOG_FILE" 2>&1 || true
  samba-tool user create "$USR_DIR_AST" "$PWD_PADRAO" --userou="$OU_DIRETORIA" --given-name="Diretoria" --surname="Assistente" >> "$LOG_FILE" 2>&1 || true
  samba-tool user create "$USR_COM_GER" "$PWD_PADRAO" --userou="$OU_COMERCIAL" --given-name="Comercial" --surname="Gerente" >> "$LOG_FILE" 2>&1 || true
  samba-tool user create "$USR_COM_AST" "$PWD_PADRAO" --userou="$OU_COMERCIAL" --given-name="Comercial" --surname="Assistente" >> "$LOG_FILE" 2>&1 || true
  samba-tool user create "$USR_PUB_GER" "$PWD_PADRAO" --userou="$OU_PUBLICO" --given-name="Publico" --surname="Gerente" >> "$LOG_FILE" 2>&1 || true
  samba-tool user create "$USR_PUB_AST" "$PWD_PADRAO" --userou="$OU_PUBLICO" --given-name="Publico" --surname="Assistente" >> "$LOG_FILE" 2>&1 || true

  samba-tool group addmembers "$GRP_FINANCEIRO_RW" "$USR_FIN_GER" >> "$LOG_FILE" 2>&1 || true
  samba-tool group addmembers "$GRP_FINANCEIRO_RO" "$USR_FIN_AST" >> "$LOG_FILE" 2>&1 || true
  samba-tool group addmembers "$GRP_RH_RW" "$USR_RH_GER" >> "$LOG_FILE" 2>&1 || true
  samba-tool group addmembers "$GRP_RH_RO" "$USR_RH_AST" >> "$LOG_FILE" 2>&1 || true
  samba-tool group addmembers "$GRP_DIRETORIA_RW" "$USR_DIR_GER" >> "$LOG_FILE" 2>&1 || true
  samba-tool group addmembers "$GRP_DIRETORIA_RO" "$USR_DIR_AST" >> "$LOG_FILE" 2>&1 || true
  samba-tool group addmembers "$GRP_COMERCIAL_RW" "$USR_COM_GER" >> "$LOG_FILE" 2>&1 || true
  samba-tool group addmembers "$GRP_COMERCIAL_RO" "$USR_COM_AST" >> "$LOG_FILE" 2>&1 || true
  samba-tool group addmembers "$GRP_PUBLICO_RW" "$USR_PUB_GER" >> "$LOG_FILE" 2>&1 || true
  samba-tool group addmembers "$GRP_PUBLICO_RO" "$USR_PUB_AST" >> "$LOG_FILE" 2>&1 || true
  samba-tool group addmembers "$GRP_TODOS" "$USR_FIN_GER,$USR_FIN_AST,$USR_RH_GER,$USR_RH_AST,$USR_DIR_GER,$USR_DIR_AST,$USR_COM_GER,$USR_COM_AST,$USR_PUB_GER,$USR_PUB_AST" >> "$LOG_FILE" 2>&1 || true
  samba-tool group addmembers "$GRP_DIRETORES_GLOBAIS" "$USR_DIR_GER" >> "$LOG_FILE" 2>&1 || true

  samba-tool group list | tee -a "$LOG_FILE"
  samba-tool user list | tee -a "$LOG_FILE"
  status_msg "Estrutura lógica do domínio criada."
}

configurar_compartilhamentos_permissoes() {
  pause_msg "ETAPA 11 - DIRETÓRIOS, PERMISSÕES E COMPARTILHAMENTOS" \
"Serão criados diretórios por setor, permissões de leitura ou controle total conforme a regra solicitada, e os shares serão publicados no Samba."

  mkdir -p "$DIR_FINANCEIRO" "$DIR_RH" "$DIR_DIRETORIA" "$DIR_COMERCIAL" "$DIR_PUBLICO" "$DIR_COMUM"

  chmod 2770 "$DIR_FINANCEIRO" "$DIR_RH" "$DIR_DIRETORIA" "$DIR_COMERCIAL" "$DIR_PUBLICO"
  chmod 2775 "$DIR_COMUM"

  chgrp "${DOMINIO_NETBIOS}\\domain users" "$DIR_COMUM" >> "$LOG_FILE" 2>&1 || true

  setfacl -m g:"${DOMINIO_NETBIOS}\\$GRP_FINANCEIRO_RW":rwx "$DIR_FINANCEIRO" || true
  setfacl -m g:"${DOMINIO_NETBIOS}\\$GRP_FINANCEIRO_RO":rx "$DIR_FINANCEIRO" || true
  setfacl -m g:"${DOMINIO_NETBIOS}\\$GRP_RH_RW":rwx "$DIR_RH" || true
  setfacl -m g:"${DOMINIO_NETBIOS}\\$GRP_RH_RO":rx "$DIR_RH" || true
  setfacl -m g:"${DOMINIO_NETBIOS}\\$GRP_DIRETORIA_RW":rwx "$DIR_DIRETORIA" || true
  setfacl -m g:"${DOMINIO_NETBIOS}\\$GRP_DIRETORIA_RO":rx "$DIR_DIRETORIA" || true
  setfacl -m g:"${DOMINIO_NETBIOS}\\$GRP_COMERCIAL_RW":rwx "$DIR_COMERCIAL" || true
  setfacl -m g:"${DOMINIO_NETBIOS}\\$GRP_COMERCIAL_RO":rx "$DIR_COMERCIAL" || true
  setfacl -m g:"${DOMINIO_NETBIOS}\\$GRP_PUBLICO_RW":rwx "$DIR_PUBLICO" || true
  setfacl -m g:"${DOMINIO_NETBIOS}\\$GRP_PUBLICO_RO":rx "$DIR_PUBLICO" || true

  for dir in "$DIR_FINANCEIRO" "$DIR_RH" "$DIR_DIRETORIA" "$DIR_COMERCIAL" "$DIR_PUBLICO" "$DIR_COMUM"; do
    setfacl -m g:"${DOMINIO_NETBIOS}\\$GRP_DIRETORES_GLOBAIS":rwx "$dir" || true
  done

  cp /etc/samba/smb.conf /etc/samba/smb.conf.pre-shares.$(date +%F-%H%M%S)
  cat >> /etc/samba/smb.conf <<EOF_SHARES

[Financeiro]
    path = $DIR_FINANCEIRO
    read only = no
    browseable = yes
    valid users = @"$DOMINIO_NETBIOS\\$GRP_FINANCEIRO_RW", @"$DOMINIO_NETBIOS\\$GRP_FINANCEIRO_RO", @"$DOMINIO_NETBIOS\\$GRP_DIRETORES_GLOBAIS"
    write list = @"$DOMINIO_NETBIOS\\$GRP_FINANCEIRO_RW", @"$DOMINIO_NETBIOS\\$GRP_DIRETORES_GLOBAIS"

[RH]
    path = $DIR_RH
    read only = no
    browseable = yes
    valid users = @"$DOMINIO_NETBIOS\\$GRP_RH_RW", @"$DOMINIO_NETBIOS\\$GRP_RH_RO", @"$DOMINIO_NETBIOS\\$GRP_DIRETORES_GLOBAIS"
    write list = @"$DOMINIO_NETBIOS\\$GRP_RH_RW", @"$DOMINIO_NETBIOS\\$GRP_DIRETORES_GLOBAIS"

[Diretoria]
    path = $DIR_DIRETORIA
    read only = no
    browseable = yes
    valid users = @"$DOMINIO_NETBIOS\\$GRP_DIRETORIA_RW", @"$DOMINIO_NETBIOS\\$GRP_DIRETORIA_RO", @"$DOMINIO_NETBIOS\\$GRP_DIRETORES_GLOBAIS"
    write list = @"$DOMINIO_NETBIOS\\$GRP_DIRETORIA_RW", @"$DOMINIO_NETBIOS\\$GRP_DIRETORES_GLOBAIS"

[Comercial]
    path = $DIR_COMERCIAL
    read only = no
    browseable = yes
    valid users = @"$DOMINIO_NETBIOS\\$GRP_COMERCIAL_RW", @"$DOMINIO_NETBIOS\\$GRP_COMERCIAL_RO", @"$DOMINIO_NETBIOS\\$GRP_DIRETORES_GLOBAIS"
    write list = @"$DOMINIO_NETBIOS\\$GRP_COMERCIAL_RW", @"$DOMINIO_NETBIOS\\$GRP_DIRETORES_GLOBAIS"

[Publico]
    path = $DIR_PUBLICO
    read only = no
    browseable = yes
    valid users = @"$DOMINIO_NETBIOS\\$GRP_PUBLICO_RW", @"$DOMINIO_NETBIOS\\$GRP_PUBLICO_RO", @"$DOMINIO_NETBIOS\\$GRP_DIRETORES_GLOBAIS"
    write list = @"$DOMINIO_NETBIOS\\$GRP_PUBLICO_RW", @"$DOMINIO_NETBIOS\\$GRP_DIRETORES_GLOBAIS"

[Comum]
    path = $DIR_COMUM
    read only = no
    browseable = yes
    valid users = @"$DOMINIO_NETBIOS\\Domain Users"
EOF_SHARES

  testparm -s | tee -a "$LOG_FILE" || true
  restart_service_safely samba-ad-dc
  smbclient -L localhost -U% | tee -a "$LOG_FILE" || true
  status_msg "Compartilhamentos publicados e conferidos."
}

configurar_script_logon() {
  pause_msg "ETAPA 12 - SCRIPT DE LOGON PARA MAPEAMENTO AUTOMÁTICO" \
"Será criado um script de logon no SYSVOL para mapear automaticamente as unidades de rede quando o cliente ingressar no domínio."

  mkdir -p "/var/lib/samba/sysvol/$DOMINIO_DNS/scripts"
  cat > "/var/lib/samba/sysvol/$DOMINIO_DNS/scripts/login.bat" <<EOF_LOGIN
@echo off
net use F: \\$HOSTNAME_DC\Financeiro /persistent:yes
net use R: \\$HOSTNAME_DC\RH /persistent:yes
net use D: \\$HOSTNAME_DC\Diretoria /persistent:yes
net use C: \\$HOSTNAME_DC\Comercial /persistent:yes
net use P: \\$HOSTNAME_DC\Publico /persistent:yes
net use X: \\$HOSTNAME_DC\Comum /persistent:yes
EOF_LOGIN

  chmod 755 "/var/lib/samba/sysvol/$DOMINIO_DNS/scripts/login.bat"
  cat "/var/lib/samba/sysvol/$DOMINIO_DNS/scripts/login.bat" | tee -a "$LOG_FILE"
  status_msg "Script de logon criado."
}

resumos_finais() {
  pause_msg "ETAPA 13 - RESUMOS E TESTES FINAIS" \
"Nesta etapa o script apresenta um resumo técnico dos serviços, validações finais, contas criadas, grupos, compartilhamentos e instruções resumidas para o próximo passo do laboratório."

  echo "================ RESUMO GERAL ================" | tee -a "$LOG_FILE"
  echo "Hostname..............: $HOSTNAME_DC" | tee -a "$LOG_FILE"
  echo "Domínio DNS...........: $DOMINIO_DNS" | tee -a "$LOG_FILE"
  echo "NetBIOS...............: $DOMINIO_NETBIOS" | tee -a "$LOG_FILE"
  echo "Realm.................: $REALM" | tee -a "$LOG_FILE"
  echo "IP servidor...........: $IP_SERVIDOR/$CIDR" | tee -a "$LOG_FILE"
  echo "Gateway...............: $GATEWAY" | tee -a "$LOG_FILE"
  echo "WAN...................: $WAN_IF" | tee -a "$LOG_FILE"
  echo "LAN...................: $LAN_IF" | tee -a "$LOG_FILE"
  echo "Timezone..............: $TIMEZONE" | tee -a "$LOG_FILE"
  echo | tee -a "$LOG_FILE"

  for srv in "${SERVICOS[@]}"; do
    systemctl status "$srv" --no-pager | tee -a "$LOG_FILE" || true
    echo | tee -a "$LOG_FILE"
  done

  host -t SRV _kerberos._udp.$DOMINIO_DNS 127.0.0.1 | tee -a "$LOG_FILE" || true
  host -t SRV _ldap._tcp.$DOMINIO_DNS 127.0.0.1 | tee -a "$LOG_FILE" || true
  samba-tool user list | tee -a "$LOG_FILE" || true
  samba-tool group list | tee -a "$LOG_FILE" || true
  smbclient -L localhost -U% | tee -a "$LOG_FILE" || true

  msg "${AZUL}================ LEITURA FINAL ================${NC}"
  msg "${VERDE}O resumo também foi salvo em: $LOG_FILE${NC}"
  msg "${AMARELO}Aguardando 60 segundos para leitura final...${NC}"
  sleep 60
}

# ===============================
# FLUXO PRINCIPAL
# ===============================
main() {
  clear
  mkdir -p "$LOG_DIR"
  touch "$LOG_FILE"

  pause_msg "INÍCIO DO SCRIPT" \
"Este script novo, em primeira versão, prepara um Debian 13 para atuar como Controlador de Domínio Samba AD com BIND9_DLZ, DHCP, usuários, grupos, OUs, diretórios e logon script, conforme escopo do laboratório VirtualBox informado."

  ensure_root_context
  prompt_senha_segura
  detectar_interfaces
  exibir_estado_rede
  configurar_rede_interfaces
  validar_rede_antes_instalacao
  corrigir_sources_list
  atualizar_sistema_inicial
  checklist_geral_pre_prosseguimento
  instalar_pacotes
  configuracao_base_sistema
  configurar_kerberos
  provisionar_samba_ad_bind9_dlz
  configurar_dhcp
  criar_ous_grupos_usuarios
  configurar_compartilhamentos_permissoes
  configurar_script_logon
  resumos_finais

  msg "${VERDE}Script concluído. Revise o log em $LOG_FILE${NC}"
}

main "$@"
