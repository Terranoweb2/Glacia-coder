#!/bin/bash
# KongoWara - Configuration des Backups Automatisés

set -e

echo "=========================================="
echo "  KongoWara - Backup Automatisé"
echo "=========================================="
echo ""

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

BACKUP_DIR="/root/backups/kongowara"
APP_DIR="/home/kongowara/kongowara-app"
BACKUP_RETENTION_DAYS=7

# Créer le répertoire de backup
echo -e "${YELLOW}[1/4] Création du répertoire de backup...${NC}"
mkdir -p $BACKUP_DIR/{database,application,nginx,logs}
echo -e "${GREEN}✓ Répertoire créé: $BACKUP_DIR${NC}"

# Créer le script de backup principal
echo -e "${YELLOW}[2/4] Création du script de backup...${NC}"

cat > /root/backup-kongowara.sh << 'BACKUP_SCRIPT'
#!/bin/bash
# KongoWara Automated Backup Script
# Exécuté quotidiennement par cron

set -e

# Configuration
BACKUP_DIR="/root/backups/kongowara"
APP_DIR="/home/kongowara/kongowara-app"
DATE=$(date +%Y%m%d_%H%M%S)
RETENTION_DAYS=7
LOG_FILE="$BACKUP_DIR/logs/backup_$DATE.log"

# Couleurs pour les logs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Fonction de logging
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a $LOG_FILE
}

log_success() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] ✓ $1${NC}" | tee -a $LOG_FILE
}

log_error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ✗ $1${NC}" | tee -a $LOG_FILE
}

log "=========================================="
log "Début du backup KongoWara"
log "=========================================="

# 1. Backup PostgreSQL
log "Backup de la base de données PostgreSQL..."
if docker exec kongowara-postgres pg_dump -U kongowara_user kongowara_db > $BACKUP_DIR/database/db_$DATE.sql; then
    gzip $BACKUP_DIR/database/db_$DATE.sql
    SIZE=$(du -h $BACKUP_DIR/database/db_$DATE.sql.gz | cut -f1)
    log_success "Base de données sauvegardée (Taille: $SIZE)"
else
    log_error "Échec du backup de la base de données"
    exit 1
fi

# 2. Backup de l'application
log "Backup des fichiers de l'application..."
if tar -czf $BACKUP_DIR/application/app_$DATE.tar.gz -C /home/kongowara kongowara-app --exclude='node_modules' --exclude='.next' --exclude='dist'; then
    SIZE=$(du -h $BACKUP_DIR/application/app_$DATE.tar.gz | cut -f1)
    log_success "Application sauvegardée (Taille: $SIZE)"
else
    log_error "Échec du backup de l'application"
fi

# 3. Backup configuration Nginx
log "Backup de la configuration Nginx..."
if tar -czf $BACKUP_DIR/nginx/nginx_$DATE.tar.gz /etc/nginx/sites-available /etc/nginx/snippets 2>/dev/null; then
    SIZE=$(du -h $BACKUP_DIR/nginx/nginx_$DATE.tar.gz | cut -f1)
    log_success "Configuration Nginx sauvegardée (Taille: $SIZE)"
else
    log_error "Échec du backup Nginx"
fi

# 4. Backup des certificats SSL
log "Backup des certificats SSL..."
if [ -d "/etc/letsencrypt" ]; then
    if tar -czf $BACKUP_DIR/nginx/ssl_$DATE.tar.gz /etc/letsencrypt 2>/dev/null; then
        SIZE=$(du -h $BACKUP_DIR/nginx/ssl_$DATE.tar.gz | cut -f1)
        log_success "Certificats SSL sauvegardés (Taille: $SIZE)"
    fi
else
    log "Pas de certificats SSL à sauvegarder"
fi

# 5. Nettoyer les anciens backups
log "Nettoyage des backups de plus de $RETENTION_DAYS jours..."
DELETED_COUNT=0

# Database
DELETED_COUNT=$((DELETED_COUNT + $(find $BACKUP_DIR/database -name "*.sql.gz" -mtime +$RETENTION_DAYS -delete -print | wc -l)))

# Application
DELETED_COUNT=$((DELETED_COUNT + $(find $BACKUP_DIR/application -name "*.tar.gz" -mtime +$RETENTION_DAYS -delete -print | wc -l)))

# Nginx
DELETED_COUNT=$((DELETED_COUNT + $(find $BACKUP_DIR/nginx -name "*.tar.gz" -mtime +$RETENTION_DAYS -delete -print | wc -l)))

# Logs
find $BACKUP_DIR/logs -name "*.log" -mtime +30 -delete

log_success "Nettoyage terminé ($DELETED_COUNT fichiers supprimés)"

# 6. Statistiques finales
log "=========================================="
log "Statistiques du backup"
log "=========================================="
log "Espace disque utilisé par les backups:"
du -sh $BACKUP_DIR/* | tee -a $LOG_FILE
log ""
log "Espace disque disponible:"
df -h / | grep -v Filesystem | tee -a $LOG_FILE

# 7. Optionnel: Upload vers cloud (décommenter si configuré)
# log "Upload vers cloud storage..."
# rclone copy $BACKUP_DIR remote:kongowara-backups/

log "=========================================="
log_success "Backup terminé avec succès!"
log "=========================================="

# Envoyer notification (optionnel)
# curl -X POST "https://api.telegram.org/bot<TOKEN>/sendMessage" \
#     -d "chat_id=<CHAT_ID>" \
#     -d "text=✅ Backup KongoWara complété avec succès - $DATE"

BACKUP_SCRIPT

chmod +x /root/backup-kongowara.sh
echo -e "${GREEN}✓ Script de backup créé${NC}"

# Configurer le cron job
echo -e "${YELLOW}[3/4] Configuration du cron job...${NC}"

# Créer une entrée cron pour backup quotidien à 2h du matin
CRON_JOB="0 2 * * * /root/backup-kongowara.sh >> $BACKUP_DIR/logs/cron.log 2>&1"

# Vérifier si le cron existe déjà
if ! crontab -l 2>/dev/null | grep -q "backup-kongowara.sh"; then
    (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
    echo -e "${GREEN}✓ Cron job configuré (Quotidien à 2h00 AM)${NC}"
else
    echo -e "${YELLOW}! Cron job déjà existant${NC}"
fi

# Créer un script de restauration
echo -e "${YELLOW}[4/4] Création du script de restauration...${NC}"

cat > /root/restore-kongowara.sh << 'RESTORE_SCRIPT'
#!/bin/bash
# KongoWara Restore Script

set -e

BACKUP_DIR="/root/backups/kongowara"
APP_DIR="/home/kongowara/kongowara-app"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}=========================================="
echo "  KongoWara - Restauration de Backup"
echo "==========================================${NC}"
echo ""

# Lister les backups disponibles
echo "Backups de base de données disponibles:"
ls -lth $BACKUP_DIR/database/*.sql.gz | head -5

echo ""
read -p "Entrez le nom du fichier à restaurer (ex: db_20251018_020000.sql.gz): " BACKUP_FILE

if [ ! -f "$BACKUP_DIR/database/$BACKUP_FILE" ]; then
    echo -e "${RED}Erreur: Fichier introuvable${NC}"
    exit 1
fi

echo -e "${RED}ATTENTION: Cette opération va REMPLACER la base de données actuelle!${NC}"
read -p "Êtes-vous sûr? (tapez 'oui' pour confiruer): " CONFIRM

if [ "$CONFIRM" != "oui" ]; then
    echo "Opération annulée"
    exit 0
fi

echo -e "${YELLOW}Restauration en cours...${NC}"

# Décompresser
gunzip -c $BACKUP_DIR/database/$BACKUP_FILE > /tmp/restore.sql

# Arrêter le backend temporairement
docker compose -f $APP_DIR/docker-compose.yml stop backend

# Restaurer la base de données
docker exec -i kongowara-postgres psql -U kongowara_user -d kongowara_db < /tmp/restore.sql

# Redémarrer le backend
docker compose -f $APP_DIR/docker-compose.yml start backend

# Nettoyer
rm /tmp/restore.sql

echo -e "${GREEN}✓ Restauration terminée avec succès!${NC}"
RESTORE_SCRIPT

chmod +x /root/restore-kongowara.sh
echo -e "${GREEN}✓ Script de restauration créé${NC}"

# Tester le backup immédiatement
echo ""
echo -e "${YELLOW}Voulez-vous exécuter un backup test maintenant? (o/n)${NC}"
read -p "> " RUN_TEST

if [[ "$RUN_TEST" == "o" || "$RUN_TEST" == "O" ]]; then
    echo -e "${YELLOW}Exécution du backup test...${NC}"
    /root/backup-kongowara.sh
fi

echo ""
echo -e "${GREEN}=========================================="
echo "  Configuration des backups terminée !"
echo "==========================================${NC}"
echo ""
echo "Résumé :"
echo "  ✓ Répertoire de backup : $BACKUP_DIR"
echo "  ✓ Script principal : /root/backup-kongowara.sh"
echo "  ✓ Script de restauration : /root/restore-kongowara.sh"
echo "  ✓ Cron job : Quotidien à 2h00 AM"
echo "  ✓ Rétention : $BACKUP_RETENTION_DAYS jours"
echo ""
echo "Commandes utiles :"
echo "  - Backup manuel : /root/backup-kongowara.sh"
echo "  - Restaurer : /root/restore-kongowara.sh"
echo "  - Voir les backups : ls -lh $BACKUP_DIR/database/"
echo "  - Logs : tail -f $BACKUP_DIR/logs/backup_*.log"
echo ""
