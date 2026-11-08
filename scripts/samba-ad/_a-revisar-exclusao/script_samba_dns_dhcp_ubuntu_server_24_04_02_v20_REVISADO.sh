#!/bin/bash
# -------------------------------------------------------------------------
# Script de Instalação e Configuração de um Controlador de Domínio com Samba
# Versão Corrigida - Para Iniciantes em Linux
# Daniel Santos / danielsantos@grupoiconne.net
# Versão: 3.1 - Maio/2025 (Corrigida)
# -------------------------------------------------------------------------

## Introdução para Iniciantes:
# Este script automatiza a criação de um controlador de domínio (Active Directory) usando Samba no Ubuntu.
# Ele é dividido em seções lógicas, cada uma com explicações detalhadas.

# Cores para facilitar a visualização
VERMELHO='\033[0;31m'
VERDE='\033[0;32m'
AMARELO='\033[1;33m'
AZUL='\033[0;34m'
NC='\033[0m' # Sem cor

# Configurações básicas - Você pode alterar esses valores
DOMINIO="TI52"
DNS_DOMINIO="ti52.aprendendo"
REINO="TI52.APRENDENDO"
IP_SERVIDOR="172.16.0.2"
MASCARA="255.255.255.0"
GATEWAY="172.16.0.1"
DNS_EXTERNO="8.8.8.8"
INTERFACE_REDE="enp0s8"

# Função para pausa e explicação
explicar() {
    echo -e "\n${AZUL}======================================================${NC}"
    echo -e "${AMARELO}$1${NC}"
    echo -e "${AZUL}======================================================${NC}"
    echo -e "${VERDE}O que será feito:${NC}"
    echo -e "$2"
    echo -e "\n${VERDE}Pressione ENTER para continuar ou aguarde 1 minuto...${NC}"
    read -t 60
}

# Função para testar resultado
testar() {
    echo -e "\n${AMARELO}Testando resultado:${NC}"
    echo -e "$1"
    eval "$1"
    echo -e "\n${VERDE}Verifique acima se o resultado está correto antes de continuar.${NC}"
    sleep 5
}

## ======================================================
## 1. ATUALIZAÇÃO DO SISTEMA
## ======================================================
explicar "ETAPA 1: ATUALIZAÇÃO DO SISTEMA" \
"Nesta etapa, vamos atualizar a lista de pacotes e todos os programas instalados.
Isso é importante para garantir que estamos usando as versões mais recentes e seguras."

# Solicitar senha sudo de forma segura
echo -e "\n${VERDE}Por favor, digite a senha do seu usuário com permissões sudo (mínimo 8 caracteres, com maiúsculas, minúsculas e números):${NC}"
read -s SENHA_SUDO

# Verificar complexidade da senha
if [[ ${#SENHA_SUDO} -lt 8 || ! "$SENHA_SUDO" =~ [A-Z] || ! "$SENHA_SUDO" =~ [a-z] || ! "$SENHA_SUDO" =~ [0-9] ]]; then
    echo -e "${VERMELHO}ERRO: A senha deve ter pelo menos 8 caracteres, incluindo maiúsculas, minúsculas e números${NC}"
    exit 1
fi

# Atualizando o sistema
echo "$SENHA_SUDO" | sudo -S apt update && sudo apt upgrade -y
sleep 10

testar "echo 'Verificando atualizações pendentes...'; apt list --upgradable -a"

## ======================================================
## 2. INSTALAÇÃO DE PACOTES NECESSÁRIOS
## ======================================================
explicar "ETAPA 2: INSTALAÇÃO DE PACOTES" \
"Aqui vamos instalar todos os programas necessários para o controlador de domínio."

# Pré-configurar o Kerberos
echo "$SENHA_SUDO" | sudo -S bash -c "cat <<EOF | debconf-set-selections
krb5-config krb5-config/default_realm string $REINO
krb5-config krb5-config/kerberos_servers string dc1.$DNS_DOMINIO
krb5-config krb5-config/admin_server string dc1.$DNS_DOMINIO
krb5-config krb5-config/add_servers_realm string $REINO
krb5-config krb5-config/add_servers boolean true
krb5-config krb5-config/read_conf boolean true
EOF"

# Instalar pacotes essenciais incluindo dnsutils
echo "$SENHA_SUDO" | sudo -S DEBIAN_FRONTEND=noninteractive apt install -y samba krb5-config winbind bind9 isc-dhcp-server acl smbclient dnsutils
sleep 10

# Adicione após a instalação dos pacotes principais
echo "$SENHA_SUDO" | sudo -S apt-get install -y --fix-broken
echo "$SENHA_SUDO" | sudo -S apt-get autoremove -y

testar "echo 'Versão do Samba instalada:'; samba --version"
testar "echo 'Status do serviço DNS:'; systemctl status bind9"

## ======================================================
## 3. CONFIGURAÇÃO BÁSICA DO SISTEMA
## ======================================================
explicar "ETAPA 3: CONFIGURAÇÃO BÁSICA" \
"Vamos configurar o nome do servidor e o arquivo hosts."

# Configurações básicas do sistema
echo "$SENHA_SUDO" | sudo -S hostnamectl set-hostname dc1
echo "$SENHA_SUDO" | sudo -S sysctl -w net.ipv6.conf.all.disable_ipv6=1
echo "$SENHA_SUDO" | sudo -S sysctl -w net.ipv6.conf.default.disable_ipv6=1

# Configurar arquivo hosts
echo "127.0.0.1 localhost" | sudo tee /etc/hosts
echo "$IP_SERVIDOR dc1.$DNS_DOMINIO dc1" | sudo tee -a /etc/hosts

# Configurar NTP
echo "$SENHA_SUDO" | sudo -S timedatectl set-ntp true
echo "$SENHA_SUDO" | sudo -S systemctl restart systemd-timesyncd
sleep 10

testar "echo 'Hostname configurado:'; hostname"
testar "echo 'Conteúdo do /etc/hosts:'; cat /etc/hosts"
testar "echo 'Status do NTP:'; timedatectl status"

## ======================================================
## 4. CONFIGURAÇÃO DO SERVIDOR DNS (BIND9)
## ======================================================
explicar "ETAPA 4: CONFIGURAÇÃO DO DNS" \
"O servidor DNS é crucial para um controlador de domínio."

# Configurar arquivo principal
cat <<EOF | sudo tee /etc/bind/named.conf.options
options {
    directory "/var/cache/bind";
    forwarders {
        $DNS_EXTERNO;
    };
    allow-query { any; };
    recursion yes;
    dnssec-validation no;
    auth-nxdomain no;
    listen-on { any; };
};
EOF

# Configurar zonas
cat <<EOF | sudo tee /etc/bind/named.conf.local
zone "$DNS_DOMINIO" {
    type master;
    file "/etc/bind/db.$DNS_DOMINIO";
};

zone "16.172.in-addr.arpa" {
    type master;
    file "/etc/bind/db.172.16";
};
EOF

# Criar arquivo de zona direta (com variáveis)
cat <<EOF | sudo tee /etc/bind/db.$DNS_DOMINIO
\$TTL    604800
@       IN      SOA     dc1.$DNS_DOMINIO. admin.$DNS_DOMINIO. (
                        3       ; Serial
                        604800  ; Refresh
                        86400   ; Retry
                        2419200 ; Expire
                        604800 ) ; Negative Cache TTL
;
@       IN      NS      dc1.$DNS_DOMINIO.
@       IN      A       $IP_SERVIDOR
dc1     IN      A       $IP_SERVIDOR
EOF

# Criar arquivo de zona reversa (com variáveis)
cat <<EOF | sudo tee /etc/bind/db.172.16
\$TTL    604800
@       IN      SOA     dc1.$DNS_DOMINIO. admin.$DNS_DOMINIO. (
                        3       ; Serial
                        604800  ; Refresh
                        86400   ; Retry
                        2419200 ; Expire
                        604800 ) ; Negative Cache TTL
;
@       IN      NS      dc1.$DNS_DOMINIO.
2.0     IN      PTR     dc1.$DNS_DOMINIO.
EOF

# Corrigir conflito de nomes de serviço
echo "$SENHA_SUDO" | sudo -S systemctl stop bind9
echo "$SENHA_SUDO" | sudo -S systemctl disable bind9

# Verificar configurações
echo "$SENHA_SUDO" | sudo -S named-checkconf
echo "$SENHA_SUDO" | sudo -S named-checkzone $DNS_DOMINIO /etc/bind/db.$DNS_DOMINIO
echo "$SENHA_SUDO" | sudo -S named-checkzone 16.172.in-addr.arpa /etc/bind/db.172.16

# Iniciar serviço com o nome correto
echo "$SENHA_SUDO" | sudo -S systemctl enable named
echo "$SENHA_SUDO" | sudo -S systemctl restart named

sleep 10
testar "echo 'Testando resolução DNS:'; dig $DNS_DOMINIO @localhost"

## ======================================================
## 5. CONFIGURAÇÃO DO KERBEROS
## ======================================================
explicar "ETAPA 5: CONFIGURAÇÃO DO KERBEROS" \
"Kerberos é um sistema de autenticação segura usado em domínios Windows."

cat <<EOF | sudo tee /etc/krb5.conf
[libdefaults]
    default_realm = $REINO
    dns_lookup_realm = false
    dns_lookup_kdc = true
    ticket_lifetime = 24h
    renew_lifetime = 7d
    forwardable = true

[realms]
    $REINO = {
        kdc = dc1.$DNS_DOMINIO
        admin_server = dc1.$DNS_DOMINIO
    }

[domain_realm]
    .$DNS_DOMINIO = $REINO
    $DNS_DOMINIO = $REINO
EOF

sleep 10
testar "echo 'Configuração do Kerberos:'; cat /etc/krb5.conf | grep -v '^#' | grep -v '^$'"

## ======================================================
## 6. CONFIGURAÇÃO DO SAMBA COMO CONTROLADOR DE DOMÍNIO - CORRIGIDA
## ======================================================
explicar "ETAPA 6: CONFIGURAÇÃO DO SAMBA" \
"Agora vamos transformar este servidor em um controlador de domínio."

# Parar serviços
echo "$SENHA_SUDO" | sudo -S systemctl stop smbd nmbd winbind
sleep 5

# Criar diretórios e corrigir permissões
echo "$SENHA_SUDO" | sudo -S mkdir -p /var/lib/samba/private
echo "$SENHA_SUDO" | sudo -S chown -R root:bind /var/lib/samba/private
echo "$SENHA_SUDO" | sudo -S chmod -R 770 /var/lib/samba/private

# Adicione esta correção ANTES do provisionamento do domínio (ETAPA 6)
echo "$SENHA_SUDO" | sudo -S mkdir -p /var/lib/samba/private
echo "$SENHA_SUDO" | sudo -S chown -R root:bind /var/lib/samba/private
echo "$SENHA_SUDO" | sudo -S chmod -R 770 /var/lib/samba/private

# Provisionar domínio
echo "$SENHA_SUDO" | sudo -S mv /etc/samba/smb.conf /etc/samba/smb.conf.bkp
if ! echo "$SENHA_SUDO" | sudo -S samba-tool domain provision --use-rfc2307 --realm=$REINO --domain=$DOMINIO --adminpass="$SENHA_SUDO" --server-role=dc; then
    echo -e "${VERMELHO}ERRO no provisionamento do domínio. Verifique os logs.${NC}"
    exit 1
fi

# Configurar DNS local
echo "nameserver $IP_SERVIDOR" | sudo tee /etc/resolv.conf
echo "search $DNS_DOMINIO" | sudo tee -a /etc/resolv.conf

# Corrigir permissões novamente após provisionamento
echo "$SENHA_SUDO" | sudo -S chown -R root:bind /var/lib/samba/private
echo "$SENHA_SUDO" | sudo -S chmod -R 770 /var/lib/samba/private

# Iniciar serviço
echo "$SENHA_SUDO" | sudo -S systemctl start samba-ad-dc
echo "$SENHA_SUDO" | sudo -S systemctl enable samba-ad-dc

sleep 10
testar "echo 'Informações do domínio'; samba-tool domain info localhost"


## ======================================================
## 7. CONFIGURAÇÃO DO DHCP - VERSÃO CORRIGIDA
## ======================================================
explicar "ETAPA 7: CONFIGURAÇÃO DO DHCP" \
"O servidor DHCP vai atribuir IPs automaticamente aos computadores da rede."

# Configurar IP estático via Netplan

# Substitua a configuração do Netplan por:
cat <<EOF | sudo tee /etc/netplan/01-dhcp-samba.yaml
network:
  version: 2
  ethernets:
    $INTERFACE_REDE:
      addresses:
        - $IP_SERVIDOR/24
      routes:
        - to: default
          via: $GATEWAY
      nameservers:
        addresses: [$IP_SERVIDOR, $DNS_EXTERNO]
EOF
# Corrija as permissões
sudo chmod 600 /etc/netplan/01-dhcp-samba.yaml

# Aplicar a configuração de rede
echo "$SENHA_SUDO" | sudo -S netplan apply
sleep 5


# 1. Verificar se a interface declarada no início existe e está ativa
INTERFACE_CORRIGIDA="$INTERFACE_REDE"

if ! ip link show "$INTERFACE_CORRIGIDA" > /dev/null 2>&1; then
    echo -e "${VERMELHO}ERRO: A interface $INTERFACE_CORRIGIDA não foi encontrada no sistema!${NC}"
    echo -e "${AMARELO}Interfaces disponíveis:${NC}"
    ip link show
    exit 1
fi

if ! ip -4 addr show "$INTERFACE_CORRIGIDA" | grep -q "inet "; then
    echo -e "${VERMELHO}ERRO: A interface $INTERFACE_CORRIGIDA não possui um IP IPv4 configurado!${NC}"
    echo -e "${AMARELO}Configure um IP estático ou dinâmico antes de continuar.${NC}"
    exit 1
fi


# 2. Configurar arquivo dhcpd.conf com verificação de sintaxe
cat <<EOF | sudo tee /etc/dhcp/dhcpd.conf
option domain-name "$DNS_DOMINIO";
option domain-name-servers $IP_SERVIDOR;

default-lease-time 600;
max-lease-time 7200;

subnet 172.16.0.0 netmask $MASCARA {
    range 172.16.0.10 172.16.0.254;
    option routers $GATEWAY;
    option broadcast-address 172.16.0.255;
    interface $INTERFACE_CORRIGIDA;
}
EOF

# 3. Configurar arquivo de interfaces CORRETAMENTE
echo "INTERFACESv4=\"$INTERFACE_CORRIGIDA\"" | sudo tee /etc/default/isc-dhcp-server

# 4. Verificar sintaxe do arquivo de configuração
if ! sudo dhcpd -t -cf /etc/dhcp/dhcpd.conf; then
    echo -e "${VERMELHO}ERRO: Configuração do DHCP inválida! Corrija os erros acima.${NC}"
    exit 1
fi

# 5. Reiniciar serviços corretamente
sudo systemctl stop isc-dhcp-server
sleep 5
sudo systemctl disable isc-dhcp-server
sleep 5
sudo systemctl daemon-reload
sleep 5
sudo systemctl enable isc-dhcp-server
sleep 5
sudo systemctl start isc-dhcp-server
sleep 5

# 6. Verificar status com tratamento de erro
sleep 3
if ! systemctl is-active --quiet isc-dhcp-server; then
    echo -e "${VERMELHO}ERRO: Falha ao iniciar o serviço DHCP. Logs:${NC}"
    journalctl -u isc-dhcp-server -b --no-pager | tail -20
    echo -e "${AMARELO}Dica: Verifique se a interface $INTERFACE_CORRIGIDA está ativa e com um IP configurado${NC}"
    exit 1
fi

testar "echo 'Status do DHCP:'; systemctl status isc-dhcp-server"
sleep 10

## ======================================================
## 8. CRIAÇÃO DE USUÁRIOS E GRUPOS
## ======================================================
explicar "ETAPA 8: CRIAÇÃO DE USUÁRIOS" \
"Vamos criar usuários e grupos para nosso domínio."

# Substitua esta seção no script:
sudo chown -R root:bind /var/lib/samba/private/
sudo chmod -R 770 /var/lib/samba/private/

# Checar se grupos já existem
for grupo in alunos professores administrativos; do
    if ! samba-tool group list | grep -q "^$grupo$"; then
        if ! echo "$SENHA_SUDO" | sudo -S samba-tool group add $grupo; then
            echo -e "${VERMELHO}ERRO ao criar grupo $grupo${NC}"
        fi
    else
        echo -e "${VERDE}Grupo $grupo já existe${NC}"
    fi
done

# Criar grupos
for grupo in alunos professores administrativos; do
    if ! echo "$SENHA_SUDO" | sudo -S samba-tool group add $grupo; then
        echo -e "${VERMELHO}ERRO ao criar grupo $grupo${NC}"
    fi
done

# Criar usuários e adicionar aos grupos
for i in {01..10}; do
    if ! echo "$SENHA_SUDO" | sudo -S samba-tool user create aluno$i SenhaAluno$i --given-name=Aluno --surname=$i; then
        echo -e "${VERMELHO}ERRO ao criar usuário aluno$i${NC}"
    fi
    
    if ! echo "$SENHA_SUDO" | sudo -S samba-tool user create professor$i SenhaProfessor$i --given-name=Professor --surname=$i; then
        echo -e "${VERMELHO}ERRO ao criar usuário professor$i${NC}"
    fi
    
    if ! echo "$SENHA_SUDO" | sudo -S samba-tool user create adm$i SenhaAdm$i --given-name=Admin --surname=$i; then
        echo -e "${VERMELHO}ERRO ao criar usuário adm$i${NC}"
    fi
    
    # Adicionar usuários aos grupos
    echo "$SENHA_SUDO" | sudo -S samba-tool group addmembers alunos aluno$i
    echo "$SENHA_SUDO" | sudo -S samba-tool group addmembers professores professor$i
    echo "$SENHA_SUDO" | sudo -S samba-tool group addmembers administrativos adm$i
done

# Reinicie os serviços:
sudo systemctl restart samba-ad-dc
sudo systemctl restart winbind

sleep 10
testar "echo 'Lista de usuários:'; samba-tool user list"
testar "echo 'Lista de grupos:'; samba-tool group list"

## ======================================================
## 9. CRIAÇÃO DE COMPARTILHAMENTOS - CORRIGIDA
## ======================================================
explicar "ETAPA 9: COMPARTILHAMENTOS DE ARQUIVOS" \
"Vamos criar pastas compartilhadas para diferentes grupos."

# Criar diretórios
PASTA_COMPARTILHADA="/srv/compartilhado"
echo "$SENHA_SUDO" | sudo -S mkdir -p $PASTA_COMPARTILHADA/{Alunos,Professores,Administrativo,Comum}

# Configurar permissões com verificação de grupos
for grupo in alunos professores administrativos; do
    if ! getent group $grupo > /dev/null; then
        echo -e "${VERMELHO}ERRO: Grupo $grupo não existe! Criando...${NC}"
        echo "$SENHA_SUDO" | sudo -S samba-tool group add $grupo
    fi
done

# Aplicar permissões corretamente
echo "$SENHA_SUDO" | sudo -S chown :'DOMAIN\Domain Users' $PASTA_COMPARTILHADA/Comum
echo "$SENHA_SUDO" | sudo -S setfacl -R -m g:"DOMAIN\\alunos":rwx $PASTA_COMPARTILHADA/Alunos
echo "$SENHA_SUDO" | sudo -S setfacl -R -m g:"DOMAIN\\professores":rwx $PASTA_COMPARTILHADA/Professores
echo "$SENHA_SUDO" | sudo -S setfacl -R -m g:"DOMAIN\\administrativos":rwx $PASTA_COMPARTILHADA/Administrativo

# Configurar Samba
cat <<EOF | sudo tee -a /etc/samba/smb.conf
[Alunos]
    path = $PASTA_COMPARTILHADA/Alunos
    read only = no
    valid users = @'DOMAIN\alunos'

[Professores]
    path = $PASTA_COMPARTILHADA/Professores
    read only = no
    valid users = @'DOMAIN\professores'

[Administrativo]
    path = $PASTA_COMPARTILHADA/Administrativo
    read only = no
    valid users = @'DOMAIN\administrativos'

[Comum]
    path = $PASTA_COMPARTILHADA/Comum
    read only = no
    valid users = @'DOMAIN\Domain Users'
EOF

echo "$SENHA_SUDO" | sudo -S systemctl restart samba-ad-dc
sleep 10
testar "echo 'Testando compartilhamentos:'; smbclient -L localhost -U%"

## ======================================================
## 10. CONFIGURAÇÃO FINAL E MENSAGEM DE LOGON
## ======================================================
explicar "ETAPA 10: FINALIZAÇÃO" \
"Últimos passos de configuração."

# Script de logon
echo "$SENHA_SUDO" | sudo -S mkdir -p /var/lib/samba/sysvol/$DNS_DOMINIO/scripts
cat <<EOF | sudo tee /var/lib/samba/sysvol/$DNS_DOMINIO/scripts/login.bat > /dev/null
@echo off
echo $DOMINIO - Parabéns, vocês conseguiram!
net use w: \\\\dc1\\Professores /persistent:yes
net use X: \\\\dc1\\Comum /persistent:yes
net use Y: \\\\dc1\\Alunos /persistent:yes
net use Z: \\\\dc1\\Administrativo /persistent:yes
EOF

echo "$SENHA_SUDO" | sudo -S chmod 755 /var/lib/samba/sysvol/$DNS_DOMINIO/scripts/login.bat
echo "$SENHA_SUDO" | sudo -S chown root:root /var/lib/samba/sysvol/$DNS_DOMINIO/scripts/login.bat

echo "$SENHA_SUDO" | sudo -S samba-tool group policy add --name="Default Domain Policy" --file="/var/lib/samba/sysvol/$DNS_DOMINIO/scripts/login.bat" --script-type="Logon"

# Configurar firewall
echo "$SENHA_SUDO" | sudo -S apt install -y ufw
echo "$SENHA_SUDO" | sudo -S ufw allow 53,135,137,138,139,445,389,636/tcp
echo "$SENHA_SUDO" | sudo -S ufw allow 53,137,138/udp
echo "$SENHA_SUDO" | sudo -S ufw enable

sleep 10
testar "echo 'Script de logon:'; cat /var/lib/samba/sysvol/$DNS_DOMINIO/scripts/login.bat"
testar "echo 'Regras do firewall:'; sudo ufw status"

## ======================================================
## CONCLUSÃO
## ======================================================
echo -e "\n${VERDE}======================================================${NC}"
echo -e "${VERDE}CONFIGURAÇÃO FINALIZADA COM SUCESSO!${NC}"
echo -e "${VERDE}======================================================${NC}"
echo -e "\nSeu controlador de domínio está pronto para uso."
echo -e "Agora você pode adicionar computadores Windows ao domínio $REINO"
echo -e "Use as credenciais:"
echo -e "  Usuário: administrator"
echo -e "  Senha: a senha sudo que você digitou no início"
echo -e "\n${AMARELO}Script desenvolvido por Daniel Santos - danielsantos@grupoiconne.net${NC}"