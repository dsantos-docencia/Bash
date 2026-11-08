#!/bin/bash

# 1. Parar serviços conflitantes
sudo systemctl stop systemd-resolved
sudo systemctl disable systemd-resolved
sudo systemctl stop dnsmasq 2>/dev/null
sudo systemctl disable dnsmasq 2>/dev/null

# 2. Corrigir configuração DNS
sudo rm /etc/resolv.conf
echo "nameserver 127.0.0.1" | sudo tee /etc/resolv.conf

# 3. Forçar liberação da porta 53
sudo fuser -k 53/tcp
sudo fuser -k 53/udp

# 4. Reiniciar Samba
sudo systemctl restart samba-ad-dc

# 5. Verificar status
echo "✅ Status do Samba:"
sudo systemctl status samba-ad-dc --no-pager