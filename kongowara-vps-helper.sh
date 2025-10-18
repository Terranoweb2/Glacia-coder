#!/bin/bash
# KongoWara VPS Helper Script
# Ce script facilite les opérations courantes sur le VPS KongoWara

VPS_HOST="root@72.60.213.98"
APP_DIR="/home/kongowara/kongowara-app"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Helper function
ssh_exec() {
    ssh -o StrictHostKeyChecking=no "$VPS_HOST" "$@"
}

# Menu functions
show_menu() {
    echo -e "${GREEN}====================================${NC}"
    echo -e "${GREEN}   KongoWara VPS Helper Menu${NC}"
    echo -e "${GREEN}====================================${NC}"
    echo "1.  Statut des services Docker"
    echo "2.  Redémarrer tous les services"
    echo "3.  Redémarrer le backend"
    echo "4.  Redémarrer le frontend"
    echo "5.  Redémarrer le frontend mobile 📱"
    echo "6.  Redémarrer PostgreSQL"
    echo "7.  Voir les logs du backend"
    echo "8.  Voir les logs du frontend"
    echo "9.  Voir les logs mobile 📱"
    echo "10. Tester la santé de l'API"
    echo "11. Tester la version mobile 📱"
    echo "12. Se connecter au VPS (SSH)"
    echo "13. Vérifier la base de données"
    echo "14. Lister les tables de la DB"
    echo "15. Backup de la base de données"
    echo "16. Déployer les dernières modifications"
    echo "17. Déployer la version mobile 📱"
    echo "18. Nettoyer Docker (volumes, images)"
    echo "0.  Quitter"
    echo -e "${GREEN}====================================${NC}"
}

# 1. Check Docker services status
check_status() {
    echo -e "${YELLOW}Vérification du statut des services...${NC}"
    ssh_exec "cd $APP_DIR && docker compose ps"
}

# 2. Restart all services
restart_all() {
    echo -e "${YELLOW}Redémarrage de tous les services...${NC}"
    ssh_exec "cd $APP_DIR && docker compose restart"
    echo -e "${GREEN}Services redémarrés!${NC}"
}

# 3. Restart backend
restart_backend() {
    echo -e "${YELLOW}Redémarrage du backend...${NC}"
    ssh_exec "cd $APP_DIR && docker compose restart backend"
    echo -e "${GREEN}Backend redémarré!${NC}"
}

# 4. Restart frontend
restart_frontend() {
    echo -e "${YELLOW}Redémarrage du frontend...${NC}"
    ssh_exec "cd $APP_DIR && docker compose restart frontend"
    echo -e "${GREEN}Frontend redémarré!${NC}"
}

# 5. Restart mobile
restart_mobile() {
    echo -e "${YELLOW}Redémarrage du frontend mobile...${NC}"
    ssh_exec "cd $APP_DIR && docker compose restart frontend-mobile"
    echo -e "${GREEN}Frontend mobile redémarré!${NC}"
}

# 6. Restart PostgreSQL
restart_postgres() {
    echo -e "${YELLOW}Redémarrage de PostgreSQL...${NC}"
    ssh_exec "cd $APP_DIR && docker compose restart postgres"
    echo -e "${GREEN}PostgreSQL redémarré!${NC}"
}

# 7. Backend logs
backend_logs() {
    echo -e "${YELLOW}Logs du backend (30 dernières lignes):${NC}"
    ssh_exec "docker logs kongowara-backend --tail 30"
}

# 8. Frontend logs
frontend_logs() {
    echo -e "${YELLOW}Logs du frontend (30 dernières lignes):${NC}"
    ssh_exec "docker logs kongowara-frontend --tail 30"
}

# 9. Mobile logs
mobile_logs() {
    echo -e "${YELLOW}Logs du mobile (30 dernières lignes):${NC}"
    ssh_exec "docker logs kongowara-mobile --tail 30"
}

# 10. Health check
health_check() {
    echo -e "${YELLOW}Vérification de la santé de l'API...${NC}"
    ssh_exec "curl -s http://localhost:5000/health | jq ."
    echo ""
    echo -e "${YELLOW}API publique:${NC}"
    ssh_exec "curl -s https://kongowara.com/health | jq ."
}

# 11. Test mobile version
test_mobile() {
    echo -e "${YELLOW}Test de la version mobile...${NC}"
    ssh_exec "curl -s http://localhost:3001 | head -20"
    echo ""
    echo -e "${YELLOW}📱 URL mobile: http://72.60.213.98:3001${NC}"
}

# 9. SSH connection
ssh_connect() {
    echo -e "${YELLOW}Connexion SSH au VPS...${NC}"
    ssh -o StrictHostKeyChecking=no "$VPS_HOST"
}

# 10. Check database
check_database() {
    echo -e "${YELLOW}Vérification de PostgreSQL...${NC}"
    ssh_exec "docker exec kongowara-postgres psql -U kongowara_user -d kongowara_db -c 'SELECT version();'"
}

# 11. List database tables
list_tables() {
    echo -e "${YELLOW}Tables de la base de données:${NC}"
    ssh_exec "docker exec kongowara-postgres psql -U kongowara_user -d kongowara_db -c '\dt'"
}

# 12. Backup database
backup_database() {
    BACKUP_FILE="kongowara_backup_$(date +%Y%m%d_%H%M%S).sql"
    echo -e "${YELLOW}Création d'un backup de la base de données...${NC}"
    ssh_exec "docker exec kongowara-postgres pg_dump -U kongowara_user kongowara_db > /tmp/$BACKUP_FILE"
    echo -e "${GREEN}Backup créé: /tmp/$BACKUP_FILE${NC}"
    echo -e "${YELLOW}Téléchargement du backup...${NC}"
    scp "$VPS_HOST:/tmp/$BACKUP_FILE" "./$BACKUP_FILE"
    echo -e "${GREEN}Backup téléchargé: ./$BACKUP_FILE${NC}"
}

# 16. Deploy updates
deploy_updates() {
    echo -e "${YELLOW}Déploiement des dernières modifications...${NC}"
    ssh_exec "cd $APP_DIR && ./deploy-app.sh"
}

# 17. Deploy mobile
deploy_mobile() {
    echo -e "${YELLOW}Déploiement de la version mobile...${NC}"
    ssh_exec "cd $APP_DIR && ./deploy-mobile.sh"
}

# 18. Clean Docker
clean_docker() {
    echo -e "${RED}Attention: Cette opération va supprimer les volumes et images inutilisés!${NC}"
    read -p "Êtes-vous sûr? (y/N): " confirm
    if [[ $confirm == [yY] ]]; then
        echo -e "${YELLOW}Nettoyage de Docker...${NC}"
        ssh_exec "docker system prune -af --volumes"
        echo -e "${GREEN}Docker nettoyé!${NC}"
    else
        echo -e "${YELLOW}Opération annulée.${NC}"
    fi
}

# Main loop
main() {
    while true; do
        show_menu
        read -p "Choisissez une option: " choice

        case $choice in
            1) check_status ;;
            2) restart_all ;;
            3) restart_backend ;;
            4) restart_frontend ;;
            5) restart_mobile ;;
            6) restart_postgres ;;
            7) backend_logs ;;
            8) frontend_logs ;;
            9) mobile_logs ;;
            10) health_check ;;
            11) test_mobile ;;
            12) ssh_connect ;;
            13) check_database ;;
            14) list_tables ;;
            15) backup_database ;;
            16) deploy_updates ;;
            17) deploy_mobile ;;
            18) clean_docker ;;
            0) echo -e "${GREEN}Au revoir!${NC}"; exit 0 ;;
            *) echo -e "${RED}Option invalide!${NC}" ;;
        esac

        echo ""
        read -p "Appuyez sur Entrée pour continuer..."
        clear
    done
}

# Check if running in interactive mode
if [ -t 0 ]; then
    clear
    main
else
    # Allow direct command execution
    case "${1:-menu}" in
        status) check_status ;;
        restart) restart_all ;;
        backend) restart_backend ;;
        frontend) restart_frontend ;;
        mobile) restart_mobile ;;
        postgres) restart_postgres ;;
        logs-backend) backend_logs ;;
        logs-frontend) frontend_logs ;;
        logs-mobile) mobile_logs ;;
        health) health_check ;;
        test-mobile) test_mobile ;;
        ssh) ssh_connect ;;
        db) check_database ;;
        tables) list_tables ;;
        backup) backup_database ;;
        deploy) deploy_updates ;;
        deploy-mobile) deploy_mobile ;;
        clean) clean_docker ;;
        menu|*) main ;;
    esac
fi
