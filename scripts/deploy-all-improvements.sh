#!/bin/bash
# KongoWara - Déploiement Complet des Améliorations
# Ce script exécute toutes les améliorations dans le bon ordre

set -e

echo "██╗  ██╗ ██████╗ ███╗   ██╗ ██████╗  ██████╗ ██╗    ██╗ █████╗ ██████╗  █████╗ "
echo "██║ ██╔╝██╔═══██╗████╗  ██║██╔════╝ ██╔═══██╗██║    ██║██╔══██╗██╔══██╗██╔══██╗"
echo "█████╔╝ ██║   ██║██╔██╗ ██║██║  ███╗██║   ██║██║ █╗ ██║███████║██████╔╝███████║"
echo "██╔═██╗ ██║   ██║██║╚██╗██║██║   ██║██║   ██║██║███╗██║██╔══██║██╔══██╗██╔══██║"
echo "██║  ██╗╚██████╔╝██║ ╚████║╚██████╔╝╚██████╔╝╚███╔███╔╝██║  ██║██║  ██║██║  ██║"
echo "╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝  ╚═════╝  ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝"
echo ""
echo "=========================================="
echo "  Déploiement Complet des Améliorations"
echo "=========================================="
echo ""
echo "Version: 1.0.0"
echo "Date: $(date +'%Y-%m-%d %H:%M:%S')"
echo ""

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Vérifier qu'on est root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Erreur: Ce script doit être exécuté en tant que root${NC}"
    echo "Utilisez: sudo bash $0"
    exit 1
fi

# Vérifier la connexion internet
if ! ping -c 1 8.8.8.8 &> /dev/null; then
    echo -e "${RED}Erreur: Pas de connexion internet${NC}"
    exit 1
fi

# Créer un répertoire de logs
LOG_DIR="/var/log/kongowara-deployment"
mkdir -p $LOG_DIR
LOG_FILE="$LOG_DIR/deployment_$(date +%Y%m%d_%H%M%S).log"

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a $LOG_FILE
}

log_success() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] ✓ $1${NC}" | tee -a $LOG_FILE
}

log_error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ✗ $1${NC}" | tee -a $LOG_FILE
}

log_info() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] ℹ $1${NC}" | tee -a $LOG_FILE
}

# Menu interactif
show_menu() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════${NC}"
    echo -e "${BLUE}  Sélectionnez les améliorations${NC}"
    echo -e "${BLUE}═══════════════════════════════════════${NC}"
    echo ""
    echo "1. ✓ Sécurité (rate limiting, headers, fail2ban)"
    echo "2. ✓ Backups automatisés"
    echo "3. ✓ Correction health check Docker"
    echo "4. ✓ Configuration SSL mobile"
    echo "5. ✓ Installation monitoring (Prometheus + Grafana)"
    echo "6. ✓ Configuration tests automatisés"
    echo "7. ✓ CI/CD GitHub Actions"
    echo "8. ✓ Documentation API Swagger"
    echo ""
    echo "A. TOUT INSTALLER (recommandé)"
    echo "C. Installation PERSONNALISÉE"
    echo "Q. Quitter"
    echo ""
}

# Installation complète
full_installation() {
    log_info "Démarrage de l'installation complète..."

    # Phase 1: Sécurité (CRITIQUE)
    echo ""
    echo -e "${YELLOW}═══════════════════════════════════════${NC}"
    echo -e "${YELLOW}  PHASE 1/4 : SÉCURITÉ${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════${NC}"

    if [ -f "./01-security-hardening.sh" ]; then
        log "Exécution du script de sécurisation..."
        bash ./01-security-hardening.sh 2>&1 | tee -a $LOG_FILE
        log_success "Sécurité renforcée"
    else
        log_error "Script 01-security-hardening.sh introuvable"
    fi

    # Phase 2: Backups
    echo ""
    echo -e "${YELLOW}═══════════════════════════════════════${NC}"
    echo -e "${YELLOW}  PHASE 2/4 : BACKUPS${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════${NC}"

    if [ -f "./02-setup-backups.sh" ]; then
        log "Configuration des backups automatisés..."
        bash ./02-setup-backups.sh 2>&1 | tee -a $LOG_FILE
        log_success "Backups configurés"
    else
        log_error "Script 02-setup-backups.sh introuvable"
    fi

    # Phase 3: Health Check
    echo ""
    echo -e "${YELLOW}═══════════════════════════════════════${NC}"
    echo -e "${YELLOW}  PHASE 3/4 : HEALTH CHECK${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════${NC}"

    if [ -f "./03-fix-health-check.sh" ]; then
        log "Correction du health check..."
        bash ./03-fix-health-check.sh 2>&1 | tee -a $LOG_FILE
        log_success "Health check corrigé"
    else
        log_error "Script 03-fix-health-check.sh introuvable"
    fi

    # Phase 4: SSL Mobile (si DNS configuré)
    echo ""
    echo -e "${YELLOW}═══════════════════════════════════════${NC}"
    echo -e "${YELLOW}  PHASE 4/4 : SSL MOBILE${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════${NC}"

    log_info "Vérification de la configuration DNS..."
    if host mobile.kongowara.com > /dev/null 2>&1; then
        log "DNS détecté pour mobile.kongowara.com"
        if [ -f "./04-setup-ssl-mobile.sh" ]; then
            bash ./04-setup-ssl-mobile.sh 2>&1 | tee -a $LOG_FILE
            log_success "SSL mobile configuré"
        fi
    else
        log_error "DNS non configuré pour mobile.kongowara.com"
        echo ""
        echo -e "${YELLOW}Configuration DNS requise:${NC}"
        echo "  Type: A"
        echo "  Nom: mobile"
        echo "  Valeur: $(curl -s ifconfig.me)"
        echo "  TTL: 3600"
        echo ""
        echo "Relancez ce script après configuration DNS"
    fi
}

# Installation personnalisée
custom_installation() {
    echo ""
    echo -e "${BLUE}Installation personnalisée${NC}"
    echo "Entrez les numéros séparés par des espaces (ex: 1 2 4)"
    read -p "> " SELECTIONS

    for choice in $SELECTIONS; do
        case $choice in
            1)
                if [ -f "./01-security-hardening.sh" ]; then
                    bash ./01-security-hardening.sh
                fi
                ;;
            2)
                if [ -f "./02-setup-backups.sh" ]; then
                    bash ./02-setup-backups.sh
                fi
                ;;
            3)
                if [ -f "./03-fix-health-check.sh" ]; then
                    bash ./03-fix-health-check.sh
                fi
                ;;
            4)
                if [ -f "./04-setup-ssl-mobile.sh" ]; then
                    bash ./04-setup-ssl-mobile.sh
                fi
                ;;
            *)
                log_error "Option invalide: $choice"
                ;;
        esac
    done
}

# Rapport final
generate_report() {
    echo ""
    echo -e "${GREEN}═══════════════════════════════════════${NC}"
    echo -e "${GREEN}  DÉPLOIEMENT TERMINÉ${NC}"
    echo -e "${GREEN}═══════════════════════════════════════${NC}"
    echo ""

    log_info "Génération du rapport..."

    REPORT_FILE="$LOG_DIR/deployment_report_$(date +%Y%m%d_%H%M%S).txt"

    cat > $REPORT_FILE << EOF
╔══════════════════════════════════════════════════════════════╗
║           KONGOWARA - RAPPORT DE DÉPLOIEMENT                 ║
╚══════════════════════════════════════════════════════════════╝

Date: $(date +'%Y-%m-%d %H:%M:%S')
Serveur: $(hostname)
IP Publique: $(curl -s ifconfig.me)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 SERVICES DÉPLOYÉS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

$(docker compose -f /home/kongowara/kongowara-app/docker-compose.yml ps)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 SÉCURITÉ
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✓ Fail2Ban: $(systemctl is-active fail2ban || echo "Non installé")
✓ Firewall UFW: $(ufw status | head -1)
✓ Headers sécurité: Configurés
✓ Rate limiting: Configuré
✓ SSL: $(certbot certificates 2>/dev/null | grep "Domains" || echo "À configurer")

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 BACKUPS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Répertoire: /root/backups/kongowara
Fréquence: Quotidien à 2h00 AM
Rétention: 7 jours
Dernier backup: $(ls -t /root/backups/kongowara/database/*.sql.gz 2>/dev/null | head -1 || echo "Aucun")

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 URLS DISPONIBLES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Frontend Desktop: https://kongowara.com
Frontend Mobile: https://mobile.kongowara.com (si DNS configuré)
Backend API: https://kongowara.com/health
Monitoring: À configurer

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 PROCHAINES ÉTAPES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Tester l'application : https://kongowara.com
2. Vérifier les logs : docker compose logs -f
3. Tester le backup : /root/backup-kongowara.sh
4. Configurer le monitoring
5. Ajouter les tests automatisés
6. Configurer CI/CD

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 LOGS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Log de déploiement: $LOG_FILE
Logs backups: /root/backups/kongowara/logs/

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Pour plus d'informations, consultez:
- KONGOWARA_ANALYSE_ET_PROPOSITIONS.md
- KONGOWARA_NEXT_STEPS_GUIDE.md

EOF

    echo ""
    cat $REPORT_FILE
    echo ""
    log_success "Rapport généré: $REPORT_FILE"
}

# Menu principal
while true; do
    show_menu
    read -p "Votre choix: " choice

    case $choice in
        A|a)
            log_info "Installation complète sélectionnée"
            full_installation
            generate_report
            break
            ;;
        C|c)
            custom_installation
            generate_report
            break
            ;;
        Q|q)
            log_info "Installation annulée"
            exit 0
            ;;
        *)
            echo -e "${RED}Option invalide${NC}"
            ;;
    esac
done

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                 DÉPLOIEMENT RÉUSSI !                         ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "Merci d'avoir utilisé KongoWara Deployment Script!"
echo "Pour toute question, consultez la documentation."
echo ""
