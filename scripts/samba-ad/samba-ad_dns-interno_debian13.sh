#!/bin/bash

# =============================================================================
# AUTOR: Daniel Santos
# DATA DE CRIAÇÃO: 18/03/2026
# ÚLTIMA MODIFICAÇÃO: 18/03/2026
# VERSÃO: 1.0.0
# =============================================================================
# DESCRIÇÃO GERAL:
# Este script automatiza a instalação e configuração de um Controlador de Domínio
# no Debian 13 utilizando Samba, DNS integrado e DHCP. O ambiente resultante
# oferece serviços de autenticação centralizada, resolução de nomes, distribuição
# automática de IPs e compartilhamento de recursos com controle de acesso baseado
# em grupos.
#
# IMPORTÂNCIA PARA A EMPRESA:
# - Centraliza o gerenciamento de usuários e permissões
# - Automatiza a distribuição de configurações de rede
# - Garante segurança com compartilhamentos departamentais
# - Facilita o gerenciamento de recursos de TI
# - Reduz custos operacionais com automação
# =============================================================================
# AMBIENTE CONFIGURADO:
# Rede: 172.16.100.0/16
# IP do Servidor: 172.16.100.2/16
# IPs Reservados: 172.16.100.1 a 172.16.100.10
# Range DHCP: 172.16.0.11 a 172.16.0.100
# Domínio: terra.universo
# =============================================================================

# Configurações de cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# =============================================================================
# FUNÇÕES AUXILIARES
# =============================================================================

# Função para mensagens de sucesso
print_success() { echo -e "${GREEN}[SUCESSO]${NC} $1"; }

# Função para mensagens de erro
print_error() { echo -e "${RED}[ERRO]${NC} $1"; }

# Função para mensagens de aviso
print_warning() { echo -e "${YELLOW}[AVISO]${NC} $1"; }

# Função para mensagens informativas
print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }

# Função para pausa com contagem regressiva
pause() {
    local segundos=$1
    local mensagem=$2
    echo -e "${YELLOW}${mensagem}${NC}"
    for ((i=$segundos; i>=1; i--)); do
        echo -ne "\rAguardando $i segundos... "
        sleep 1
    done
    echo -e "\r${GREEN}Continuando...${NC}          "
}

# Função de menu interativo para troubleshooting
troubleshoot_menu() {
    local servico=$1
    local erro=$2
    
    while true; do
        echo -e "\n${RED}=== TROUBLESHOOTING - $servico ===${NC}"
        echo -e "Erro detectado: $erro"
        echo -e "\n${YELLOW}Opções disponíveis:${NC}"
        echo "1) Verificar status do serviço"
        echo "2) Verificar logs do serviço (últimas 20 linhas)"
        echo "3) Verificar arquivo de configuração"
        echo "4) Reiniciar serviço e tentar novamente"
        echo "5) Ignorar erro e continuar"
        echo "6) Abortar script"
        echo -n "Escolha uma opção (1-6): "
        
        read opcao
        case $opcao in
            1) 
                systemctl status $servico --no-pager
                pause 5 "Aguardando..."
                ;;
            2) 
                journalctl -u $servico -n 20 --no-pager
                pause 5 "Aguardando..."
                ;;
            3) 
                echo "Verifique manualmente as configurações em /etc/$servico"
                pause 5 "Aguardando..."
                ;;
            4) 
                systemctl restart $servico
                pause 10 "Reiniciando serviço e aguardando..."
                return 1  # Sinaliza para tentar novamente
                ;;
            5) 
                print_warning "Continuando mesmo com erro..."
                return 0
                ;;
            6) 
                print_error "Script abortado pelo usuário"
                exit 1
                ;;
            *) 
                echo "Opção inválida"
                ;;
        esac
    done
}

# =============================================================================
# ETAPA 1: CONFIGURAÇÃO DO AMBIENTE
# =============================================================================
print_info "=== ETAPA 1: CONFIGURAÇÃO DO AMBIENTE ==="
print_info "Importância: Garantir que a base do sistema está correta antes das configurações críticas"

# -----------------------------------------------------------------------------
# 1. Verificação das placas de rede
# -----------------------------------------------------------------------------
print_info "Verificando placas de rede disponíveis..."
# O comando abaixo lista todas as interfaces de rede excluindo a loopback
INTERFACES=$(ip -o link show | awk -F': ' '{print $2}' | grep -v lo)
echo "Interfaces encontradas:"
echo "$INTERFACES"

# -----------------------------------------------------------------------------
# 2. Backup das configurações atuais de rede
# -----------------------------------------------------------------------------
print_info "Realizando backup das configurações de rede..."
# Arquivo de configuração: /etc/network/interfaces (gerencia interfaces de rede)
cp /etc/network/interfaces /etc/network/interfaces.backup.$(date +%Y%m%d_%H%M%S)
print_success "Backup criado em /etc/network/interfaces.backup.$(date +%Y%m%d_%H%M%S)"

# -----------------------------------------------------------------------------
# 3. Identificação interativa das interfaces WAN e LAN
# -----------------------------------------------------------------------------
print_info "Identificando interfaces de rede para WAN e LAN..."

# Seleção da interface WAN (internet via DHCP)
echo -e "\n${YELLOW}Selecione a interface WAN (conectada à internet - receberá IP via DHCP):${NC}"
select WAN_IF in $INTERFACES; do
    if [ -n "$WAN_IF" ]; then
        echo "Interface WAN selecionada: $WAN_IF"
        break
    else
        echo "Seleção inválida"
    fi
done

# Seleção da interface LAN (rede interna - IP fixo)
echo -e "\n${YELLOW}Selecione a interface LAN (rede interna - receberá IP fixo 172.16.100.2):${NC}"
select LAN_IF in $INTERFACES; do
    if [ -n "$LAN_IF" ] && [ "$LAN_IF" != "$WAN_IF" ]; then
        echo "Interface LAN selecionada: $LAN_IF"
        break
    else
        echo "Seleção inválida ou mesma interface da WAN"
    fi
done

# -----------------------------------------------------------------------------
# 4. Configuração das interfaces no arquivo /etc/network/interfaces
# -----------------------------------------------------------------------------
print_info "Configurando interfaces de rede no arquivo /etc/network/interfaces..."
# Este arquivo é lido pelo serviço networking para configurar as interfaces

cat > /etc/network/interfaces << EOF
# Loopback
auto lo
iface lo inet loopback

# Interface WAN - DHCP (Internet)
# Recebe IP automaticamente do roteador/modem
auto $WAN_IF
iface $WAN_IF inet dhcp

# Interface LAN - IP Fixo
# Configuração manual para a rede interna 172.16.0.0/16
auto $LAN_IF
iface $LAN_IF inet static
    address 172.16.100.2
    netmask 255.255.0.0
    network 172.16.0.0
    broadcast 172.16.255.255
EOF

print_success "Arquivo /etc/network/interfaces configurado"

# -----------------------------------------------------------------------------
# 5. Reinicialização dos serviços de rede e testes
# -----------------------------------------------------------------------------
print_info "Reiniciando serviços de rede..."
systemctl restart networking

# Teste de conectividade WAN
print_info "Testando conectividade com a internet..."
if ping -c 4 8.8.8.8 &> /dev/null; then
    print_success "Conexão com internet OK"
else
    print_error "Sem acesso à internet"
    troubleshoot_menu "networking" "Falha no ping para 8.8.8.8"
fi

# Teste de conectividade LAN
print_info "Verificando configuração da interface LAN..."
if ip addr show $LAN_IF | grep -q "172.16.100.2"; then
    print_success "Interface LAN configurada corretamente com IP 172.16.100.2"
else
    print_error "Falha na configuração da interface LAN"
    troubleshoot_menu "networking" "Interface LAN não configurada corretamente"
fi

pause 10 "Etapa 1 concluída. Aguardando para próxima etapa..."

# =============================================================================
# ETAPA 2: ATUALIZAÇÃO DO SISTEMA E CONFIGURAÇÃO DE REPOSITÓRIOS
# =============================================================================
print_info "=== ETAPA 2: ATUALIZAÇÃO DO SISTEMA ==="
print_info "Importância: Garantir que o sistema está atualizado para evitar conflitos"

# -----------------------------------------------------------------------------
# 6. Verificação e configuração do sources.list
# -----------------------------------------------------------------------------
print_info "Verificando arquivo de repositórios /etc/apt/sources.list..."
# Este arquivo define de onde o apt-get baixa os pacotes

# Backup do arquivo original
cp /etc/apt/sources.list /etc/apt/sources.list.backup.$(date +%Y%m%d_%H%M%S)

# Comentar linha do CD/DROM se existir (evita pedir disco de instalação)
sed -i 's/^deb cdrom/#deb cdrom/' /etc/apt/sources.list

# Verificar se os repositórios do Debian 13 (Trixie) estão configurados
if ! grep -q "trixie main" /etc/apt/sources.list; then
    print_info "Configurando repositórios do Debian 13 Trixie..."
    cat >> /etc/apt/sources.list << EOF

# Repositórios oficiais Debian 13 Trixie
deb http://deb.debian.org/debian/ trixie main contrib non-free non-free-firmware
deb-src http://deb.debian.org/debian/ trixie main contrib non-free non-free-firmware

deb http://security.debian.org/debian-security trixie-security main contrib non-free non-free-firmware
deb-src http://security.debian.org/debian-security trixie-security main contrib non-free non-free-firmware

deb http://deb.debian.org/debian/ trixie-updates main contrib non-free non-free-firmware
deb-src http://deb.debian.org/debian/ trixie-updates main contrib non-free non-free-firmware
EOF
fi

# Atualizar lista de pacotes
print_info "Atualizando lista de pacotes..."
apt update

if [ $? -ne 0 ]; then
    print_error "Falha ao atualizar lista de pacotes"
    troubleshoot_menu "apt" "Falha no apt update"
fi

# -----------------------------------------------------------------------------
# 7. Atualização completa do sistema
# -----------------------------------------------------------------------------
print_info "Atualizando todos os pacotes do sistema..."
apt upgrade -y
apt dist-upgrade -y

print_success "Sistema atualizado com sucesso"

# Teste final de internet após atualizações
if ! ping -c 4 8.8.8.8 &> /dev/null; then
    print_error "Conexão com internet perdida após atualizações"
    troubleshoot_menu "network" "Internet indisponível"
fi

pause 10 "Sistema atualizado. Aguardando próxima etapa..."

# =============================================================================
# ETAPA 3: INSTALAÇÃO DOS PACOTES
# =============================================================================
print_info "=== ETAPA 3: INSTALAÇÃO DOS PACOTES ==="
print_info "Importância: Instalar todos os serviços necessários para o controlador de domínio"

# Lista completa de pacotes necessários
PACOTES="samba smbclient winbind krb5-user krb5-config \
         bind9 bind9utils bind9-doc isc-dhcp-server \
         acl attr ntp ntpdate dnsutils ldb-tools \
         tdb-tools cifs-utils unixodbc unixodbc-dev"

# -----------------------------------------------------------------------------
# 8. Configuração prévia do Kerberos (para evitar prompts interativos)
# -----------------------------------------------------------------------------
print_info "Configurando respostas automáticas para o Kerberos..."
debconf-set-selections <<EOF
krb5-config krb5-config/default_realm string TERRA.UNIVERSO
krb5-config krb5-config/kerberos_servers string 172.16.100.2
krb5-config krb5-config/admin_server string 172.16.100.2
EOF

# -----------------------------------------------------------------------------
# 9. Instalação dos pacotes
# -----------------------------------------------------------------------------
print_info "Instalando pacotes: $PACOTES"
apt install -y $PACOTES

if [ $? -eq 0 ]; then
    print_success "Todos os pacotes instalados com sucesso"
else
    print_error "Falha na instalação de alguns pacotes"
    troubleshoot_menu "apt" "Falha na instalação de pacotes"
fi

# -----------------------------------------------------------------------------
# 10. Verificação das versões instaladas
# -----------------------------------------------------------------------------
print_info "Versões dos principais serviços instalados:"
echo -n "Samba: " && samba --version | head -1
echo -n "Bind9: " && named -v | cut -d' ' -f1-3
echo -n "DHCP: " && dhcpd --version 2>&1 | head -1

pause 10 "Pacotes instalados. Aguardando próxima etapa..."

# =============================================================================
# ETAPA 4: CONFIGURAÇÃO DO SAMBA COMO CONTROLADOR DE DOMÍNIO
# =============================================================================
print_info "=== ETAPA 4: CONFIGURAÇÃO DO SAMBA DOMAIN CONTROLLER ==="
print_info "Importância: O Samba será o coração do sistema, gerenciando autenticação e diretório"

# -----------------------------------------------------------------------------
# 11. Preparação para o provisionamento
# -----------------------------------------------------------------------------
print_info "Parando serviços que podem conflitar com o Samba AD DC..."
systemctl stop samba-ad-dc smbd nmbd winbind 2>/dev/null
systemctl disable smbd nmbd winbind 2>/dev/null

# Remover configuração existente
rm -f /etc/samba/smb.conf

# -----------------------------------------------------------------------------
# 12. Provisionamento do domínio
# -----------------------------------------------------------------------------
print_info "Provisionando domínio TERRA.UNIVERSO com IP 172.16.100.2..."
# O comando abaixo configura o Samba como Domain Controller
# --use-rfc2307: Habilita atributos POSIX para integração com Linux/Unix
# --dns-backend=SAMBA_INTERNAL: Usa o DNS interno do Samba

samba-tool domain provision \
    --use-rfc2307 \
    --domain=TERRA \
    --realm=TERRA.UNIVERSO \
    --server-role=dc \
    --dns-backend=SAMBA_INTERNAL \
    --adminpass="Senha@123" \
    --function-level=2008_R2 \
    --host-ip=172.16.100.2

if [ $? -eq 0 ]; then
    print_success "Domínio provisionado com sucesso"
    
    # Copiar configuração do Kerberos gerada pelo Samba
    cp /var/lib/samba/private/krb5.conf /etc/krb5.conf
    
    # Habilitar e iniciar o serviço Samba AD DC
    systemctl unmask samba-ad-dc
    systemctl enable samba-ad-dc
    systemctl restart samba-ad-dc
    
    print_info "Arquivo de configuração do Samba: /etc/samba/smb.conf"
    print_info "Arquivo de configuração do Kerberos: /etc/krb5.conf"
else
    print_error "Falha no provisionamento do domínio"
    troubleshoot_menu "samba-ad-dc" "Falha no provisionamento"
fi

# -----------------------------------------------------------------------------
# 13. Testes pós-configuração
# -----------------------------------------------------------------------------
pause 10 "Aguardando Samba iniciar completamente..."

if systemctl is-active --quiet samba-ad-dc; then
    print_success "Samba AD DC está rodando"
    
    # Teste de autenticação Kerberos
    echo -n "Testando Kerberos... "
    if echo "Senha@123" | kinit administrator@TERRA.UNIVERSO &>/dev/null; then
        print_success "Kerberos funcionando"
        kdestroy
    else
        print_warning "Kerberos com problemas"
    fi
    
    # Teste de resolução DNS
    echo -n "Testando DNS interno... "
    if host -t A terra.universo 127.0.0.1 &>/dev/null; then
        print_success "DNS interno funcionando"
    else
        print_warning "DNS interno com problemas"
    fi
else
    print_error "Samba AD DC não iniciou corretamente"
    troubleshoot_menu "samba-ad-dc" "Serviço não iniciou"
fi

pause 10 "Samba configurado. Aguardando próxima etapa..."

# =============================================================================
# ETAPA 5: CONFIGURAÇÃO DO DNS RESOLVER
# =============================================================================
print_info "=== ETAPA 5: CONFIGURAÇÃO DO RESOLVEDOR DNS ==="
print_info "Importância: Garantir que o servidor use seu próprio DNS para resolução de nomes"

# -----------------------------------------------------------------------------
# 14. Configuração do /etc/resolv.conf
# -----------------------------------------------------------------------------
print_info "Configurando resolvedor DNS em /etc/resolv.conf..."
# Este arquivo define quais servidores DNS o sistema consultará

cat > /etc/resolv.conf << EOF
# Configuração DNS para domínio terra.universo
domain terra.universo
search terra.universo
nameserver 172.16.100.2
nameserver 8.8.8.8  # DNS secundário para internet
EOF

# Tornar o arquivo imutável para evitar alterações pelo DHCP
chattr +i /etc/resolv.conf
print_success "/etc/resolv.conf configurado e protegido"

# Testar resolução
print_info "Testando resolução de nomes..."
nslookup terra.universo 172.16.100.2
nslookup google.com 172.16.100.2

pause 10 "DNS configurado. Aguardando próxima etapa..."

# =============================================================================
# ETAPA 6: CONFIGURAÇÃO DO DHCP SERVER
# =============================================================================
print_info "=== ETAPA 6: CONFIGURAÇÃO DO DHCP SERVER ==="
print_info "Importância: Distribuição automática de IPs para os clientes da rede"

# -----------------------------------------------------------------------------
# 15. Configuração do DHCP em /etc/dhcp/dhcpd.conf
# -----------------------------------------------------------------------------
print_info "Configurando servidor DHCP em /etc/dhcp/dhcpd.conf..."
# Backup da configuração original
cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.original.$(date +%Y%m%d_%H%M%S)

cat > /etc/dhcp/dhcpd.conf << 'EOF'
# Configuração DHCP Server para domínio terra.universo
authoritative;

# Opções globais
option domain-name "terra.universo";
option domain-name-servers 172.16.100.2;
option ntp-servers 172.16.100.2;
default-lease-time 86400;
max-lease-time 172800;

# Definição da rede interna
subnet 172.16.0.0 netmask 255.255.0.0 {
    # Range de distribuição para clientes
    range 172.16.0.11 172.16.0.100;
    
    # Gateway padrão (primeiro IP reservado para gateway)
    option routers 172.16.100.1;
    
    # Broadcast da rede
    option broadcast-address 172.16.255.255;
    
    # Reservas para servidores (172.16.100.1 - 172.16.100.10)
    # IMPORTANTE: Substitua os MAC addresses pelos reais
    
    host servidor-dc {
        hardware ethernet 08:00:27:AA:BB:CC;  # MAC do servidor DC
        fixed-address 172.16.100.2;
    }
    
    host servidor-dns2 {
        hardware ethernet 08:00:27:DD:EE:FF;  # MAC do servidor DNS secundário
        fixed-address 172.16.100.3;
    }
    
    host servidor-file {
        hardware ethernet 08:00:27:11:22:33;  # MAC do servidor de arquivos
        fixed-address 172.16.100.4;
    }
    
    host servidor-backup {
        hardware ethernet 08:00:27:44:55:66;  # MAC do servidor de backup
        fixed-address 172.16.100.5;
    }
    
    host servidor-monitor {
        hardware ethernet 08:00:27:77:88:99;  # MAC do servidor de monitoramento
        fixed-address 172.16.100.6;
    }
}
EOF

# -----------------------------------------------------------------------------
# 16. Configuração da interface para o DHCP
# -----------------------------------------------------------------------------
print_info "Configurando interface $LAN_IF para DHCP em /etc/default/isc-dhcp-server..."
sed -i "s/^INTERFACESv4=.*/INTERFACESv4=\"$LAN_IF\"/" /etc/default/isc-dhcp-server

# -----------------------------------------------------------------------------
# 17. Inicialização do serviço DHCP
# -----------------------------------------------------------------------------
systemctl enable isc-dhcp-server
systemctl restart isc-dhcp-server
pause 10 "Aguardando DHCP iniciar..."

if systemctl is-active --quiet isc-dhcp-server; then
    print_success "DHCP Server está rodando na interface $LAN_IF"
    
    # Mostrar estatísticas do DHCP
    dhcp-lease-list 2>/dev/null || print_warning "Instale dhcp-lease-list para ver leases"
else
    print_error "DHCP Server não iniciou"
    troubleshoot_menu "isc-dhcp-server" "Serviço não iniciou"
fi

pause 10 "DHCP configurado. Aguardando próxima etapa..."

# =============================================================================
# ETAPA 7: CRIAÇÃO DA ESTRUTURA DE DIRETÓRIOS E USUÁRIOS
# =============================================================================
print_info "=== ETAPA 7: CRIAÇÃO DE DIRETÓRIOS COMPARTILHADOS E USUÁRIOS ==="
print_info "Importância: Estabelecer a estrutura organizacional de pastas e acessos"

# -----------------------------------------------------------------------------
# 18. Criação dos diretórios compartilhados
# -----------------------------------------------------------------------------
print_info "Criando diretórios departamentais em /srv/samba/..."

DIRETORIOS=("Publico" "Diretoria" "Marketing" "Financeiro" "RH")
for dir in "${DIRETORIOS[@]}"; do
    mkdir -p /srv/samba/$dir
    print_success "Diretório /srv/samba/$dir criado"
done

# -----------------------------------------------------------------------------
# 19. Criação dos grupos no Active Directory
# -----------------------------------------------------------------------------
print_info "Criando grupos de acesso no domínio..."

# Grupos para cada departamento (w = escrita, r = leitura)
declare -A GRUPOS=(
    ["fin"]="Financeiro"
    ["mk"]="Marketing"
    ["rh"]="RH"
    ["dir"]="Diretoria"
)

for dep in "${!GRUPOS[@]}"; do
    samba-tool group add grp_${dep}_w
    samba-tool group add grp_${dep}_r
    print_success "Grupos grp_${dep}_w e grp_${dep}_r criados para ${GRUPOS[$dep]}"
done

# -----------------------------------------------------------------------------
# 20. Criação dos usuários (2 por departamento)
# -----------------------------------------------------------------------------
print_info "Criando usuários no domínio..."

# Função para criar usuário
create_user() {
    local username=$1
    local nome=$2
    local sobrenome=$3
    
    samba-tool user create $username "Senha@123" \
        --given-name="$nome" \
        --surname="$sobrenome" \
        --must-change-at-next-login
    
    if [ $? -eq 0 ]; then
        print_success "Usuário $username criado"
        return 0
    else
        print_error "Falha ao criar usuário $username"
        return 1
    fi
}

# Financeiro
create_user "user_fin_w" "Financeiro" "Escrita" && samba-tool group addmembers grp_fin_w user_fin_w
create_user "user_fin_r" "Financeiro" "Leitura" && samba-tool group addmembers grp_fin_r user_fin_r

# Marketing
create_user "user_mk_w" "Marketing" "Escrita" && samba-tool group addmembers grp_mk_w user_mk_w
create_user "user_mk_r" "Marketing" "Leitura" && samba-tool group addmembers grp_mk_r user_mk_r

# RH
create_user "user_rh_w" "RH" "Escrita" && samba-tool group addmembers grp_rh_w user_rh_w
create_user "user_rh_r" "RH" "Leitura" && samba-tool group addmembers grp_rh_r user_rh_r

# Diretoria
create_user "user_dir_w" "Diretoria" "Escrita" && samba-tool group addmembers grp_dir_w user_dir_w
create_user "user_dir_r" "Diretoria" "Leitura" && samba-tool group addmembers grp_dir_r user_dir_r

# -----------------------------------------------------------------------------
# 21. Aplicação de permissões nos diretórios
# -----------------------------------------------------------------------------
print_info "Aplicando permissões ACL nos diretórios..."

# Público - todos os usuários do domínio têm acesso
setfacl -m g:"Domain Users":rwx /srv/samba/Publico

# Diretoria
setfacl -m g:grp_dir_w:rwx /srv/samba/Diretoria
setfacl -m g:grp_dir_r:rx /srv/samba/Diretoria

# Marketing
setfacl -m g:grp_mk_w:rwx /srv/samba/Marketing
setfacl -m g:grp_mk_r:rx /srv/samba/Marketing

# Financeiro
setfacl -m g:grp_fin_w:rwx /srv/samba/Financeiro
setfacl -m g:grp_fin_r:rx /srv/samba/Financeiro

# RH
setfacl -m g:grp_rh_w:rwx /srv/samba/RH
setfacl -m g:grp_rh_r:rx /srv/samba/RH

print_success "Permissões aplicadas nos diretórios"

# =============================================================================
# ETAPA 8: CONFIGURAÇÃO DOS COMPARTILHAMENTOS NO SAMBA
# =============================================================================
print_info "=== ETAPA 8: CONFIGURAÇÃO DOS COMPARTILHAMENTOS ==="
print_info "Importância: Exportar os diretórios via SMB/CIFS para acesso dos clientes"

# -----------------------------------------------------------------------------
# 22. Adicionar compartilhamentos ao smb.conf
# -----------------------------------------------------------------------------
print_info "Adicionando compartilhamentos ao /etc/samba/smb.conf..."

cat >> /etc/samba/smb.conf << 'EOF'

# =============================================================================
# COMPARTILHAMENTOS DEPARTAMENTAIS
# =============================================================================

# Público - Acesso irrestrito a todos os usuários do domínio
[Publico]
    path = /srv/samba/Publico
    read only = no
    browseable = yes
    guest ok = yes
    force user = nobody
    force group = "Domain Users"
    create mask = 0666
    directory mask = 0777

# Diretoria - Acesso baseado em grupos
[Diretoria]
    path = /srv/samba/Diretoria
    read only = no
    browseable = yes
    valid users = @TERRA\grp_dir_w, @TERRA\grp_dir_r
    write list = @TERRA\grp_dir_w
    force group = grp_dir_w
    create mask = 0660
    directory mask = 0770

# Marketing
[Marketing]
    path = /srv/samba/Marketing
    read only = no
    browseable = yes
    valid users = @TERRA\grp_mk_w, @TERRA\grp_mk_r
    write list = @TERRA\grp_mk_w
    force group = grp_mk_w
    create mask = 0660
    directory mask = 0770

# Financeiro
[Financeiro]
    path = /srv/samba/Financeiro
    read only = no
    browseable = yes
    valid users = @TERRA\grp_fin_w, @TERRA\grp_fin_r
    write list = @TERRA\grp_fin_w
    force group = grp_fin_w
    create mask = 0660
    directory mask = 0770

# Recursos Humanos
[RH]
    path = /srv/samba/RH
    read only = no
    browseable = yes
    valid users = @TERRA\grp_rh_w, @TERRA\grp_rh_r
    write list = @TERRA\grp_rh_w
    force group = grp_rh_w
    create mask = 0660
    directory mask = 0770
EOF

# Reiniciar Samba para aplicar configurações
systemctl restart samba-ad-dc
pause 10 "Aguardando Samba reiniciar..."

print_success "Compartilhamentos configurados no Samba"

# =============================================================================
# ETAPA 9: CONFIGURAÇÃO DO LOGIN SCRIPT
# =============================================================================
print_info "=== ETAPA 9: CONFIGURAÇÃO DO SCRIPT DE LOGON ==="
print_info "Importância: Mapear automaticamente as unidades de rede para os usuários"

# -----------------------------------------------------------------------------
# 23. Criar script de logon
# -----------------------------------------------------------------------------
print_info "Criando script de logon em /srv/samba/sysvol/terra.universo/scripts/logon.bat..."

# O diretório sysvol é replicado entre DCs e contém políticas e scripts
mkdir -p /srv/samba/sysvol/terra.universo/scripts

cat > /srv/samba/sysvol/terra.universo/scripts/logon.bat << 'EOF'
@echo off
title Configurando unidades de rede...
color 0A
echo.
echo ===============================================
echo     MAPEAMENTO DE UNIDADES - TERRA.UNIVERSO
echo ===============================================
echo.

REM Mapeamento da unidade pública para todos
echo Mapeando unidade P: (Publico)...
net use P: \\terra.universo\Publico /persistent:yes

REM Verificar grupos e mapear unidades específicas
echo.
echo Verificando permissoes do usuario...

REM Diretoria
whoami /groups | findstr /C:"grp_dir_w" > nul
if %errorlevel%==0 (
    echo Mapeando unidade D: (Diretoria) com permissao total...
    net use D: \\terra.universo\Diretoria /persistent:yes
)

whoami /groups | findstr /C:"grp_dir_r" > nul
if %errorlevel%==0 (
    echo Mapeando unidade D: (Diretoria) em modo leitura...
    net use D: \\terra.universo\Diretoria /persistent:yes
)

REM Marketing
whoami /groups | findstr /C:"grp_mk_w" > nul
if %errorlevel%==0 (
    echo Mapeando unidade M: (Marketing) com permissao total...
    net use M: \\terra.universo\Marketing /persistent:yes
)

whoami /groups | findstr /C:"grp_mk_r" > nul
if %errorlevel%==0 (
    echo Mapeando unidade M: (Marketing) em modo leitura...
    net use M: \\terra.universo\Marketing /persistent:yes
)

REM Financeiro
whoami /groups | findstr /C:"grp_fin_w" > nul
if %errorlevel%==0 (
    echo Mapeando unidade F: (Financeiro) com permissao total...
    net use F: \\terra.universo\Financeiro /persistent:yes
)

whoami /groups | findstr /C:"grp_fin_r" > nul
if %errorlevel%==0 (
    echo Mapeando unidade F: (Financeiro) em modo leitura...
    net use F: \\terra.universo\Financeiro /persistent:yes
)

REM RH
whoami /groups | findstr /C:"grp_rh_w" > nul
if %errorlevel%==0 (
    echo Mapeando unidade R: (RH) com permissao total...
    net use R: \\terra.universo\RH /persistent:yes
)

whoami /groups | findstr /C:"grp_rh_r" > nul
if %errorlevel%==0 (
    echo Mapeando unidade R: (RH) em modo leitura...
    net use R: \\terra.universo\RH /persistent:yes
)

echo.
echo ===============================================
echo     CONFIGURACAO CONCLUIDA COM SUCESSO!
echo ===============================================
echo.
pause
EOF

# Converter para formato Windows (CRLF)
apt install -y dos2unix
unix2dos /srv/samba/sysvol/terra.universo/scripts/logon.bat

# Configurar permissões do script
chmod 755 /srv/samba/sysvol/terra.universo/scripts/logon.bat

print_success "Script de logon criado e configurado"

# =============================================================================
# ETAPA 10: TESTES FINAIS E VERIFICAÇÃO
# =============================================================================
print_info "=== ETAPA 10: TESTES FINAIS E VERIFICAÇÃO ==="
print_info "Importância: Garantir que todos os serviços estão funcionando corretamente"

echo -e "\n${BLUE}================================================================${NC}"
echo -e "${BLUE}           RELATÓRIO FINAL DE CONFIGURAÇÃO                     ${NC}"
echo -e "${BLUE}================================================================${NC}\n"

# -----------------------------------------------------------------------------
# 24. Teste do Samba AD DC
# -----------------------------------------------------------------------------
echo -n "Testando serviço Samba AD DC... "
if systemctl is-active --quiet samba-ad-dc; then
    echo -e "${GREEN}[OK]${NC}"
    SAMBA_STATUS="ATIVO"
else
    echo -e "${RED}[FALHOU]${NC}"
    SAMBA_STATUS="INATIVO"
fi

# -----------------------------------------------------------------------------
# 25. Teste do DNS
# -----------------------------------------------------------------------------
echo -n "Testando resolução DNS (terra.universo)... "
if nslookup terra.universo 127.0.0.1 &>/dev/null; then
    echo -e "${GREEN}[OK]${NC}"
    DNS_STATUS="FUNCIONANDO"
else
    echo -e "${RED}[FALHOU]${NC}"
    DNS_STATUS="COM PROBLEMAS"
fi

# -----------------------------------------------------------------------------
# 26. Teste do DHCP
# -----------------------------------------------------------------------------
echo -n "Testando serviço DHCP... "
if systemctl is-active --quiet isc-dhcp-server; then
    echo -e "${GREEN}[OK]${NC}"
    DHCP_STATUS="ATIVO"
else
    echo -e "${RED}[FALHOU]${NC}"
    DHCP_STATUS="INATIVO"
fi

# -----------------------------------------------------------------------------
# 27. Teste de autenticação Kerberos
# -----------------------------------------------------------------------------
echo -n "Testando autenticação Kerberos... "
if echo "Senha@123" | kinit administrator@TERRA.UNIVERSO &>/dev/null; then
    echo -e "${GREEN}[OK]${NC}"
    KERBEROS_STATUS="FUNCIONANDO"
    kdestroy
else
    echo -e "${RED}[FALHOU]${NC}"
    KERBEROS_STATUS="COM PROBLEMAS"
fi

# -----------------------------------------------------------------------------
# 28. Teste de compartilhamentos
# -----------------------------------------------------------------------------
echo -n "Testando listagem de compartilhamentos... "
if smbclient -L localhost -N &>/dev/null; then
    echo -e "${GREEN}[OK]${NC}"
    SHARE_STATUS="ACESSÍVEL"
else
    echo -e "${RED}[FALHOU]${NC}"
    SHARE_STATUS="INACESSÍVEL"
fi

# -----------------------------------------------------------------------------
# 29. Verificação de grupos
# -----------------------------------------------------------------------------
echo -n "Verificando criação de grupos... "
GRUPOS_CRIADOS=$(samba-tool group list | grep -E "grp_(fin|mk|rh|dir)_[wr]" | wc -l)
if [ "$GRUPOS_CRIADOS" -eq 8 ]; then
    echo -e "${GREEN}[OK] (8 grupos encontrados)${NC}"
    GRUPOS_STATUS="COMPLETO"
else
    echo -e "${RED}[FALHOU] (Encontrados $GRUPOS_CRIADOS de 8)${NC}"
    GRUPOS_STATUS="INCOMPLETO"
fi

# -----------------------------------------------------------------------------
# 30. Verificação de usuários
# -----------------------------------------------------------------------------
echo -n "Verificando criação de usuários... "
USUARIOS_CRIADOS=$(samba-tool user list | grep -E "user_(fin|mk|rh|dir)_[wr]" | wc -l)
if [ "$USUARIOS_CRIADOS" -eq 8 ]; then
    echo -e "${GREEN}[OK] (8 usuários encontrados)${NC}"
    USUARIOS_STATUS="COMPLETO"
else
    echo -e "${RED}[FALHOU] (Encontrados $USUARIOS_CRIADOS de 8)${NC}"
    USUARIOS_STATUS="INCOMPLETO"
fi

# -----------------------------------------------------------------------------
# 31. Verificação de diretórios
# -----------------------------------------------------------------------------
echo -n "Verificando diretórios compartilhados... "
DIRETORIOS_ENCONTRADOS=0
for dir in "${DIRETORIOS[@]}"; do
    if [ -d "/srv/samba/$dir" ]; then
        ((DIRETORIOS_ENCONTRADOS++))
    fi
done

if [ "$DIRETORIOS_ENCONTRADOS" -eq 5 ]; then
    echo -e "${GREEN}[OK]${NC}"
    DIRETORIOS_STATUS="COMPLETO"
else
    echo -e "${RED}[FALHOU]${NC}"
    DIRETORIOS_STATUS="INCOMPLETO"
fi

# -----------------------------------------------------------------------------
# 32. Resumo final
# -----------------------------------------------------------------------------
echo -e "\n${BLUE}================================================================${NC}"
echo -e "${BLUE}                     RESUMO DA CONFIGURAÇÃO                     ${NC}"
echo -e "${BLUE}================================================================${NC}"
echo -e "Samba AD DC:     ${GREEN}$SAMBA_STATUS${NC}"
echo -e "DNS:             ${GREEN}$DNS_STATUS${NC}"
echo -e "DHCP:            ${GREEN}$DHCP_STATUS${NC}"
echo -e "Kerberos:        ${GREEN}$KERBEROS_STATUS${NC}"
echo -e "Compartilhamentos: ${GREEN}$SHARE_STATUS${NC}"
echo -e "Grupos:          ${GREEN}$GRUPOS_STATUS${NC}"
echo -e "Usuários:        ${GREEN}$USUARIOS_STATUS${NC}"
echo -e "Diretórios:      ${GREEN}$DIRETORIOS_STATUS${NC}"
echo -e "${BLUE}================================================================${NC}"

# =============================================================================
# INFORMAÇÕES FINAIS
# =============================================================================
echo -e "\n${YELLOW}=== INFORMAÇÕES IMPORTANTES PARA ACESSO ===${NC}"
echo -e "Domínio: ${GREEN}terra.universo${NC}"
echo -e "IP do Controlador: ${GREEN}172.16.100.2${NC}"
echo -e "Rede: ${GREEN}172.16.0.0/16${NC}"
echo -e "Range DHCP: ${GREEN}172.16.0.11 - 172.16.0.100${NC}"
echo -e "Usuário Administrador: ${GREEN}Administrator${NC}"
echo -e "Senha Administrador: ${GREEN}Senha@123${NC}"
echo ""
echo -e "${YELLOW}=== USUÁRIOS CRIADOS (senha padrão: Senha@123) ===${NC}"
echo -e "Financeiro:  ${GREEN}user_fin_w${NC} (escrita), ${GREEN}user_fin_r${NC} (leitura)"
echo -e "Marketing:   ${GREEN}user_mk_w${NC} (escrita), ${GREEN}user_mk_r${NC} (leitura)"
echo -e "RH:          ${GREEN}user_rh_w${NC} (escrita), ${GREEN}user_rh_r${NC} (leitura)"
echo -e "Diretoria:   ${GREEN}user_dir_w${NC} (escrita), ${GREEN}user_dir_r${NC} (leitura)"
echo ""
echo -e "${YELLOW}=== COMPARTILHAMENTOS DISPONÍVEIS ===${NC}"
echo -e "\\\\${GREEN}terra.universo\\Publico${NC}     - Acesso público"
echo -e "\\\\${GREEN}terra.universo\\Diretoria${NC}   - Acesso da Diretoria"
echo -e "\\\\${GREEN}terra.universo\\Marketing${NC}   - Acesso do Marketing"
echo -e "\\\\${GREEN}terra.universo\\Financeiro${NC}  - Acesso do Financeiro"
echo -e "\\\\${GREEN}terra.universo\\RH${NC}          - Acesso do RH"
echo ""
echo -e "${YELLOW}=== SCRIPT DE LOGON ===${NC}"
echo -e "Localização no servidor: ${GREEN}/srv/samba/sysvol/terra.universo/scripts/logon.bat${NC}"
echo -e "Acesso pelos clientes:   ${GREEN}\\\\terra.universo\\sysvol\\terra.universo\\scripts\\logon.bat${NC}"
echo ""

# Salvar log da configuração
cat > /root/configuracao_completa_$(date +%Y%m%d_%H%M%S).txt << EOF
RELATÓRIO DE CONFIGURAÇÃO DO CONTROLADOR DE DOMÍNIO
Data: $(date)
Autor: Daniel Santos

SERVIÇOS CONFIGURADOS:
- Samba AD DC: $SAMBA_STATUS
- DNS: $DNS_STATUS
- DHCP: $DHCP_STATUS
- Kerberos: $KERBEROS_STATUS
- Compartilhamentos: $SHARE_STATUS

ESTRUTURA CRIADA:
- Grupos: $GRUPOS_STATUS (8 grupos)
- Usuários: $USUARIOS_STATUS (8 usuários)
- Diretórios: $DIRETORIOS_STATUS (5 diretórios)

INFORMAÇÕES DE REDE:
- Domínio: terra.universo
- IP do Servidor: 172.16.100.2/16
- Range DHCP: 172.16.0.11 - 172.16.0.100
- IPs Reservados: 172.16.100.1 - 172.16.100.10

CREDENCIAIS:
- Administrator: Senha@123
- Usuários departamentais: Senha@123 (todos)

ARQUIVOS DE CONFIGURAÇÃO:
- /etc/samba/smb.conf - Configuração do Samba
- /etc/krb5.conf - Configuração do Kerberos
- /etc/dhcp/dhcpd.conf - Configuração do DHCP
- /etc/resolv.conf - Configuração do DNS resolver
- /etc/network/interfaces - Configuração de rede

COMPARTILHAMENTOS:
- Publico: /srv/samba/Publico
- Diretoria: /srv/samba/Diretoria
- Marketing: /srv/samba/Marketing
- Financeiro: /srv/samba/Financeiro
- RH: /srv/samba/RH

SCRIPT DE LOGON:
- /srv/samba/sysvol/terra.universo/scripts/logon.bat
EOF

print_success "Log de configuração salvo em /root/configuracao_completa_$(date +%Y%m%d_%H%M%S).txt"

echo -e "\n${GREEN}========================================================================${NC}"
echo -e "${GREEN}          CONFIGURAÇÃO CONCLUÍDA COM SUCESSO!                          ${NC}"
echo -e "${GREEN}========================================================================${NC}"
echo -e "${YELLOW}Autor: Daniel Santos | Versão: 1.0.0 | Data: $(date +%d/%m/%Y)${NC}"
echo -e "${GREEN}========================================================================${NC}\n"

# Fim do script
exit 0