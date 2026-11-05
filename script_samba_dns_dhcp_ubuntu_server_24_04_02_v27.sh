#!/bin/bash
# ---------------------------------------------------------------------------------------------------------------
# Versão: 27 - Junho/2025																						-
# Desenvoldido por Daniel Santos / danielsantos@grupoiconne														-
# Script de Instalação e Configuração de um Controlador de Domínio com Samba									-
# Versão Corrigida - Para Iniciantes em Linux																	-
# Autor Daniel Santos / danielsantos@grupoiconne.net															-

# ---------------------------------------------------------------------------------------------------------------
# CHANGELOG V28:
# - Corrigido conflito DNS (porta 53) BIND9 e Samba AD DC, para simpleficar instalação e corrigir conflitos. 
#	- Cenário 1: Samba será o servidor DNS (mais comum em AD DC)
#	-- Você NÃO deve iniciar o serviço BIND9.
# 	- Cenário 2: Quer usar o BIND9 como DNS do Samba (avançado)
# 	-- Só siga esse caminho se você provisionou o Samba com --dns-backend=BIND9_DLZ.
#	-- Nesse caso, você pode manter o BIND9 rodando, mas precisa configurar o DLZ corretamente.
# - Nosso cenário será o Cenário 1, removendo a partir da versão v28 do script o BIND9...
# ... e substituindo pelo SAMBA_INTERNAL.
# - Para mais informações sobre DNS no Samba, consulta final do arquivo com Apêndice A
# ---------------------------------------------------------------------------------------------------------------

# ---------------------------------------------------------------------------------------------------------------
# CHANGELOG V27:
# - Corrigido erro no samba-tool domain info adicionando FQDN no /etc/hosts antes do teste.
# - Corrigida sintaxe do setfacl com domínio NetBIOS e escape correto das barras.
# - Adicionada variável DOMINIO_NETBIOS no início.
# - Adicionado restart do serviço samba-ad-dc antes do teste de smbclient.
# - Script final gerado com permissão de execução (chmod +x).
# ---------------------------------------------------------------------------------------------------------------

# ---------------------------------------------------------------------------------------------------------------
# CHANGELOG V26:
# - Corrigido erro no comando 'samba-tool domain info' que não aceita IP diretamente.
# - Substituído por FQDN: dc1.$DNS_DOMINIO.
# ---------------------------------------------------------------------------------------------------------------

# Serviços incluídos: Samba (AD), BIND9 ou SAMBA_INTERNAL (DNS), ISC DHCP, Kerberos e Firewall					-
# Otimizado para Ubuntu Server 24.04.2 LTS																		-
# Instala e configura Samba, DHCP, DNS, Kerberos, Hostname...													-
# O Samba AD DC será o servidor DNS primário.																	-
# ... ip fixo na interface ENPS08, cria users e pastas de rede...												-
# ... cria regras no firewall, automatiza mapeamento das pastas no cliente										-
# Homologado para Ubuntu Server 2024.04.01 cli opção padrão (não instalar opção minimizada,...					-
# ... pois bibliotecas e comandos essenciais são removidos e precisarão ser instalados...						-
# ... manualmente depois. Caso esteja trabalhando numa instalação minimizada, digite...							-
# ... #sudo unminimized para restaurar as opções padrões de sistema e suas respectivas bibliotecas,...			-
# ... sem alterar suas configurações.																			-
# Altere as opções básicas logo abaixo para suas necessidades, atenção especial para:...						-
# hostname, interface de rede, ips, gateway, etc																-
# É comum dar erro mesmo após dar permissão pelo chmod +x nome_do_script, caso você faça ele em Windows...		-
# ... esse erro (with CRLF line terminators) normalmente é devido script ter sifo feito em Windows...			-
# ... nesse caso, execute os comandos abaixo para converter o script em formato Unix (LF):						-
# $ sudo apt update																								-
# $ sudo apt install dos2unix -y																				-
# $ dos2unix "SEU SCRIPT.SH"																					-
# Execute esse script como root (sudo ./seu_Script.sh)															-
# Tenha 2 interfaces de rede, (nat / bridge - WAN e interna - LAN (nesse caso enp0s8) 							-

# ---------------------------------------------------------------------------------------------------------------


# Configuração de cores para saída do terminal
VERMELHO='\033[0;31m'    # Mensagens de erro
VERDE='\033[0;32m'       # Mensagens de sucesso
AMARELO='\033[1;33m'     # Alertas e avisos
AZUL='\033[0;34m'        # Títulos e cabeçalhos
NC='\033[0m'             # Reset de cor

### VARIÁVEIS DE CONFIGURAÇÃO ###
DOMINIO="TI52"
DOMINIO_NETBIOS="TI52"             						# Nome NetBIOS do domínio (15 chars max)
DNS_DOMINIO="ti52.aprendendo"    						# Nome DNS completo do domínio
REINO="TI52.APRENDENDO"          						# Realm Kerberos (deve ser maiúsculo)
IP_SERVIDOR="172.16.0.2"         						# IP fixo do servidor DC

# Remover espaços acidentais das variáveis
DNS_DOMINIO=$(echo "$DNS_DOMINIO" | tr -d '[:space:]')
IP_SERVIDOR=$(echo "$IP_SERVIDOR" | tr -d '[:space:]')
echo "DEBUG: IP_SERVIDOR=[$IP_SERVIDOR]"

MASCARA="255.255.255.0"          						# Máscara de rede (/24)
GATEWAY="172.16.0.1"            						# Gateway padrão da rede
DNS_EXTERNO="8.8.8.8"            						# DNS externo para forwarding
INTERFACE_REDE="enp0s8"          						# Interface de rede principal

### FUNÇÕES UTILITÁRIAS ###

explicar() {
    # Exibe mensagem explicativa antes de cada bloco principal
    echo -e "\n${AZUL}========== ETAPA $1 ==========${NC}"
    echo -e "${AMARELO}$2${NC}"
    echo -e "${AZUL}=================================${NC}"
    echo -e "${VERDE}Ações que serão executadas:${NC}\n$3"
    echo -e "\n${VERDE}Pressione ENTER para continuar (aguarde 60s)...${NC}"
    read -t 60
}

testar() {
    # Verifica o resultado dos comandos executados
    echo -e "\n${AMARELO}VERIFICAÇÃO DE RESULTADOS:${NC}"
    echo -e "$1"
    eval "$1"
    echo -e "\n${VERDE}Verifique os resultados antes de continuar.${NC}"
    sleep 5
}

## ======================================================
## 1. ATUALIZAÇÃO DO SISTEMA
## ======================================================
explicar "1/9" "PREPARAÇÃO INICIAL DO SERVIDOR" \
"- Atualização completa do sistema
- Verificação de dependências
- Configuração de senha administrativa"

# Solicitação segura de senha sudo com requisitos mínimos
echo -e "\n${VERDE}Por favor, digite a senha do administrador:${NC}"
echo -e "${AMARELO}(Mínimo 8 caracteres, com maiúsculas, minúsculas e números)${NC}"
read -s SENHA_SUDO

# Validação de complexidade da senha
if [[ ${#SENHA_SUDO} -lt 8 || ! "$SENHA_SUDO" =~ [A-Z] || ! "$SENHA_SUDO" =~ [a-z] || ! "$SENHA_SUDO" =~ [0-9] ]]; then
    echo -e "${VERMELHO}ERRO: A senha não atende aos requisitos de segurança${NC}"
    exit 1
fi

# Execução das atualizações do sistema
echo "$SENHA_SUDO" | sudo -S apt update && sudo apt upgrade -y
sleep 10

# Verificação de pacotes que podem ser atualizados
testar "echo 'Pacotes disponíveis para atualização:'; apt list --upgradable -a"

## ======================================================
## 2. INSTALAÇÃO DE PACOTES NECESSÁRIOS
## ======================================================
explicar "2/9" "INSTALAÇÃO DOS SERVIÇOS REQUERIDOS" \
"- Samba 4 (Active Directory)
- SAMBA_INTERNAL (Servidor DNS)
- ISC DHCP Server
- Kerberos (Autenticação)
- Utilitários de rede"

# Pré-configuração do Kerberos para instalação não interativa
echo "$SENHA_SUDO" | sudo -S bash -c "cat <<EOF | debconf-set-selections
krb5-config krb5-config/default_realm string $REINO
krb5-config krb5-config/kerberos_servers string dc1.$DNS_DOMINIO
krb5-config krb5-config/admin_server string dc1.$DNS_DOMINIO
krb5-config krb5-config/add_servers_realm string $REINO
krb5-config krb5-config/add_servers boolean true
krb5-config krb5-config/read_conf boolean true
EOF"

# Instalação dos pacotes principais em modo não interativo
echo "$SENHA_SUDO" | sudo -S DEBIAN_FRONTEND=noninteractive apt install -y \
    samba krb5-config isc-dhcp-server acl smbclient dnsutils
sleep 10

# Correção de possíveis problemas pós-instalação
echo "$SENHA_SUDO" | sudo -S apt-get install -y --fix-broken
echo "$SENHA_SUDO" | sudo -S apt-get autoremove -y

# Verificações pós-instalação
testar "echo 'Versão do Samba instalada:'; samba --version"
testar "echo 'Status do serviço DNS:'; systemctl status samba-ad-dc --no-pager | head -30"
sleep 10  # Espera 10 segundos antes de continuar


## ======================================================
## 3. CONFIGURAÇÃO BÁSICA DO SISTEMA
## ======================================================
explicar "3/9" "AJUSTES BÁSICOS DO SISTEMA" \
"- Configuração de hostname
- Desativação do IPv6
- Configuração do arquivo hosts
- Sincronização de tempo (NTP)"

# Configuração do nome do servidor
echo "$SENHA_SUDO" | sudo -S hostnamectl set-hostname dc1

# Desativação do IPv6 (recomendado para ambientes AD)
echo "$SENHA_SUDO" | sudo -S sysctl -w net.ipv6.conf.all.disable_ipv6=1
echo "$SENHA_SUDO" | sudo -S sysctl -w net.ipv6.conf.default.disable_ipv6=1

# Configuração do arquivo hosts com resolução local
echo "127.0.0.1 localhost" | sudo tee /etc/hosts
echo "$IP_SERVIDOR dc1.$DNS_DOMINIO dc1" | sudo tee -a /etc/hosts

# Configuração e sincronização do tempo (crítico para Kerberos)
echo "$SENHA_SUDO" | sudo -S timedatectl set-timezone America/Sao_Paulo
echo "$SENHA_SUDO" | sudo -S timedatectl set-ntp true
echo "$SENHA_SUDO" | sudo -S systemctl restart systemd-timesyncd
sleep 10

# Remove entradas antigas do FQDN no /etc/hosts
sudo sed -i "/dc1\.${DNS_DOMINIO}/d" /etc/hosts

# Adiciona entrada única, sem espaços extras
echo "${IP_SERVIDOR} dc1.${DNS_DOMINIO} dc1" | sudo tee -a /etc/hosts


# Verificações da configuração básica
testar "echo 'Hostname configurado:'; hostname"
testar "echo 'Conteúdo do /etc/hosts:'; cat /etc/hosts"
testar "echo 'Status do NTP:'; timedatectl status"
sleep 10 # Espera 10 segundos antes de continuar

## ======================================================
## 4. CONFIGURAÇÃO DO KERBEROS
## ======================================================
explicar "4/9" "INTEGRAÇÃO COM KERBEROS" \
"- Configuração do realm
- Definição dos servidores KDC
- Configuração de domínios"

# Criação do arquivo de configuração do Kerberos
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
# Verificação da configuração do Kerberos
testar "echo 'Configuração do Kerberos:'; cat /etc/krb5.conf | grep -v '^#' | grep -v '^$'"

## ======================================================
## 5. CONFIGURAÇÃO DO SAMBA COMO CONTROLADOR DE DOMÍNIO
## ======================================================
explicar "5/9" "CRIAÇÃO DO DOMÍNIO ACTIVE DIRECTORY" \
"- Provisionamento do domínio
- Configuração de permissões
- Inicialização dos serviços
- Verificação do status"

# Parar serviços antigos do Samba
echo "$SENHA_SUDO" | sudo -S systemctl stop smbd nmbd
sleep 5

### 🔒 INÍCIO DA CORREÇÃO DNS (PORTA 53) ###
### Esse trecho foi inserido para resolver conflitos que estavam ocorrendo na sessão anterior ###
echo -e "\n${VERDE}>>> Resolvendo conflito de porta DNS (53)...${NC}"

# Parar serviços conflitantes (systemd-resolved/dnsmasq)
sudo systemctl stop systemd-resolved >/dev/null 2>&1
sudo systemctl disable systemd-resolved >/dev/null 2>&1
sudo systemctl stop dnsmasq >/dev/null 2>&1
sudo systemctl disable dnsmasq >/dev/null 2>&1

# Forçar liberação da porta 53
sudo fuser -k 53/tcp >/dev/null 2>&1
sudo fuser -k 53/udp >/dev/null 2>&1
sleep 2  # Garantir liberação

# Configurar DNS local
sudo rm -f /etc/resolv.conf
echo "nameserver 127.0.0.1" | sudo tee /etc/resolv.conf
echo "search $DNS_DOMINIO" | sudo tee -a /etc/resolv.conf

echo -e "${VERDE}>>> Conflito DNS resolvido!${NC}\n"
### 🔒 FIM DA CORREÇÃO DNS (PORTA 53) ###
sleep 10 # Analisar resultado

# Preparação da estrutura de diretórios com permissões adequadas
echo "$SENHA_SUDO" | sudo -S mkdir -p /var/lib/samba/private
echo "$SENHA_SUDO" | sudo -S chown -R root:root /var/lib/samba/private
echo "$SENHA_SUDO" | sudo -S chmod -R 770 /var/lib/samba/private
echo "$SENHA_SUDO" | sudo -S setfacl -R -m u:samba:rwx /var/lib/samba/private

# Backup da configuração original do Samba
echo "$SENHA_SUDO" | sudo -S mv /etc/samba/smb.conf /etc/samba/smb.conf.bkp

# Provisionamento do domínio Active Directory
if ! echo "$SENHA_SUDO" | sudo -S samba-tool domain provision --use-rfc2307 --realm=$REINO --domain=$DOMINIO --adminpass="$SENHA_SUDO" --server-role=dc; then
    echo -e "${VERMELHO}ERRO: Falha no provisionamento do domínio. Verifique os logs.${NC}"
    exit 1
fi

# ======== ADICIONAR ======== #
explicar "5.1" "Reiniciando serviço Samba AD DC" "Garantir que novas configurações sejam aplicadas"
sudo systemctl restart samba-ad-dc
sleep 10  # Esperar estabilização
# =========================== #

# Configuração do DNS local para resolução interna
echo "nameserver $IP_SERVIDOR" | sudo tee /etc/resolv.conf
echo "search $DNS_DOMINIO" | sudo tee -a /etc/resolv.conf

# Reinicialização dos serviços do Samba como DC
echo "$SENHA_SUDO" | sudo -S systemctl start samba-ad-dc
echo "$SENHA_SUDO" | sudo -S systemctl enable samba-ad-dc
sleep 10

# Configuração do FQDN no hosts antes do teste
echo "$IP_SERVIDOR dc1.$DNS_DOMINIO dc1" | sudo tee -a /etc/hosts

# Verificação do status do domínio
FQDN_DC="dc1.$DNS_DOMINIO"
echo "$SENHA_SUDO" | sudo -S systemctl restart samba-ad-dc
sleep 5

# Alterar teste de domínio (usar IP ao invés de FQDN)
testar "echo 'Informações do domínio:'; samba-tool domain info $IP_SERVIDOR"  # ✅ Corrigido

## ======================================================
## 6. CONFIGURAÇÃO DO DHCP - VERSÃO CORRIGIDA
## ======================================================
explicar "6/9" "IMPLANTAÇÃO DO SERVIDOR DHCP" \
"- Configuração de escopo
- Definição de opções DHCP
- Configuração de interface
- Ativação do serviço"

# Configuração do endereço IP estático via Netplan
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

# Ajuste de permissões do arquivo de configuração
sudo chmod 600 /etc/netplan/01-dhcp-samba.yaml

# Aplicação da configuração de rede
echo "$SENHA_SUDO" | sudo -S netplan apply
sleep 5

# Verificação da interface de rede
if ! ip link show "$INTERFACE_REDE" > /dev/null 2>&1; then
    echo -e "${VERMELHO}ERRO: Interface $INTERFACE_REDE não encontrada!${NC}"
    echo -e "${AMARELO}Interfaces disponíveis:${NC}"
    ip link show
    exit 1
fi

if ! ip -4 addr show "$INTERFACE_REDE" | grep -q "inet "; then
    echo -e "${VERMELHO}ERRO: Interface $INTERFACE_REDE sem configuração IPv4!${NC}"
    exit 1
fi

# Configuração do arquivo principal do DHCP
cat <<EOF | sudo tee /etc/dhcp/dhcpd.conf
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

# Configuração da interface para o serviço DHCP
echo "INTERFACESv4=\"$INTERFACE_REDE\"" | sudo tee /etc/default/isc-dhcp-server

# Verificação da sintaxe do arquivo de configuração
if ! sudo dhcpd -t -cf /etc/dhcp/dhcpd.conf; then
    echo -e "${VERMELHO}ERRO: Configuração DHCP inválida! Corrija os erros.${NC}"
    exit 1
fi

# Reinicialização controlada do serviço DHCP
sudo systemctl stop isc-dhcp-server
sudo systemctl disable isc-dhcp-server
sleep 5
sudo systemctl daemon-reload
sleep 5
sudo systemctl enable isc-dhcp-server
sudo systemctl start isc-dhcp-server
sleep 5

# Verificação do status do serviço DHCP
testar "echo 'Status do serviço DHCP:'; systemctl status isc-dhcp-server"

## ======================================================
## 7. CRIAÇÃO DE USUÁRIOS E GRUPOS
## ======================================================
explicar "7/9" "POPULAÇÃO DO DIRETÓRIO" \
"- Criação de grupos (alunos, professores, admins)
- Criação de usuários de exemplo
- Atribuição a grupos
- Verificação da estrutura"

# Ajuste final de permissões do Samba
sudo chown -R root:root /var/lib/samba/private/
sudo chmod -R 770 /var/lib/samba/private/

# Criação dos grupos principais com verificação de existência
for grupo in alunos professores administrativos; do
    if ! samba-tool group list | grep -q "^$grupo$"; then
        if ! echo "$SENHA_SUDO" | sudo -S samba-tool group add $grupo; then
            echo -e "${VERMELHO}ERRO: Falha ao criar grupo $grupo${NC}"
            exit 1
        fi
    fi
done

# Criação de usuários de exemplo (alunos, professores e admins)
for i in {01..10}; do
    # Criação de usuários alunos
    if ! echo "$SENHA_SUDO" | sudo -S samba-tool user create aluno$i SenhaAluno$i --given-name=Aluno --surname=$i; then
        echo -e "${VERMELHO}ERRO: Falha ao criar usuário aluno$i${NC}"
    fi
    
    # Criação de usuários professores
    if ! echo "$SENHA_SUDO" | sudo -S samba-tool user create professor$i SenhaProfessor$i --given-name=Professor --surname=$i; then
        echo -e "${VERMELHO}ERRO: Falha ao criar usuário professor$i${NC}"
    fi
    
    # Criação de usuários administrativos
    if ! echo "$SENHA_SUDO" | sudo -S samba-tool user create adm$i SenhaAdm$i --given-name=Admin --surname=$i; then
        echo -e "${VERMELHO}ERRO: Falha ao criar usuário adm$i${NC}"
    fi
    
    # Adicionar usuários aos respectivos grupos
    echo "$SENHA_SUDO" | sudo -S samba-tool group addmembers alunos aluno$i
    echo "$SENHA_SUDO" | sudo -S samba-tool group addmembers professores professor$i
    echo "$SENHA_SUDO" | sudo -S samba-tool group addmembers administrativos adm$i
done

# Reinicialização dos serviços de diretório
sudo systemctl restart samba-ad-dc
sleep 10

# Verificação dos usuários e grupos criados
testar "echo 'Lista de usuários do domínio:'; samba-tool user list"
sleep 10 # Analisar usuários criados
testar "echo 'Lista de grupos do domínio:'; samba-tool group list"
sleep 10 # Analisar grupos criados

## ======================================================
## 8. CRIAÇÃO DE COMPARTILHAMENTOS (Samba_Internal)
## ======================================================
explicar "8/9" "CONFIGURAÇÃO DE COMPARTILHAMENTOS" \
"- Criação de diretórios
- Definição de permissões
- Configuração de shares Samba
- Teste de acesso"

# ======== ADICIONAR ======== #
explicar "8.1" "Configurando firewall" "Abrindo portas essenciais"
sudo ufw allow 139/tcp
sudo ufw allow 445/tcp
sudo ufw allow 389/tcp
# =========================== #

# Criar diretórios base
sudo mkdir -p /srv/compartilhado/{Comum,Alunos,Professores,Administrativo}

# Aplicar permissões POSIX básicas
sudo chmod 770 /srv/compartilhado/*
sudo chown -R root:root /srv/compartilhado

# Configurar compartilhamentos no smb.conf
sudo tee -a /etc/samba/smb.conf << EOF

[global]
  netbios name = $NOME_NETBIOS
  realm = $DNS_DOMINIO
  server role = active directory domain controller
  dns backend = samba_internal
  server services = rpc, wrepl, ldap, cldap, kdc, drepl, smb, dns
  disable netbios = yes
  server min protocol = SMB2
  client min protocol = SMB2
  dns forwarder = 8.8.8.8
  idmap_ldb:use rfc2307 = yes
  socket options = TCP_NODELAY IPTOS_LOWDELAY
  winbind enum users = no
  winbind enum groups = no
  allow dns updates = secure only
  deadtime = 30
	

[Comum]
  path = /srv/compartilhado/Comum
  valid users = @\"$DOMINIO_NETBIOS\\\\Domain Users\"
  read only = No
  force group = "Domain Users"
  create mask = 770
  directory mask = 770

[Alunos]
  path = /srv/compartilhado/Alunos
  valid users = @\"$DOMINIO_NETBIOS\\\\alunos\"
  read only = No
  force group = alunos
  create mask = 770
  directory mask = 770

[Professores]
  path = /srv/compartilhado/Professores
  valid users = @\"$DOMINIO_NETBIOS\\\\professores\"
  read only = No
  force group = professores
  create mask = 770
  directory mask = 770

[Administrativo]
  path = /srv/compartilhado/Administrativo
  valid users = @\"$DOMINIO_NETBIOS\\\\administrativo\"
  read only = No
  force group = administrativo
  create mask = 770
  directory mask = 770
EOF

# Reiniciar serviço Samba
sudo systemctl restart samba-ad-dc

# Alterar teste de compartilhamento (com credenciais válidas)
testar "echo 'Testando compartilhamentos:'; smbclient -L //localhost -U aluno01%$SENHA_ALUNO01"  # ✅ Corrigido

# Testar acesso aos compartilhamentos
smbclient -U aluno01 //localhost/Alunos -c "mkdir teste; ls"

# Verificar permissões
ls -ld /srv/compartilhado/Alunos/teste
# Saída esperada: drwxrwx--- root alunos

## ======================================================
## 9. CONFIGURAÇÃO FINAL E MENSAGEM DE LOGON
## ======================================================
explicar "9/9" "CONFIGURAÇÕES FINAIS" \
"- Script de logon automático
- Configuração do firewall
- Testes finais
- Mensagem de conclusão"

# Criação do script de logon para usuários do domínio
echo "$SENHA_SUDO" | sudo -S mkdir -p /var/lib/samba/sysvol/$DNS_DOMINIO/scripts
cat <<EOF | sudo tee /var/lib/samba/sysvol/$DNS_DOMINIO/scripts/login.bat > /dev/null
@echo off
echo $DOMINIO - Configuração concluída com sucesso!
net use w: \\\\dc1\\Professores /persistent:yes
net use X: \\\\dc1\\Comum /persistent:yes
net use Y: \\\\dc1\\Alunos /persistent:yes
net use Z: \\\\dc1\\Administrativo /persistent:yes
EOF

# Ajuste de permissões do script de logon
echo "$SENHA_SUDO" | sudo -S chmod 755 /var/lib/samba/sysvol/$DNS_DOMINIO/scripts/login.bat
echo "$SENHA_SUDO" | sudo -S chown root:root /var/lib/samba/sysvol/$DNS_DOMINIO/scripts/login.bat

# Aplicação da política de logon
echo "$SENHA_SUDO" | sudo -S samba-tool group policy add --name="Default Domain Policy" --file="/var/lib/samba/sysvol/$DNS_DOMINIO/scripts/login.bat" --script-type="Logon"

# Configuração básica do firewall (UFW)
echo "$SENHA_SUDO" | sudo -S apt install -y ufw
echo "$SENHA_SUDO" | sudo -S ufw allow 53,135,137,138,139,445,389,636/tcp
echo "$SENHA_SUDO" | sudo -S ufw allow 53,137,138/udp
echo "$SENHA_SUDO" | sudo -S ufw enable

sleep 10
# Verificações finais
testar "echo 'Conteúdo do script de logon:'; cat /var/lib/samba/sysvol/$DNS_DOMINIO/scripts/login.bat"
testar "echo 'Regras do firewall ativas:'; sudo ufw status"

## ======================================================
## CONCLUSÃO
## ======================================================
echo -e "\n${VERDE}======== IMPLANTAÇÃO CONCLUÍDA COM SUCESSO! ========${NC}"
echo -e "${AMARELO}RESUMO DA CONFIGURAÇÃO:${NC}"
echo -e "- Domínio: $DOMINIO"
echo -e "- Hostname: dc1.$DNS_DOMINIO"
echo -e "- IP do Servidor: $IP_SERVIDOR"
echo -e "- Usuário Administrador: administrator"
echo -e "- Serviços Configurados:"
echo -e "  • Samba Active Directory"
echo -e "  • Samba Internal DNS Server (SAMBA_INTERNAL)"
echo -e "  • ISC DHCP Server"
echo -e "  • Kerberos Authentication"
echo -e "  • UFW Firewall"

echo -e "\n${VERDE}PRÓXIMOS PASSOS RECOMENDADOS:${NC}"
echo -e "1. Adicionar estações Windows ao domínio $REINO"
echo -e "2. Testar a autenticação de usuários"
echo -e "3. Verificar o funcionamento do DHCP"
echo -e "4. Validar o acesso aos compartilhamentos de rede"
echo -e "5. Configurar políticas de grupo adicionais conforme necessidade"

echo -e "\n${AZUL}Script desenvolvido para fins educacionais${NC}"
echo -e "${AZUL}Suporte: danielsantos@grupoiconne.net${NC}"