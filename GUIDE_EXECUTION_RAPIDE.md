# KongoWara - Guide d'Exécution Rapide

## 🚀 Installation en 5 Minutes

### Étape 1 : Préparer les Scripts (Sur Windows)

```powershell
# Ouvrir PowerShell ou CMD
cd C:\Users\HP

# Vérifier que les scripts existent
dir scripts\*.sh

# Vous devriez voir :
# - 01-security-hardening.sh
# - 02-setup-backups.sh
# - 03-fix-health-check.sh
# - 04-setup-ssl-mobile.sh
# - deploy-all-improvements.sh
```

### Étape 2 : Uploader vers le VPS

```powershell
# Option A : Avec SCP (si disponible)
scp C:\Users\HP\scripts\*.sh root@72.60.213.98:/root/kongowara-scripts/

# Option B : Manuellement via WinSCP ou FileZilla
# 1. Télécharger WinSCP : https://winscp.net/
# 2. Se connecter à 72.60.213.98 avec root
# 3. Uploader le dossier C:\Users\HP\scripts vers /root/kongowara-scripts/
```

### Étape 3 : Se Connecter au VPS

```bash
ssh root@72.60.213.98
```

### Étape 4 : Configurer les Permissions

```bash
# Aller dans le dossier des scripts
cd /root/kongowara-scripts

# Rendre tous les scripts exécutables
chmod +x *.sh

# Vérifier
ls -la *.sh
```

### Étape 5 : Lancer l'Installation Complète

```bash
# Lancer le script maître
./deploy-all-improvements.sh

# Suivre les instructions à l'écran
# Choisir "A" pour TOUT installer
```

---

## 📋 Alternative : Installation Script par Script

Si vous préférez contrôler chaque étape :

### Script 1 : Sécurité (10 minutes)

```bash
cd /root/kongowara-scripts
./01-security-hardening.sh

# Ce script va :
# - Installer Fail2Ban
# - Configurer rate limiting
# - Ajouter headers de sécurité
# - Renforcer SSH

# Après exécution :
nginx -t
systemctl reload nginx
cd /home/kongowara/kongowara-app/backend
npm install express-rate-limit
cd /root/kongowara-scripts
docker compose -f /home/kongowara/kongowara-app/docker-compose.yml restart backend
```

### Script 2 : Backups (5 minutes)

```bash
./02-setup-backups.sh

# Quand demandé "Exécuter un backup test?" → répondre "o"

# Vérifier que ça marche :
ls -lh /root/backups/kongowara/database/
```

### Script 3 : Health Check (3 minutes)

```bash
./03-fix-health-check.sh

# Quand demandé "Appliquer ces modifications?" → répondre "o"

# Attendre 60 secondes puis vérifier :
docker compose -f /home/kongowara/kongowara-app ps
```

### Script 4 : SSL Mobile (5 minutes)

**⚠️ IMPORTANT : Configurer le DNS d'abord !**

#### 4.1 Configurer le DNS (Sur votre registrar)

```
Type: A
Nom: mobile
Valeur: 72.60.213.98
TTL: 3600
```

#### 4.2 Vérifier la propagation DNS

```bash
# Attendre 5-30 minutes après configuration DNS

# Tester depuis le VPS
host mobile.kongowara.com

# Devrait retourner : mobile.kongowara.com has address 72.60.213.98
```

#### 4.3 Lancer le script SSL

```bash
./04-setup-ssl-mobile.sh

# Le script va :
# - Vérifier le DNS
# - Installer Certbot
# - Créer config Nginx
# - Obtenir certificat SSL
# - Configurer HTTPS

# Vérifier :
curl -I https://mobile.kongowara.com
```

---

## 🎯 Vérifications Post-Installation

### Vérifier la Sécurité

```bash
# Fail2Ban actif ?
systemctl status fail2ban

# Firewall actif ?
ufw status

# Headers de sécurité ?
curl -I https://kongowara.com | grep -E "X-Frame|X-Content|CSP"
```

### Vérifier les Backups

```bash
# Cron job créé ?
crontab -l | grep backup

# Fichiers de backup créés ?
ls -lh /root/backups/kongowara/database/

# Tester manuellement :
/root/backup-kongowara.sh
```

### Vérifier les Services

```bash
# Tous les services healthy ?
docker compose -f /home/kongowara/kongowara-app/docker-compose.yml ps

# Health check backend
docker inspect --format='{{json .State.Health}}' kongowara-backend | jq

# API fonctionne ?
curl https://kongowara.com/health
```

### Vérifier le SSL

```bash
# Certificat installé ?
certbot certificates

# HTTPS mobile fonctionne ?
curl -I https://mobile.kongowara.com

# Test SSL Labs (dans navigateur)
# https://www.ssllabs.com/ssltest/analyze.html?d=mobile.kongowara.com
```

---

## 🛠️ Commandes Utiles

### Gestion des Services

```bash
# Statut global
docker compose -f /home/kongowara/kongowara-app/docker-compose.yml ps

# Redémarrer un service
docker compose -f /home/kongowara/kongowara-app/docker-compose.yml restart backend

# Voir les logs
docker logs kongowara-backend --tail 50 -f

# Rebuild un service
docker compose -f /home/kongowara/kongowara-app/docker-compose.yml build frontend
docker compose -f /home/kongowara/kongowara-app/docker-compose.yml up -d frontend
```

### Gestion des Backups

```bash
# Backup manuel
/root/backup-kongowara.sh

# Lister les backups
ls -lh /root/backups/kongowara/database/

# Restaurer (ATTENTION : écrase la DB actuelle !)
/root/restore-kongowara.sh

# Voir les logs de backup
tail -f /root/backups/kongowara/logs/backup_*.log
```

### Gestion SSL

```bash
# Voir tous les certificats
certbot certificates

# Renouveler manuellement
certbot renew

# Test de renouvellement (sans vraiment renouveler)
certbot renew --dry-run

# Révoquer un certificat
certbot revoke --cert-path /etc/letsencrypt/live/mobile.kongowara.com/cert.pem
```

### Sécurité

```bash
# Statut Fail2Ban
fail2ban-client status

# Bannir une IP manuellement
fail2ban-client set sshd banip 1.2.3.4

# Débannir une IP
fail2ban-client set sshd unbanip 1.2.3.4

# Voir les IPs bannies
fail2ban-client status sshd

# Logs Fail2Ban
tail -f /var/log/fail2ban.log
```

---

## 🚨 En Cas de Problème

### Problème 1 : Script ne s'exécute pas

```bash
# Vérifier permissions
ls -l *.sh

# Corriger
chmod +x *.sh

# Si édité sur Windows, corriger fins de ligne
sed -i 's/\r$//' *.sh
```

### Problème 2 : Erreur pendant l'installation

```bash
# Voir les logs détaillés
cat /var/log/kongowara-deployment/deployment_*.log

# Rollback si nécessaire
# Restaurer docker-compose.yml
ls /home/kongowara/kongowara-app/docker-compose.yml.backup-*
cp /home/kongowara/kongowara-app/docker-compose.yml.backup-YYYYMMDD \
   /home/kongowara/kongowara-app/docker-compose.yml
docker compose -f /home/kongowara/kongowara-app/docker-compose.yml restart
```

### Problème 3 : Services unhealthy après fix

```bash
# Vérifier que curl est dans l'image
docker exec kongowara-backend curl --version

# Si manquant, ajouter dans backend/Dockerfile:
RUN apk add --no-cache curl

# Puis rebuild
cd /home/kongowara/kongowara-app
docker compose build backend
docker compose up -d backend
```

### Problème 4 : SSL échoue

```bash
# Vérifier DNS
host mobile.kongowara.com

# Vérifier port 80
netstat -tulpn | grep :80

# Vérifier Nginx
nginx -t
systemctl status nginx

# Logs Certbot
tail -f /var/log/letsencrypt/letsencrypt.log

# Retry manuel
certbot certonly --nginx -d mobile.kongowara.com
```

---

## 📊 Tableau de Bord Final

Après installation complète, votre tableau de bord devrait être :

```
╔══════════════════════════════════════════════════════════╗
║              KONGOWARA STATUS DASHBOARD                  ║
╚══════════════════════════════════════════════════════════╝

🟢 SERVICES
  ✓ Backend API      : https://kongowara.com/health
  ✓ Frontend Desktop : https://kongowara.com
  ✓ Frontend Mobile  : https://mobile.kongowara.com
  ✓ PostgreSQL       : Healthy
  ✓ Redis            : Healthy

🔒 SÉCURITÉ
  ✓ Fail2Ban         : Active
  ✓ Firewall UFW     : Active
  ✓ SSL/TLS          : A+ (SSL Labs)
  ✓ Headers          : Configurés
  ✓ Rate Limiting    : Actif

💾 BACKUPS
  ✓ Automatique      : Quotidien 2h AM
  ✓ Rétention        : 7 jours
  ✓ Dernier backup   : [DATE]
  ✓ Taille DB        : [SIZE]

📈 PERFORMANCE
  ✓ Uptime           : 99.9%
  ✓ Response Time    : < 200ms
  ✓ First Load JS    : 81 KB

🎯 PROCHAINES ÉTAPES
  [ ] Monitoring (Prometheus/Grafana)
  [ ] Tests automatisés
  [ ] CI/CD GitHub Actions
  [ ] Documentation API Swagger
  [ ] Page Admin

╚══════════════════════════════════════════════════════════╝
```

---

## ✅ Checklist Finale

### Installation
- [ ] Scripts uploadés sur le VPS
- [ ] Permissions configurées (`chmod +x`)
- [ ] Script maître exécuté
- [ ] Aucune erreur dans les logs

### Sécurité
- [ ] Fail2Ban installé et actif
- [ ] Headers de sécurité configurés
- [ ] Rate limiting ajouté à l'API
- [ ] SSH renforcé
- [ ] UFW actif

### Backups
- [ ] Script de backup créé
- [ ] Cron job configuré
- [ ] Backup test effectué
- [ ] Script de restauration créé

### Services
- [ ] Tous les containers healthy
- [ ] Health checks corrigés
- [ ] API répond correctement
- [ ] Frontend accessible

### SSL
- [ ] DNS configuré pour mobile
- [ ] Certificat SSL obtenu
- [ ] HTTPS actif
- [ ] Redirection HTTP→HTTPS
- [ ] Renouvellement automatique configuré

---

## 🎓 Ressources

### Documentation
- `KONGOWARA_ANALYSE_ET_PROPOSITIONS.md` - Analyse complète
- `scripts/README.md` - Documentation scripts détaillée
- `KONGOWARA_NEXT_STEPS_GUIDE.md` - Prochaines étapes

### Logs Importants
- `/var/log/kongowara-deployment/` - Logs déploiement
- `/root/backups/kongowara/logs/` - Logs backups
- `/var/log/nginx/` - Logs Nginx
- `/var/log/fail2ban.log` - Logs sécurité

### Commandes Essentielles
```bash
# Statut global
docker compose -f /home/kongowara/kongowara-app/docker-compose.yml ps

# Backup manuel
/root/backup-kongowara.sh

# Voir les logs
docker logs kongowara-backend -f

# Redémarrer services
docker compose -f /home/kongowara/kongowara-app/docker-compose.yml restart
```

---

**🎉 Félicitations ! Votre installation KongoWara est maintenant sécurisée, sauvegardée et optimisée !**

**Questions ? Consultez la documentation ou les logs.**

---

**Version :** 1.0.0
**Date :** 2025-10-18
**Temps total estimé :** 30-45 minutes
