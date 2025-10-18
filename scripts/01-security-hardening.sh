#!/bin/bash
# KongoWara - Script de Sécurisation
# Ce script applique les mesures de sécurité critiques

set -e

echo "=========================================="
echo "  KongoWara - Sécurisation du VPS"
echo "=========================================="
echo ""

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

APP_DIR="/home/kongowara/kongowara-app"

# 1. Ajouter rate limiting au backend
echo -e "${YELLOW}[1/5] Installation de express-rate-limit...${NC}"

cat > $APP_DIR/backend/middleware/rateLimiter.js << 'EOF'
const rateLimit = require('express-rate-limit');

// Rate limiter pour les routes d'authentification
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // 5 tentatives max
  message: {
    error: 'Trop de tentatives de connexion. Veuillez réessayer dans 15 minutes.',
    retryAfter: '15 minutes'
  },
  standardHeaders: true,
  legacyHeaders: false,
});

// Rate limiter pour les routes API générales
const apiLimiter = rateLimit({
  windowMs: 1 * 60 * 1000, // 1 minute
  max: 100, // 100 requêtes max par minute
  message: {
    error: 'Trop de requêtes. Veuillez ralentir.',
    retryAfter: '1 minute'
  },
  standardHeaders: true,
  legacyHeaders: false,
});

// Rate limiter strict pour les opérations sensibles
const strictLimiter = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 heure
  max: 10, // 10 tentatives max par heure
  message: {
    error: 'Limite de requêtes atteinte. Réessayez plus tard.',
    retryAfter: '1 hour'
  },
  standardHeaders: true,
  legacyHeaders: false,
});

module.exports = {
  authLimiter,
  apiLimiter,
  strictLimiter
};
EOF

echo -e "${GREEN}✓ Rate limiter créé${NC}"

# 2. Configurer headers de sécurité Nginx
echo -e "${YELLOW}[2/5] Configuration des headers de sécurité Nginx...${NC}"

cat > /etc/nginx/snippets/security-headers.conf << 'EOF'
# Security Headers
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
add_header Permissions-Policy "geolocation=(), microphone=(), camera=()" always;
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

# Content Security Policy (ajuster selon vos besoins)
add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval' https://res.cloudinary.com; style-src 'self' 'unsafe-inline'; img-src 'self' data: https: http:; font-src 'self' data:; connect-src 'self' https://kongowara.com; frame-ancestors 'self';" always;

# Remove Server header
more_clear_headers 'Server';
more_clear_headers 'X-Powered-By';
EOF

echo -e "${GREEN}✓ Headers de sécurité configurés${NC}"

# 3. Mettre à jour la configuration Nginx principale
echo -e "${YELLOW}[3/5] Application des headers à la config Nginx...${NC}"

# Backup de la config actuelle
cp /etc/nginx/sites-available/kongowara.conf /etc/nginx/sites-available/kongowara.conf.backup-$(date +%Y%m%d)

# Ajouter l'include dans la config
sed -i '/server {/a \    include snippets/security-headers.conf;' /etc/nginx/sites-available/kongowara.conf

echo -e "${GREEN}✓ Configuration Nginx mise à jour${NC}"

# 4. Installer Fail2Ban pour protection brute force
echo -e "${YELLOW}[4/5] Installation de Fail2Ban...${NC}"

if ! command -v fail2ban-client &> /dev/null; then
    apt-get update
    apt-get install -y fail2ban
fi

# Configuration Fail2Ban pour SSH
cat > /etc/fail2ban/jail.local << 'EOF'
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 5
destemail = admin@kongowara.com
sendername = Fail2Ban-KongoWara
action = %(action_mwl)s

[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 7200

[nginx-http-auth]
enabled = true
filter = nginx-http-auth
port = http,https
logpath = /var/log/nginx/error.log
maxretry = 5

[nginx-noscript]
enabled = true
port = http,https
filter = nginx-noscript
logpath = /var/log/nginx/access.log
maxretry = 6

[nginx-badbots]
enabled = true
port = http,https
filter = nginx-badbots
logpath = /var/log/nginx/access.log
maxretry = 2
EOF

systemctl enable fail2ban
systemctl restart fail2ban

echo -e "${GREEN}✓ Fail2Ban configuré et activé${NC}"

# 5. Renforcer la configuration SSH
echo -e "${YELLOW}[5/5] Renforcement de la configuration SSH...${NC}"

# Backup SSH config
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup-$(date +%Y%m%d)

# Appliquer les bonnes pratiques SSH
cat >> /etc/ssh/sshd_config << 'EOF'

# KongoWara Security Settings
PermitRootLogin prohibit-password
PasswordAuthentication no
PubkeyAuthentication yes
ChallengeResponseAuthentication no
UsePAM yes
X11Forwarding no
PrintMotd no
AcceptEnv LANG LC_*
ClientAliveInterval 300
ClientAliveCountMax 2
MaxAuthTries 3
MaxSessions 5
EOF

# Redémarrer SSH
systemctl restart sshd

echo -e "${GREEN}✓ Configuration SSH renforcée${NC}"

echo ""
echo -e "${GREEN}=========================================="
echo "  Sécurisation terminée avec succès !"
echo "==========================================${NC}"
echo ""
echo "Actions effectuées :"
echo "  ✓ Rate limiting ajouté"
echo "  ✓ Headers de sécurité configurés"
echo "  ✓ Nginx mis à jour"
echo "  ✓ Fail2Ban installé et configuré"
echo "  ✓ SSH renforcé"
echo ""
echo -e "${YELLOW}Prochaines étapes :${NC}"
echo "  1. Tester Nginx : nginx -t"
echo "  2. Recharger Nginx : systemctl reload nginx"
echo "  3. Installer express-rate-limit : cd $APP_DIR/backend && npm install express-rate-limit"
echo "  4. Redémarrer le backend : docker compose restart backend"
echo ""
