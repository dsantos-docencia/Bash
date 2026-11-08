#!/bin/bash
# -------------------------------------------------------------------------
# Versao Corrigida: v23
# Script de Configuracao de Samba AD DC + DNS + DHCP + Kerberos + Firewall
# Base: Ubuntu Server 24.04.2 LTS
# Correcoes: permissao do samba-tool, provisionamento, DNS, conectividade
# -------------------------------------------------------------------------

# ==================== CONFIGURACAO INICIAL =====================

# Verifica se o script esta sendo executado como root
if [[ $EUID -ne 0 ]]; then
  echo "Este script deve ser executado como root (sudo su)"
  exit 1
fi

# Cores para destacar mensagens no terminal
VERMELHO='\033[0;31m'    # Mensagens de erro
VERDE='\033[0;32m'       # Mensagens de sucesso
AMARELO='\033[1;33m'     # Alertas e avisos
AZUL='\033[0;34m'        # Títulos e cabeçalhos
NC='\033[0m'             # Reset de cor

# Variaveis principais da configuracao
DOMINIO="TI52"
DNS_DOMINIO="ti52.aprendendo"
REINO="TI52.APRENDENDO"
IP_SERVIDOR="172.16.0.2"
MASCARA="255.255.255.0"
GATEWAY="172.16.0.1"
DNS_EXTERNO="8.8.8.8"
INTERFACE_REDE="enp0s8"

# ==================== TESTES INICIAIS DE CONECTIVIDADE =====================

# Verifica se ha conectividade com a internet e repositórios
echo -e "${AZUL}Verificando conectividade...${NC}"
ping -c 2 8.8.8.8 &> /dev/null || {
  echo -e "${VERMELHO}Sem acesso à internet. Verifique o gateway e o cabo de rede.${NC}"
  exit 1
}

ping -c 2 archive.ubuntu.com &> /dev/null || {
  echo -e "${AMARELO}Aviso: Sem acesso aos repositórios. Pacotes podem falhar ao instalar.${NC}"
}

# Força o DNS externo temporário para evitar falhas
echo "nameserver $DNS_EXTERNO" > /etc/resolv.conf
sleep 2

# ==================== ATUALIZA SISTEMA =====================

# Atualiza a lista de pacotes e realiza upgrades
echo -e "${AZUL}Atualizando sistema...${NC}"
apt update && apt upgrade -y
sleep 5

# ==================== INSTALA PACOTES =====================

# Instala os pacotes necessários para AD, DNS, DHCP e outros utilitários
echo -e "${AZUL}Instalando pacotes...${NC}"
DEBIAN_FRONTEND=noninteractive apt install -y samba krb5-config winbind bind9 isc-dhcp-server acl smbclient dnsutils net-tools ufw
sleep 5

# ==================== CONFIGURA HOSTNAME E TEMPO =====================

# Define o hostname do servidor como dc1
echo -e "${AZUL}Configurando hostname e sincronização de tempo...${NC}"
hostnamectl set-hostname dc1

# Atualiza o arquivo /etc/hosts
echo "127.0.0.1 localhost" > /etc/hosts
echo "$IP_SERVIDOR dc1.$DNS_DOMINIO dc1" >> /etc/hosts

# Sincroniza tempo com servidor NTP (fundamental para Kerberos)
systemctl restart systemd-timesyncd
sleep 2

# ==================== CONFIGURA DNS (BIND9) =====================

# Configura o Bind9 com zona direta e reversa
echo -e "${AZUL}Configurando servidor DNS...${NC}"
cat <<EOF > /etc/bind/named.conf.options
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

cat <<EOF > /etc/bind/named.conf.local
zone "$DNS_DOMINIO" {
    type master;
    file "/etc/bind/db.$DNS_DOMINIO";
};

zone "16.172.in-addr.arpa" {
    type master;
    file "/etc/bind/db.172.16";
};
EOF

# Cria zona direta (nome -> IP)
cat <<EOF > /etc/bind/db.$DNS_DOMINIO
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

# Cria zona reversa (IP -> nome)
cat <<EOF > /etc/bind/db.172.16
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

# Reinicia o serviço do BIND para aplicar configurações
systemctl restart named
sleep 2

# ==================== CONFIGURA KERBEROS =====================

# Cria o arquivo de configuracao do Kerberos com base no domínio
echo -e "${AZUL}Configurando Kerberos...${NC}"
cat <<EOF > /etc/krb5.conf
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
sleep 2

# ==================== PROVISIONAMENTO SAMBA AD =====================

# Remove o smb.conf original e inicia o provisionamento do domínio
echo -e "${AZUL}Provisionando o domínio Active Directory...${NC}"
mv /etc/samba/smb.conf /etc/samba/smb.conf.bkp

samba-tool domain provision \
  --use-rfc2307 \
  --realm=$REINO \
  --domain=$DOMINIO \
  --server-role=dc \
  --adminpass='SenhaAdmin123' || {
    echo -e "${VERMELHO}Erro no provisionamento. Verifique os logs.${NC}"
    exit 1
}

# Ativa e inicia o serviço principal do Samba como controlador
systemctl unmask samba-ad-dc
systemctl enable samba-ad-dc
systemctl start samba-ad-dc
sleep 3

# ==================== CONFIGURA DHCP =====================

# Cria arquivo de configuração para interface com IP fixo via netplan
echo -e "${AZUL}Configurando DHCP (escopo e rede)...${NC}"
cat <<EOF > /etc/netplan/01-dhcp-samba.yaml
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
netplan apply
sleep 2

# Configura escopo DHCP
cat <<EOF > /etc/dhcp/dhcpd.conf
option domain-name "$DNS_DOMINIO";
option domain-name-servers $IP_SERVIDOR;

default-lease-time 600;
max-lease-time 7200;

subnet 172.16.0.0 netmask $MASCARA {
  range 172.16.0.10 172.16.0.254;
  option routers $GATEWAY;
  option broadcast-address 172.16.0.255;
  interface $INTERFACE_REDE;
}
EOF

# Define interface utilizada pelo serviço DHCP
echo "INTERFACESv4=\"$INTERFACE_REDE\"" > /etc/default/isc-dhcp-server

# Valida configuração e inicia serviço
if dhcpd -t -cf /etc/dhcp/dhcpd.conf; then
  systemctl enable isc-dhcp-server
  systemctl restart isc-dhcp-server
else
  echo -e "${VERMELHO}Erro na configuração do DHCP. Verifique o arquivo dhcpd.conf.${NC}"
fi
sleep 2

# ==================== CRIA USUÁRIOS E GRUPOS =====================

# Cria grupos e usuários de exemplo com senhas padrão para testes
echo -e "${AZUL}Criando grupos e usuários de exemplo...${NC}"
for grupo in alunos professores administrativos; do
  samba-tool group add $grupo
done

for i in {01..05}; do
  samba-tool user create aluno$i SenhaAluno$i --given-name=Aluno --surname=$i
  samba-tool user create professor$i SenhaProfessor$i --given-name=Professor --surname=$i
  samba-tool user create adm$i SenhaAdm$i --given-name=Admin --surname=$i
  samba-tool group addmembers alunos aluno$i
  samba-tool group addmembers professores professor$i
  samba-tool group addmembers administrativos adm$i
  sleep 1
done

# ==================== COMPARTILHAMENTOS DE REDE =====================

# Cria pastas e define permissões para compartilhamento via Samba
echo -e "${AZUL}Criando compartilhamentos de rede...${NC}"
mkdir -p /srv/compartilhado/{Alunos,Professores,Administrativo,Comum}

# Aplica permissões com ACLs
setfacl -R -m g:"$DOMINIO\\alunos":rwx /srv/compartilhado/Alunos
setfacl -R -m g:"$DOMINIO\\professores":rwx /srv/compartilhado/Professores
setfacl -R -m g:"$DOMINIO\\administrativos":rwx /srv/compartilhado/Administrativo

# Adiciona configuração ao smb.conf
cat <<EOF >> /etc/samba/smb.conf
[Alunos]
  path = /srv/compartilhado/Alunos
  read only = no
  valid users = @"$DOMINIO\\alunos"

[Professores]
  path = /srv/compartilhado/Professores
  read only = no
  valid users = @"$DOMINIO\\professores"

[Administrativo]
  path = /srv/compartilhado/Administrativo
  read only = no
  valid users = @"$DOMINIO\\administrativos"

[Comum]
  path = /srv/compartilhado/Comum
  read only = no
  valid users = @"$DOMINIO\\Domain Users"
EOF

systemctl restart samba-ad-dc
sleep 3

# ==================== SCRIPT DE LOGON E FIREWALL =====================

# Cria script de logon para mapear drives
mkdir -p /var/lib/samba/sysvol/$DNS_DOMINIO/scripts
cat <<EOF > /var/lib/samba/sysvol/$DNS_DOMINIO/scripts/login.bat
@echo off
echo Bem-vindo ao domínio $DOMINIO!
net use x: \\dc1\Comum /persistent:yes
net use y: \\dc1\Alunos /persistent:yes
net use z: \\dc1\Professores /persistent:yes
net use w: \\dc1\Administrativo /persistent:yes
EOF
chmod 755 /var/lib/samba/sysvol/$DNS_DOMINIO/scripts/login.bat

# Habilita portas no firewall
ufw allow 53,135,137,138,139,445,389,636/tcp
ufw allow 53,137,138/udp
ufw --force enable

# ==================== FIM =====================

# Mensagem de conclusão
echo -e "\n${VERDE}CONFIGURAÇÃO CONCLUÍDA COM SUCESSO!${NC}"
echo -e "${AMARELO}Próximos passos recomendados:${NC}"
echo -e "1. Validar conectividade com clientes Windows"
echo -e "2. Testar logon de usuários no domínio"
echo -e "3. Acessar os compartilhamentos de rede"
echo -e "4. Criar e aplicar políticas de grupo (GPOs)"
echo -e "5. Monitorar logs do sistema com journalctl e /var/log/samba"

exit 0
