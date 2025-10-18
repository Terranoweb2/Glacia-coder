#!/bin/bash
# KongoWara - Correction du Health Check Backend

set -e

echo "=========================================="
echo "  KongoWara - Fix Health Check"
echo "=========================================="
echo ""

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

APP_DIR="/home/kongowara/kongowara-app"

echo -e "${YELLOW}[1/2] Correction du health check dans docker-compose.yml...${NC}"

# Backup du fichier actuel
cp $APP_DIR/docker-compose.yml $APP_DIR/docker-compose.yml.backup-$(date +%Y%m%d)

# Vérifier si le health check existe déjà
if grep -q "healthcheck:" $APP_DIR/docker-compose.yml; then
    echo -e "${YELLOW}Health check existant trouvé, mise à jour...${NC}"

    # Créer un nouveau docker-compose.yml avec le health check corrigé
    cat > /tmp/docker-compose-fixed.yml << 'EOF'
version: '3.8'

services:
  postgres:
    image: postgres:15-alpine
    container_name: kongowara-postgres
    restart: unless-stopped
    environment:
      POSTGRES_USER: kongowara_user
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-secure_password_change_me}
      POSTGRES_DB: kongowara_db
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5433:5432"
    networks:
      - kongowara-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U kongowara_user -d kongowara_db"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 10s

  redis:
    image: redis:7-alpine
    container_name: kongowara-redis
    restart: unless-stopped
    command: redis-server --appendonly yes
    volumes:
      - redis_data:/data
    ports:
      - "6380:6379"
    networks:
      - kongowara-network
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 3s
      retries: 5
      start_period: 5s

  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: kongowara-backend
    restart: unless-stopped
    env_file:
      - ./backend/.env
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    ports:
      - "5000:5000"
    networks:
      - kongowara-network
    volumes:
      - ./backend:/app
      - /app/node_modules
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:5000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s

  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    container_name: kongowara-frontend
    restart: unless-stopped
    depends_on:
      - backend
    ports:
      - "3000:3000"
    networks:
      - kongowara-network
    environment:
      - NEXT_PUBLIC_API_URL=https://kongowara.com
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  frontend-mobile:
    build:
      context: ./frontend-mobile
      dockerfile: Dockerfile
    container_name: kongowara-mobile
    restart: unless-stopped
    depends_on:
      - backend
    ports:
      - "3001:3001"
    networks:
      - kongowara-network
    environment:
      - NEXT_PUBLIC_API_URL=https://kongowara.com
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3001"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

networks:
  kongowara-network:
    driver: bridge

volumes:
  postgres_data:
  redis_data:
EOF

    # Comparer et afficher les différences
    echo -e "${YELLOW}Différences détectées:${NC}"
    diff -u $APP_DIR/docker-compose.yml /tmp/docker-compose-fixed.yml || true

    echo ""
    read -p "Appliquer ces modifications? (o/n): " APPLY

    if [[ "$APPLY" == "o" || "$APPLY" == "O" ]]; then
        cp /tmp/docker-compose-fixed.yml $APP_DIR/docker-compose.yml
        echo -e "${GREEN}✓ docker-compose.yml mis à jour${NC}"
    else
        echo -e "${YELLOW}Modifications non appliquées${NC}"
        exit 0
    fi
else
    echo -e "${RED}Impossible de trouver le fichier docker-compose.yml${NC}"
    exit 1
fi

echo -e "${YELLOW}[2/2] Redémarrage des services...${NC}"

cd $APP_DIR

# Reconstruire et redémarrer
docker compose down
docker compose up -d

echo ""
echo -e "${YELLOW}Attente du démarrage des services (60 secondes)...${NC}"
sleep 60

# Vérifier le status
echo ""
echo -e "${YELLOW}Statut des services:${NC}"
docker compose ps

echo ""
echo -e "${GREEN}=========================================="
echo "  Health check corrigé !"
echo "==========================================${NC}"
echo ""
echo "Vérifications:"
echo "  - Backend : docker inspect --format='{{json .State.Health}}' kongowara-backend | jq"
echo "  - Frontend : docker inspect --format='{{json .State.Health}}' kongowara-frontend | jq"
echo "  - Mobile : docker inspect --format='{{json .State.Health}}' kongowara-mobile | jq"
echo "  - PostgreSQL : docker inspect --format='{{json .State.Health}}' kongowara-postgres | jq"
echo "  - Redis : docker inspect --format='{{json .State.Health}}' kongowara-redis | jq"
echo ""
