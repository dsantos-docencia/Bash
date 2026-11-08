#!/bin/bash
# -------------------------------------------------------------------------
# Script de Instalação e Configuração de um Controlador de Domínio com Samba
# Versão Corrigida - Para Iniciantes em Linux
# Autor Daniel Santos / danielsantos@grupoiconne.net
# Instala e configura Samba, DHCP, DNS, Kerberos, Hostname...
# ... ip fixo na interface ENPS08, cria users e pastas de rede...
# ... cria regras no firewall, automatiza mapeamento das pastas no cliente
# Homologado para Ubuntu Server 2024.04.01 cli opção padrão (não instalar opção minimizada,...
# ... pois bibliotecas e comandos essenciais são removidos e precisarão ser instalados...
# ... manualmente depois. Caso esteja trabalhando numa instalação minimizada, digite...
# ... #sudo unminimized para restaurar as opções padrões de sistema e suas respectivas bibliotecas,...
# ... sem alterar suas configurações.
# Versão: 25 - Junho/2025
# Altere as opções básicas logo abaixo para suas necessidades, atenção especial para:...
# hostname, interface de rede, ips, gateway, etc
# É comum dar erro mesmo após dar permissão pelo chmod +x nome_do_script, caso você faça ele em Windows...
# ... esse erro (with CRLF line terminators) normalmente é devido script ter sifo feito em Windows...
# ... nesse caso, execute os comandos abaixo para converter o script em formato Unix (LF):
# $ sudo apt update
# $ sudo apt install dos2unix -y
# $ dos2unix "SEU SCRIPT.SH"
# -------------------------------------------------------------------------

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

# Defina o nome do arquivo de log (altere se quiser outro nome)
LOGFILE="log_instalacao_samba_dns_dhcp.log"

# Redirecione toda a saída para a tela e para o log ao mesmo tempo
exec > >(tee -a "$LOGFILE") 2>&1

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

# Função para logar comandos
log_comando() {
    echo -e "\n===== Comando: $* ====="
    eval "$@"
    local STATUS=$?
    echo -e "===== Fim do comando (status: $STATUS) =====\n"
    return $STATUS
}

# Função para testar resultado
testar() {
    echo -e "\n${AMARELO}Testando resultado:${NC}"
    echo -e "$1"
    log_comando "$1"
    echo -e "\n${VERDE}Verifique acima se o resultado está correto antes de continuar.${NC}"
    sleep 5
}

## ======================================================
## 1. ATUALIZAÇÃO DO SISTEMA
## ======================================================
explicar "ETAPA 1: ATUALIZAÇÃO DO SISTEMA" \
"Nesta etapa, vamos atualizar a lista de pacotes e todos os programas instalados.
Isso é importante para garantir que estamos usando as versões mais recentes e seguras."

echo -e "\n${VERDE}Por favor, digite a senha do seu usuário com permissões sudo (mínimo 8 caracteres, com maiúsculas, minúsculas e números):${NC}"
read -s SENHA_SUDO

# Verificar complexidade da senha
if [[ ${#SENHA_SUDO} -lt 8 || ! "$SENHA_SUDO" =~ [A-Z] || ! "$SENHA_SUDO" =~ [a-z] || ! "$SENHA_SUDO" =~ [0-9] ]]; then
    echo -e "${VERMELHO}ERRO: A senha deve ter pelo menos 8 caracteres, incluindo maiúsculas, minúsculas e números${NC}"
    exit 1
fi

# Atualizando o sistema
log_comando "echo \"$SENHA_SUDO\" | sudo -S apt update && sudo apt upgrade -y"
sleep 10

testar "echo 'Verificando atualizações pendentes...'; apt list --upgradable -a"

## ======================================================
## 2. INSTALAÇÃO DE PACOTES NECESSÁRIOS
## ======================================================
explicar "ETAPA 2: INSTALAÇÃO DE PACOTES" \
"Aqui vamos instalar todos os programas necessários para o controlador de domínio."

# Pré-configurar o Kerberos
log_comando "echo \"$SENHA_SUDO\" | sudo -S bash -c \"cat <<EOF | debconf-set-selections
krb5-config krb5-config/default_realm string $REINO
krb5-config krb5-config/kerberos_servers string dc1.$DNS_DOMINIO
krb5-config krb5-config/admin_server string dc1.$DNS_DOMINIO
krb5-config krb5-config/add_servers_realm string $REINO
krb5-config krb5-config/add_servers boolean true
krb5-config krb5-config/read_conf boolean true
EOF\""

# Instalar pacotes essenciais incluindo dnsutils
log_comando "echo \"$SENHA_SUDO\" | sudo -S DEBIAN_FRONTEND=noninteractive apt install -y samba krb5-config winbind bind9 isc-dhcp-server acl smbclient dnsutils"
sleep 10

log_comando "echo \"$SENHA_SUDO\" | sudo -S apt-get install -y --fix-broken"
log_comando "echo \"$SENHA_SUDO\" | sudo -S apt-get autoremove -y"

testar "echo 'Versão do Samba instalada:'; samba --version"
testar "echo 'Status do serviço DNS:'; systemctl status bind9"

## ======================================================
## 3. CONFIGURAÇÃO BÁSICA DO SISTEMA
## ======================================================
explicar "ETAPA 3: CONFIGURAÇÃO BÁSICA" \
"Vamos configurar o nome do servidor e o arquivo hosts."

log_comando "echo \"$SENHA_SUDO\" | sudo -S hostnamectl set-hostname dc1"
log_comando "echo \"$SENHA_SUDO\" | sudo -S sysctl -w net.ipv6.conf.all.disable_ipv6=1"
log_comando "echo \"$SENHA_SUDO\" | sudo -S sysctl -w net.ipv6.conf.default.disable_ipv6=1"

log_comando "echo \"127.0.0.1 localhost\" | sudo tee /etc/hosts"
log_comando "echo \"$IP_SERVIDOR dc1.$DNS_DOMINIO dc1\" | sudo tee -a /etc/hosts"

log_comando "echo \"$SENHA_SUDO\" | sudo -S timedatectl set-ntp true"
log_comando "echo \"$SENHA_SUDO\" | sudo -S systemctl restart systemd-timesyncd"
sleep 10

testar "echo 'Hostname configurado:'; hostname"
testar "echo 'Conteúdo do /etc/hosts:'; cat /etc/hosts"
testar "echo 'Status do NTP:'; timedatectl status"

## ======================================================
## 4. CONFIGURAÇÃO DO SERVIDOR DNS (BIND9)
## ======================================================
explicar "ETAPA 4: CONFIGURAÇÃO DO DNS" \
"O servidor DNS é crucial para um controlador de domínio."

log_comando "cat <<EOF | sudo tee /etc/bind/named.conf.options
options {
    directory \"/var/cache/bind\";
    forwarders {
        $DNS_EXTERNO;
    };
    allow-query { any; };
    recursion yes;
    dnssec-validation no;
    auth-nxdomain no;
    listen-on { any; };
};
EOF"

log_comando "cat <<EOF | sudo tee /etc/bind/named.conf.local
zone \"$DNS_DOMINIO\" {
    type master;
    file \"/etc/bind/db.$DNS_DOMINIO\";
};

zone \"16.172.in-addr.arpa\" {
    type master;
    file \"/etc/bind/db.172.16\";
};
EOF"

log_comando "cat <<EOF | sudo tee /etc/bind/db.$DNS_DOMINIO
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
EOF"

log_comando "cat <<EOF | sudo tee /etc/bind/db.172.16
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
EOF"

log_comando "echo \"$SENHA_SUDO\" | sudo -S systemctl stop bind9"
log_comando "echo \"$SENHA_SUDO\" | sudo -S systemctl disable bind9"

log_comando "echo \"$SENHA_SUDO\" | sudo -S named-checkconf"
log_comando "echo \"$SENHA_SUDO\" | sudo -S named-checkzone $DNS_DOMINIO /etc/bind/db.$DNS_DOMINIO"
log_comando "echo \"$SENHA_SUDO\" | sudo -S named-checkzone 16.172.in-addr.arpa /etc/bind/db.172.16"

log_comando "echo \"$SENHA_SUDO\" | sudo -S systemctl enable named"
log_comando "echo \"$SENHA_SUDO\" | sudo -S systemctl restart named"

sleep 10
testar "echo 'Testando resolução DNS:'; dig $DNS_DOMINIO @localhost"

## ======================================================
## 5. CONFIGURAÇÃO DO KERBEROS
## ======================================================
explicar "ETAPA 5: CONFIGURAÇÃO DO KERBEROS" \
"Kerberos é um sistema de autenticação segura usado em domínios Windows."

log_comando "cat <<EOF | sudo tee /etc/krb5.conf
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
EOF"
sleep 10
testar "echo 'Configuração do Kerberos:'; cat /etc/krb5.conf | grep -v '^#' | grep -v '^$'"

## ======================================================
## 6. CONFIGURAÇÃO DO SAMBA COMO CONTROLADOR DE DOMÍNIO - CORRIGIDA
## ======================================================
explicar "ETAPA 6: CONFIGURAÇÃO DO SAMBA" \
"Agora vamos transformar este servidor em um controlador de domínio."

log_comando "echo \"$SENHA_SUDO\" | sudo -S systemctl stop smbd nmbd winbind"
sleep 5

log_comando "echo \"$SENHA_SUDO\" | sudo -S mkdir -p /var/lib/samba/private"
log_comando "echo \"$SENHA_SUDO\" | sudo -S chown -R root:bind /var/lib/samba/private"
log_comando "echo \"$SENHA_SUDO\" | sudo -S chmod -R 770 /var/lib/samba/private"

log_comando "echo \"$SENHA_SUDO\" | sudo -S mv /etc/samba/smb.conf /etc/samba/smb.conf.bkp"
if ! log_comando "echo \"$SENHA_SUDO\" | sudo -S samba-tool domain provision --use-rfc2307 --realm=$REINO --domain=$DOMINIO --adminpass=\"$SENHA_SUDO\" --server-role=dc"; then
    echo -e "${VERMELHO}ERRO no provisionamento do domínio. Verifique os logs.${NC}"
    exit 1
fi

log_comando "echo \"nameserver $IP_SERVIDOR\" | sudo tee /etc/resolv.conf"
log_comando "echo \"search $DNS_DOMINIO\" | sudo tee -a /etc/resolv.conf"

log_comando "echo \"$SENHA_SUDO\" | sudo -S chown -R root:bind /var/lib/samba/private"
log_comando "echo \"$SENHA_SUDO\" | sudo -S chmod -R 770 /var/lib/samba/private"

log_comando "echo \"$SENHA_SUDO\" | sudo -S systemctl start samba-ad-dc"
log_comando "echo \"$SENHA_SUDO\" | sudo -S systemctl enable samba-ad-dc"

sleep 10
testar "echo 'Informações do domínio'; samba-tool domain info localhost"

## ======================================================
## 7. CONFIGURAÇÃO DO DHCP - VERSÃO CORRIGIDA
## ======================================================
explicar "ETAPA 7: CONFIGURAÇÃO DO DHCP" \
"O servidor DHCP vai atribuir IPs automaticamente aos computadores da rede."

log_comando "cat <<EOF | sudo tee /etc/netplan/01-dhcp-samba.yaml
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
EOF"
log_comando "sudo chmod 600 /etc/netplan/01-dhcp-samba.yaml"
log_comando "echo \"$SENHA_SUDO\" | sudo -S netplan apply"
sleep 5

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

log_comando "cat <<EOF | sudo tee /etc/dhcp/dhcpd.conf
option domain-name \"$DNS_DOMINIO\";
option domain-name-servers $IP_SERVIDOR;

default-lease-time 600;
max-lease-time 7200;

subnet 172.16.0.0 netmask $MASCARA {
    range 172.16.0.10 172.16.0.254;
    option routers $GATEWAY;
    option broadcast-address 172.16.0.255;
    interface $INTERFACE_CORRIGIDA;
}
EOF"

log_comando "echo \"INTERFACESv4=\\\"$INTERFACE_CORRIGIDA\\\"\" | sudo tee /etc/default/isc-dhcp-server"

if ! log_comando "sudo dhcpd -t -cf /etc/dhcp/dhcpd.conf"; then
    echo -e "${VERMELHO}ERRO: Configuração do DHCP inválida! Corrija os erros acima.${NC}"
    exit 1
fi

log_comando "sudo systemctl stop isc-dhcp-server"
sleep 5
log_comando "sudo systemctl disable isc-dhcp-server"
sleep 5
log_comando "sudo systemctl daemon-reload"
sleep 5
log_comando "sudo systemctl enable isc-dhcp-server"
sleep 5
log_comando "sudo systemctl start isc-dhcp-server"
sleep 5

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

log_comando "sudo chown -R root:bind /var/lib/samba/private/"
log_comando "sudo chmod -R 770 /var/lib/samba/private/"

for grupo in alunos professores administrativos; do
    if ! samba-tool group list | grep -q "^$grupo$"; then
        if ! log_comando "echo \"$SENHA_SUDO\" | sudo -S samba-tool group add $grupo"; then
            echo -e "${VERMELHO}ERRO ao criar grupo $grupo${NC}"
        fi
    else
        echo -e "${VERDE}Grupo $grupo já existe${NC}"
    fi
done

for grupo in alunos professores administrativos; do
    log_comando "echo \"$SENHA_SUDO\" | sudo -S samba-tool group add $grupo"
done

for i in {01..10}; do
    log_comando "echo \"$SENHA_SUDO\" | sudo -S samba-tool user create aluno$i SenhaAluno$i --given-name=Aluno --surname=$i"
    log_comando "echo \"$SENHA_SUDO\" | sudo -S samba-tool user create professor$i SenhaProfessor$i --given-name=Professor --surname=$i"
    log_comando "echo \"$SENHA_SUDO\" | sudo -S samba-tool user create adm$i SenhaAdm$i --given-name=Admin --surname=$i"
    log_comando "echo \"$SENHA_SUDO\" | sudo -S samba-tool group addmembers alunos aluno$i"
    log_comando "echo \"$SENHA_SUDO\" | sudo -S samba-tool group addmembers professores professor$i"
    log_comando "echo \"$SENHA_SUDO\" | sudo -S samba-tool group addmembers administrativos adm$i"
done

log_comando "sudo systemctl restart samba-ad-dc"
log_comando "sudo systemctl restart winbind"

sleep 10
testar "echo 'Lista de usuários:'; samba-tool user list"
testar "echo 'Lista de grupos:'; samba-tool group list"

## ======================================================
## 9. CRIAÇÃO DE COMPARTILHAMENTOS - CORRIGIDA
## ======================================================
explicar "ETAPA 9: COMPARTILHAMENTOS DE ARQUIVOS" \
"Vamos criar pastas compartilhadas para diferentes grupos."

PASTA_COMPARTILHADA="/srv/compartilhado"
log_comando "echo \"$SENHA_SUDO\" | sudo -S mkdir -p $PASTA_COMPARTILHADA/{Alunos,Professores,Administrativo,Comum}"

for grupo in alunos professores administrativos; do
    if ! getent group $grupo > /dev/null; then
        echo -e "${VERMELHO}ERRO: Grupo $grupo não existe! Criando...${NC}"
        log_comando "echo \"$SENHA_SUDO\" | sudo -S samba-tool group add $grupo"
    fi
done

log_comando "echo \"$SENHA_SUDO\" | sudo -S chown :'DOMAIN\\Domain Users' $PASTA_COMPARTILHADA/Comum"
log_comando "echo \"$SENHA_SUDO\" | sudo -S setfacl -R -m g:\"DOMAIN\\\\alunos\":rwx $PASTA_COMPARTILHADA/Alunos"
log_comando "echo \"$SENHA_SUDO\" | sudo -S setfacl -R -m g:\"DOMAIN\\\\professores\":rwx $PASTA_COMPARTILHADA/Professores"
log_comando "echo \"$SENHA_SUDO\" | sudo -S setfacl -R -m g:\"DOMAIN\\\\administrativos\":rwx $PASTA_COMPARTILHADA/Administrativo"

log_comando "cat <<EOF | sudo tee -a /etc/samba/smb.conf
[Alunos]
    path = $PASTA_COMPARTILHADA/Alunos
    read only = no
    valid users = @'DOMAIN\\alunos'

[Professores]
    path = $PASTA_COMPARTILHADA/Professores
    read only = no
    valid users = @'DOMAIN\\professores'

[Administrativo]
    path = $PASTA_COMPARTILHADA/Administrativo
    read only = no
    valid users = @'DOMAIN\\administrativos'

[Comum]
    path = $PASTA_COMPARTILHADA/Comum
    read only = no
    valid users = @'DOMAIN\\Domain Users'
EOF"

log_comando "echo \"$SENHA_SUDO\" | sudo -S systemctl restart samba-ad-dc"
sleep 10
testar "echo 'Testando compartilhamentos:'; smbclient -L localhost -U%"

## ======================================================
## 10. CONFIGURAÇÃO FINAL E MENSAGEM DE LOGON
## ======================================================
explicar "ETAPA 10: FINALIZAÇÃO" \
"Últimos passos de configuração."

log_comando "echo \"$SENHA_SUDO\" | sudo -S mkdir -p /var/lib/samba/sysvol/$DNS_DOMINIO/scripts"
log_comando "cat <<EOF | sudo tee /var/lib/samba/sysvol/$DNS_DOMINIO/scripts/login.bat > /dev/null
@echo off
echo $DOMINIO - Parabéns, vocês conseguiram!
net use w: \\\\dc1\\Professores /persistent:yes
net use X: \\\\dc1\\Comum /persistent:yes
net use Y: \\\\dc1\\Alunos /persistent:yes
net use Z: \\\\dc1\\Administrativo /persistent:yes
EOF"

log_comando "echo \"$SENHA_SUDO\" | sudo -S chmod 755 /var/lib/samba/sysvol/$DNS_DOMINIO/scripts/login.bat"
log_comando "echo \"$SENHA_SUDO\" | sudo -S chown root:root /var/lib/samba/sysvol/$DNS_DOMINIO/scripts/login.bat"

log_comando "echo \"$SENHA_SUDO\" | sudo -S samba-tool group policy add --name=\"Default Domain Policy\" --file=\"/var/lib/samba/sysvol/$DNS_DOMINIO/scripts/login.bat\" --script-type=\"Logon\""

log_comando "echo \"$SENHA_SUDO\" | sudo -S apt install -y ufw"
log_comando "echo \"$SENHA_SUDO\" | sudo -S ufw allow 53,135,137,138,139,445,389,636/tcp"
log_comando "echo \"$SENHA_SUDO\" | sudo -S ufw allow 53,137,138/udp"
log_comando "echo \"$SENHA_SUDO\" | sudo -S ufw enable"

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
echo -e "\n${AMARELO}O log detalhado dos comandos está salvo em: ${LOG_ARQUIVO}${NC}"
