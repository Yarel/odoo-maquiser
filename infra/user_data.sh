#!/bin/bash

# ---------------------------
# INSTALAR PAQUETES NECESARIOS
# ---------------------------
apt-get update -y
apt-get install -y docker.io docker-compose nginx ufw certbot python3-certbot-nginx make curl

systemctl enable docker
usermod -aG docker ubuntu

# ---------------------------
# CONFIGURAR FIREWALL
# ---------------------------
ufw allow OpenSSH
ufw allow 'Nginx Full'
ufw --force enable

# ---------------------------
# ESPERAR MANUAL UPDATE A NO-IP
# ---------------------------
echo "Esperando 60 segundos para que actualices el dominio en No-IP..."
sleep 60

# ---------------------------
# ESPERAR QUE EL DOMINIO APUNTE A LA IP PÚBLICA REAL
# ---------------------------
PUBLIC_IP=$(curl -s http://checkip.amazonaws.com)
while true; do
  DOMAIN_IP=$(dig +short maquiser.ddns.net | tail -n1)
  if [ "$DOMAIN_IP" == "$PUBLIC_IP" ]; then
    echo "✅ Dominio maquiser.ddns.net ya apunta a $PUBLIC_IP"
    break
  else
    echo "⏳ Esperando que maquiser.ddns.net apunte a $PUBLIC_IP. Actualmente apunta a: $DOMAIN_IP"
    sleep 30
  fi
done

# ---------------------------
# CONFIGURAR NGINX
# ---------------------------
cat > /etc/nginx/sites-available/odoo_ssl <<EOF
server {
    listen 80;
    server_name maquiser.ddns.net;

    location / {
        proxy_pass http://localhost:8069;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

ln -s /etc/nginx/sites-available/odoo_ssl /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx

# ---------------------------
# INSTALAR SSL CON CERTBOT
# ---------------------------
certbot --nginx --non-interactive --agree-tos -m yarelbalcazar@gmail.com -d maquiser.ddns.net

systemctl reload nginx
