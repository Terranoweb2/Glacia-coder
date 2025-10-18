# KongoWara - Scripts d'Amélioration

Ce dossier contient tous les scripts nécessaires pour améliorer et sécuriser votre installation KongoWara.

## 📋 Liste des Scripts

### Scripts d'Installation

| Script | Description | Durée | Priorité |
|--------|-------------|-------|----------|
| `deploy-all-improvements.sh` | **Script maître** - Orchestre tout | 15-30 min | ⭐⭐⭐ |
| `01-security-hardening.sh` | Sécurisation complète du VPS | 5-10 min | 🔴 CRITIQUE |
| `02-setup-backups.sh` | Configuration backups automatisés | 5 min | 🔴 CRITIQUE |
| `03-fix-health-check.sh` | Correction health check Docker | 3 min | 🟡 Important |
| `04-setup-ssl-mobile.sh` | Configuration SSL pour mobile | 5 min | 🟡 Important |

### Scripts Additionnels

| Script | Description |
|--------|-------------|
| `05-install-monitoring.sh` | Prometheus + Grafana (à créer) |
| `06-setup-tests.sh` | Tests automatisés (à créer) |
| `07-setup-cicd.sh` | CI/CD GitHub Actions (à créer) |
| `08-swagger-api.sh` | Documentation API (à créer) |

---

## 🚀 Démarrage Rapide

### Option 1 : Installation Complète (Recommandé)

```bash
# 1. Se connecter au VPS
ssh root@72.60.213.98

# 2. Créer le dossier de scripts
mkdir -p /root/kongowara-scripts
cd /root/kongowara-scripts

# 3. Uploader les scripts depuis Windows
# (Exécuter depuis Windows PowerShell/CMD)
scp C:\Users\HP\scripts\*.sh root@72.60.213.98:/root/kongowara-scripts/

# 4. Sur le VPS, rendre les scripts exécutables
chmod +x *.sh

# 5. Lancer l'installation complète
./deploy-all-improvements.sh
```

### Option 2 : Installation Script par Script

```bash
# Sécurité (FAIRE EN PREMIER)
./01-security-hardening.sh

# Backups
./02-setup-backups.sh

# Health Check
./03-fix-health-check.sh

# SSL Mobile (après configuration DNS)
./04-setup-ssl-mobile.sh
```

---

## 📝 Prérequis

### Avant de Commencer

- [x] Accès SSH au VPS (root@72.60.213.98)
- [x] Docker et Docker Compose installés
- [x] Application KongoWara déployée
- [ ] **DNS configuré pour mobile.kongowara.com** (pour le SSL)

### Configuration DNS Requise (pour SSL mobile)

Connectez-vous à votre registrar et ajoutez :

```
Type: A
Nom: mobile
Valeur: 72.60.213.98
TTL: 3600
```

Vérification :
```bash
# Attendre 5-30 min puis tester
ping mobile.kongowara.com
# Devrait retourner 72.60.213.98
```

---

## 🔧 Détails des Scripts

### 1. Security Hardening (`01-security-hardening.sh`)

**Ce que fait ce script :**
- ✅ Installe et configure **Fail2Ban** (protection brute force)
- ✅ Configure **rate limiting** sur l'API (max 5 tentatives login/15min)
- ✅ Ajoute **headers de sécurité** Nginx (CSP, XSS-Protection, etc.)
- ✅ Renforce **configuration SSH** (désactive password auth)
- ✅ Configure **firewall UFW**

**Après exécution :**
```bash
# Vérifier Fail2Ban
fail2ban-client status sshd

# Vérifier headers
curl -I https://kongowara.com

# Vérifier UFW
ufw status
```

### 2. Setup Backups (`02-setup-backups.sh`)

**Ce que fait ce script :**
- ✅ Crée `/root/backups/kongowara/`
- ✅ Configure backup quotidien PostgreSQL (2h AM)
- ✅ Backup application + config Nginx
- ✅ Rétention 7 jours automatique
- ✅ Crée script de restauration

**Commandes utiles :**
```bash
# Backup manuel
/root/backup-kongowara.sh

# Voir les backups
ls -lh /root/backups/kongowara/database/

# Restaurer
/root/restore-kongowara.sh

# Logs
tail -f /root/backups/kongowara/logs/backup_*.log
```

### 3. Fix Health Check (`03-fix-health-check.sh`)

**Ce que fait ce script :**
- ✅ Corrige `docker-compose.yml` avec health checks appropriés
- ✅ Configure `start_period` pour éviter faux positifs
- ✅ Teste les services après redémarrage

**Vérification :**
```bash
# Voir le statut de santé
docker compose ps

# Inspecter un container
docker inspect --format='{{json .State.Health}}' kongowara-backend | jq
```

### 4. Setup SSL Mobile (`04-setup-ssl-mobile.sh`)

**Ce que fait ce script :**
- ✅ Vérifie résolution DNS
- ✅ Installe Certbot si nécessaire
- ✅ Crée config Nginx pour mobile
- ✅ Obtient certificat Let's Encrypt
- ✅ Configure HTTPS avec redirection HTTP→HTTPS
- ✅ Configure renouvellement automatique

**Vérification :**
```bash
# Tester HTTPS
curl -I https://mobile.kongowara.com

# Voir les certificats
certbot certificates

# Tester le renouvellement
certbot renew --dry-run

# SSL Labs test
# Ouvrir: https://www.ssllabs.com/ssltest/analyze.html?d=mobile.kongowara.com
```

---

## 🎯 Ordre d'Exécution Recommandé

### Phase 1 : Critique (À faire AUJOURD'HUI)
1. ✅ `01-security-hardening.sh` - **PRIORITÉ ABSOLUE**
2. ✅ `02-setup-backups.sh` - Protection données

### Phase 2 : Important (Cette semaine)
3. ✅ Configurer DNS pour mobile.kongowara.com
4. ✅ `04-setup-ssl-mobile.sh` - Activer HTTPS mobile
5. ✅ `03-fix-health-check.sh` - Monitoring fiable

### Phase 3 : Améliorations (Ce mois)
6. ⏳ Monitoring (Prometheus/Grafana)
7. ⏳ Tests automatisés
8. ⏳ CI/CD
9. ⏳ Documentation API

---

## 🆘 Dépannage

### Problème : Script ne s'exécute pas

```bash
# Vérifier les permissions
ls -l *.sh

# Rendre exécutable
chmod +x nom-du-script.sh

# Vérifier les fins de ligne (si édité sur Windows)
dos2unix nom-du-script.sh
```

### Problème : Erreur "command not found"

```bash
# Installer les dépendances manquantes
apt-get update
apt-get install -y curl jq certbot nginx
```

### Problème : Certificat SSL échoue

```bash
# Vérifier DNS
host mobile.kongowara.com

# Vérifier port 80 ouvert
netstat -tulpn | grep :80

# Vérifier Nginx
nginx -t
systemctl status nginx

# Logs Certbot
tail -f /var/log/letsencrypt/letsencrypt.log
```

### Problème : Health check toujours unhealthy

```bash
# Vérifier que curl est installé dans le container
docker exec kongowara-backend curl --version

# Si manquant, ajouter dans Dockerfile:
RUN apk add --no-cache curl
# Puis rebuild:
docker compose build backend
docker compose up -d backend
```

---

## 📊 Vérifications Post-Installation

### Checklist de Sécurité

```bash
# ✓ Fail2Ban actif
systemctl status fail2ban

# ✓ SSH sécurisé
grep "PermitRootLogin" /etc/ssh/sshd_config
# Devrait afficher: prohibit-password

# ✓ Firewall actif
ufw status
# Devrait afficher: Status: active

# ✓ Headers de sécurité
curl -I https://kongowara.com | grep -E "X-Frame|X-Content|CSP"

# ✓ Rate limiting
# Tester 6 tentatives de login rapides, la 6ème devrait être bloquée
```

### Checklist Backups

```bash
# ✓ Répertoire existe
ls -la /root/backups/kongowara/

# ✓ Cron configuré
crontab -l | grep backup

# ✓ Test backup
/root/backup-kongowara.sh

# ✓ Vérifier fichiers créés
ls -lh /root/backups/kongowara/database/
```

### Checklist SSL

```bash
# ✓ Certificat installé
certbot certificates

# ✓ HTTPS fonctionne
curl -I https://mobile.kongowara.com

# ✓ Redirection HTTP→HTTPS
curl -I http://mobile.kongowara.com
# Devrait montrer: 301 Moved Permanently

# ✓ Renouvellement automatique
crontab -l | grep certbot
```

---

## 📈 Monitoring et Logs

### Logs Importants

```bash
# Logs de déploiement
/var/log/kongowara-deployment/

# Logs backups
/root/backups/kongowara/logs/

# Logs Nginx
/var/log/nginx/

# Logs Docker
docker compose logs -f

# Logs Fail2Ban
tail -f /var/log/fail2ban.log
```

### Commandes de Monitoring

```bash
# État des services Docker
docker compose ps

# Utilisation disque
df -h

# Utilisation mémoire
free -h

# Processus
htop

# Connexions réseau
netstat -tulpn
```

---

## 🔄 Mises à Jour

### Mettre à jour les scripts

```bash
# Depuis Windows, uploader les nouveaux scripts
scp C:\Users\HP\scripts\*.sh root@72.60.213.98:/root/kongowara-scripts/

# Sur le VPS
cd /root/kongowara-scripts
chmod +x *.sh
```

### Mettre à jour les certificats SSL

```bash
# Renouvellement manuel
certbot renew

# Test sans réellement renouveler
certbot renew --dry-run
```

---

## 📞 Support

### En cas de problème

1. **Vérifier les logs** : Toujours commencer par les logs
2. **Consulter la documentation** : `KONGOWARA_ANALYSE_ET_PROPOSITIONS.md`
3. **Restaurer un backup** : Si problème critique
4. **Contacter le support** : admin@kongowara.com

### Rollback en cas d'échec

Tous les scripts créent des backups avant modification :

```bash
# Restaurer docker-compose.yml
cp /home/kongowara/kongowara-app/docker-compose.yml.backup-YYYYMMDD \
   /home/kongowara/kongowara-app/docker-compose.yml

# Restaurer config Nginx
cp /etc/nginx/sites-available/kongowara.conf.backup-YYYYMMDD \
   /etc/nginx/sites-available/kongowara.conf

# Redémarrer services
docker compose restart
systemctl reload nginx
```

---

## 🎓 Ressources

### Documentation Complète

- [KONGOWARA_ANALYSE_ET_PROPOSITIONS.md](../KONGOWARA_ANALYSE_ET_PROPOSITIONS.md)
- [KONGOWARA_NEXT_STEPS_GUIDE.md](../KONGOWARA_NEXT_STEPS_GUIDE.md)
- [DNS_CONFIGURATION_GUIDE.md](../DNS_CONFIGURATION_GUIDE.md)

### Outils Externes

- [SSL Labs Test](https://www.ssllabs.com/ssltest/)
- [Security Headers](https://securityheaders.com/)
- [Let's Encrypt](https://letsencrypt.org/docs/)

---

## ✅ Checklist Complète

### Avant Installation
- [ ] SSH fonctionne
- [ ] Docker installé
- [ ] Application déployée
- [ ] Backup manuel effectué

### Installation
- [ ] Scripts uploadés
- [ ] Permissions configurées
- [ ] DNS configuré (pour SSL)
- [ ] Installation exécutée

### Vérification
- [ ] Services Docker healthy
- [ ] HTTPS fonctionne
- [ ] Backups créés
- [ ] Fail2Ban actif
- [ ] Headers sécurité présents

### Maintenance
- [ ] Monitoring configuré
- [ ] Alertes configurées
- [ ] Documentation à jour
- [ ] Équipe formée

---

**Version :** 1.0.0
**Date :** 2025-10-18
**Auteur :** Claude Code
**Projet :** KongoWara Platform

---

**🎉 Bonne installation ! Si vous avez des questions, consultez la documentation ou les logs.**
