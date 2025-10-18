#!/bin/bash
# KongoWara - Configuration SSL pour Mobile

set -e

echo "=========================================="
echo "  KongoWara - SSL Mobile Setup"
echo "=========================================="
echo ""

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

DOMAIN="mobile.kongowara.com"

# Vérifier la résolution DNS
echo -e "${YELLOW}[1/4] Vérification de la résolution DNS...${NC}"
echo "Vérification de $DOMAIN..."

if host $DOMAIN > /dev/null 2>&1; then
    IP=$(host $DOMAIN | grep "has address" | awk '{print $4}')
    echo -e "${GREEN}✓ DNS résolu: $DOMAIN -> $IP${NC}"

    # Vérifier que c'est la bonne IP
    SERVER_IP=$(curl -s ifconfig.me)
    if [ "$IP" != "$SERVER_IP" ]; then
        echo -e "${RED}⚠ ATTENTION: Le DNS pointe vers $IP mais ce serveur est $SERVER_IP${NC}"
        read -p "Continuer quand même? (o/n): " CONTINUE
        if [[ "$CONTINUE" != "o" ]]; then
            exit 1
        fi
    fi
else
    echo -e "${RED}✗ Erreur: DNS non résolu pour $DOMAIN${NC}"
    echo ""
    echo "Actions à faire:"
    echo "  1. Connectez-vous à votre registrar de domaine"
    echo "  2. Ajoutez un enregistrement DNS de type A:"
    echo "     Type: A"
    echo "     Nom: mobile"
    echo "     Valeur: $(curl -s ifconfig.me)"
    echo "     TTL: 3600"
    echo "  3. Attendez 5-30 minutes pour la propagation"
    echo "  4. Relancez ce script"
    echo ""
    exit 1
fi

# Vérifier que certbot est installé
echo -e "${YELLOW}[2/4] Vérification de Certbot...${NC}"
if ! command -v certbot &> /dev/null; then
    echo "Installation de Certbot..."
    apt-get update
    apt-get install -y certbot python3-certbot-nginx
    echo -e "${GREEN}✓ Certbot installé${NC}"
else
    echo -e "${GREEN}✓ Certbot déjà installé${NC}"
fi

# Créer la configuration Nginx pour mobile (HTTP d'abord)
echo -e "${YELLOW}[3/4] Création de la configuration Nginx...${NC}"

cat > /etc/nginx/sites-available/mobile.kongowara.conf << 'NGINX_CONFIG'
upstream kongowara_mobile {
    server localhost:3001;
    keepalive 32;
}

server {
    listen 80;
    listen [::]:80;
    server_name mobile.kongowara.com;

    # Security headers
    include snippets/security-headers.conf;

    # Logs
    access_log /var/log/nginx/mobile.access.log;
    error_log /var/log/nginx/mobile.error.log;

    # Client body size limit
    client_max_body_size 10M;

    # Proxy settings
    location / {
        proxy_pass http://kongowara_mobile;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        proxy_read_timeout 90;
        proxy_connect_timeout 90;
        proxy_send_timeout 90;
    }

    # Next.js specific
    location /_next/static {
        proxy_pass http://kongowara_mobile;
        proxy_cache_valid 200 60m;
        add_header Cache-Control "public, immutable, max-age=31536000";
    }

    # Service Worker
    location /sw.js {
        proxy_pass http://kongowara_mobile;
        add_header Cache-Control "no-cache, no-store, must-revalidate";
        add_header Pragma "no-cache";
        add_header Expires "0";
    }

    # Manifest
    location /manifest.json {
        proxy_pass http://kongowara_mobile;
        add_header Cache-Control "public, max-age=3600";
    }

    # Health check
    location /health {
        proxy_pass http://kongowara_mobile;
        access_log off;
    }
}
NGINX_CONFIG

# Activer le site
ln -sf /etc/nginx/sites-available/mobile.kongowara.conf /etc/nginx/sites-enabled/

# Tester la configuration
if nginx -t; then
    echo -e "${GREEN}✓ Configuration Nginx valide${NC}"
    systemctl reload nginx
else
    echo -e "${RED}✗ Erreur dans la configuration Nginx${NC}"
    exit 1
fi

# Obtenir le certificat SSL
echo -e "${YELLOW}[4/4] Obtention du certificat SSL...${NC}"
echo "Cela peut prendre quelques secondes..."

if certbot certonly --nginx -d $DOMAIN --non-interactive --agree-tos --email admin@kongowara.com; then
    echo -e "${GREEN}✓ Certificat SSL obtenu avec succès!${NC}"

    # Mettre à jour la configuration Nginx pour HTTPS
    cat > /etc/nginx/sites-available/mobile.kongowara.conf << 'NGINX_HTTPS_CONFIG'
upstream kongowara_mobile {
    server localhost:3001;
    keepalive 32;
}

# HTTP -> HTTPS redirect
server {
    listen 80;
    listen [::]:80;
    server_name mobile.kongowara.com;

    location /.well-known/acme-challenge/ {
        root /var/www/html;
    }

    location / {
        return 301 https://$server_name$request_uri;
    }
}

# HTTPS server
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name mobile.kongowara.com;

    # SSL configuration
    ssl_certificate /etc/letsencrypt/live/mobile.kongowara.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/mobile.kongowara.com/privkey.pem;
    ssl_trusted_certificate /etc/letsencrypt/live/mobile.kongowara.com/chain.pem;

    # SSL settings
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384';
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    ssl_stapling on;
    ssl_stapling_verify on;

    # Security headers
    include snippets/security-headers.conf;

    # Logs
    access_log /var/log/nginx/mobile.access.log;
    error_log /var/log/nginx/mobile.error.log;

    # Client body size limit
    client_max_body_size 10M;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml+rss application/json application/javascript;

    # Proxy settings
    location / {
        proxy_pass http://kongowara_mobile;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        proxy_read_timeout 90;
        proxy_connect_timeout 90;
        proxy_send_timeout 90;
    }

    # Next.js specific
    location /_next/static {
        proxy_pass http://kongowara_mobile;
        proxy_cache_valid 200 60m;
        add_header Cache-Control "public, immutable, max-age=31536000";
    }

    # Service Worker
    location /sw.js {
        proxy_pass http://kongowara_mobile;
        add_header Cache-Control "no-cache, no-store, must-revalidate";
        add_header Pragma "no-cache";
        add_header Expires "0";
    }

    # Manifest
    location /manifest.json {
        proxy_pass http://kongowara_mobile;
        add_header Cache-Control "public, max-age=3600";
    }

    # Health check
    location /health {
        proxy_pass http://kongowara_mobile;
        access_log off;
    }
}
NGINX_HTTPS_CONFIG

    # Tester et recharger Nginx
    if nginx -t; then
        systemctl reload nginx
        echo -e "${GREEN}✓ Nginx rechargé avec HTTPS${NC}"
    else
        echo -e "${RED}✗ Erreur dans la configuration HTTPS${NC}"
        exit 1
    fi

    # Configurer le renouvellement automatique
    if ! crontab -l 2>/dev/null | grep -q "certbot renew"; then
        (crontab -l 2>/dev/null; echo "0 3 * * * certbot renew --quiet --post-hook 'systemctl reload nginx'") | crontab -
        echo -e "${GREEN}✓ Renouvellement automatique SSL configuré${NC}"
    fi

else
    echo -e "${RED}✗ Échec de l'obtention du certificat SSL${NC}"
    echo "Vérifiez que:"
    echo "  1. Le DNS est bien propagé"
    echo "  2. Le port 80 est ouvert"
    echo "  3. Nginx est en cours d'exécution"
    exit 1
fi

echo ""
echo -e "${GREEN}=========================================="
echo "  SSL Mobile configuré avec succès !"
echo "==========================================${NC}"
echo ""
echo "URLs disponibles:"
echo "  - HTTP: http://mobile.kongowara.com (redirige vers HTTPS)"
echo "  - HTTPS: https://mobile.kongowara.com ✓"
echo ""
echo "Tests à effectuer:"
echo "  - curl https://mobile.kongowara.com"
echo "  - SSL Labs: https://www.ssllabs.com/ssltest/analyze.html?d=mobile.kongowara.com"
echo ""
echo "Certificat:"
echo "  - Emplacement: /etc/letsencrypt/live/mobile.kongowara.com/"
echo "  - Renouvellement: Automatique tous les jours à 3h00"
echo "  - Test renouvellement: certbot renew --dry-run"
echo ""
