# 🚀 Glacia-Coder

**Plateforme de Génération d'Applications Web Powered by IA**

Glacia-Coder est une plateforme SaaS complète qui permet de générer des applications web fonctionnelles à partir de simples descriptions textuelles, similaire à Lovable.dev, Bolt.new ou v0.dev.

![Version](https://img.shields.io/badge/version-3.0.0--production--ready-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Node](https://img.shields.io/badge/node-%3E%3D20.0.0-brightgreen)
![Status](https://img.shields.io/badge/status-production-success)

## ✨ Fonctionnalités

### 🤖 Génération de Code IA
- **Claude API 3.5 Sonnet** (Anthropic) - Génération de code haute qualité
- Génération complète d'applications (React + TypeScript)
- Code production-ready avec best practices
- **Parsing JSON robuste** avec gestion des caractères de contrôle
- **Retry automatique** avec backoff exponentiel

### 💻 Éditeur de Code Intégré
- **Monaco Editor** (moteur de VS Code)
- Coloration syntaxique pour tous les langages
- Thèmes clair et sombre
- Auto-complétion et IntelliSense
- Édition en temps réel
- **Aperçu en direct** (Preview Panel)

### 📊 Dashboard Utilisateur
- Vue d'ensemble de tous les projets
- Statuts en temps réel (génération, complété, erreur)
- Statistiques d'utilisation
- **Gestion des quotas API** (10 générations/utilisateur)
- Historique des générations

### 🔐 Authentification Complète
- **Supabase Auth** intégré
- Inscription / Connexion sécurisée
- Protection HTTPS obligatoire
- Row Level Security (RLS)
- Gestion de profil

### 📦 Gestion de Projets
- Sauvegarde automatique dans PostgreSQL
- Stockage sécurisé du code généré (JSONB)
- Versioning des projets
- **Logs structurés** avec Winston

### 🗄️ Base de Données Supabase
- PostgreSQL avec Row Level Security
- Authentification Supabase Auth
- Trigger auto-création utilisateurs
- **13 conteneurs Docker** en production
- Backup automatique

## 🏗️ Architecture Technique

### Stack Backend
- **Runtime**: Node.js 20.x LTS
- **Framework**: Express.js (serveur natif, pas TypeScript)
- **Database**: PostgreSQL (Supabase)
- **Auth**: Supabase Auth
- **AI API**: Claude 3.5 Sonnet (Anthropic)
- **Logging**: Winston (JSON structuré)
- **Process Manager**: PM2
- **Middleware**: Rate Limiting, Quota Management, Error Handling

### Stack Frontend
- **Framework**: React 18 + Vite
- **Language**: TypeScript
- **Styling**: TailwindCSS
- **Editor**: Monaco Editor
- **State**: React Context + Hooks
- **Routing**: React Router v6
- **HTTP**: Fetch API + Supabase Client

### Infrastructure
- **OS**: Ubuntu 22.04 LTS
- **Web Server**: Nginx
- **SSL**: Let's Encrypt (Certbot)
- **Firewall**: UFW
- **Containers**: Docker + Docker Compose (Supabase)
- **Reverse Proxy**: Nginx
- **Domain**: glacia-code.sbs

## 📋 Prérequis

### Serveur VPS
- Ubuntu 22.04 LTS ou supérieur
- 4 GB RAM minimum (8 GB recommandé)
- 40 GB espace disque
- Accès root SSH
- IP: 72.60.213.98

### Clés API Requises
- **Anthropic API Key** (Claude) - [Obtenir ici](https://console.anthropic.com/)

### Domaine Configuré
- Domaine principal : `glacia-code.sbs`
- Supabase : `supabase.glacia-code.sbs`

## 🚀 Installation Rapide

### 1. Cloner le Repository

```bash
git clone https://github.com/Terranoweb2/Kongowara.git glacia-coder
cd glacia-coder
```

### 2. Configuration Backend

```bash
cd backend
cp .env.example .env
nano .env
```

Variables d'environnement requises:

```env
# Anthropic API
ANTHROPIC_API_KEY=sk-ant-xxxxxxxxxxxxx

# Supabase
SUPABASE_URL=https://supabase.glacia-code.sbs
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key

# Server
PORT=3001
NODE_ENV=production
```

### 3. Installation des Dépendances

```bash
# Backend
cd backend
npm install

# Frontend
cd ../frontend
npm install
```

### 4. Build Frontend

```bash
cd frontend
npm run build
```

### 5. Déploiement sur VPS

```bash
# Transférer vers VPS
scp -r backend root@72.60.213.98:/root/glacia-coder/
scp -r frontend/dist root@72.60.213.98:/root/glacia-coder/frontend/

# Sur le VPS
ssh root@72.60.213.98
cd /root/glacia-coder/backend
pm2 start server.js --name glacia-backend
pm2 save
```

## 🌐 Accès aux Services

| Service | URL | Description |
|---------|-----|-------------|
| **Frontend** | https://glacia-code.sbs | Interface utilisateur |
| **API Backend** | https://glacia-code.sbs/api | API REST |
| **Supabase** | https://supabase.glacia-code.sbs | Base de données |
| **Health Check** | https://glacia-code.sbs/api/health | Statut API |

## 📚 Structure du Projet

```
glacia-coder/
├── backend/                 # API Node.js/Express
│   ├── server.js           # Serveur principal (v3.0.0)
│   ├── rateLimiter.js      # Middleware rate limiting
│   ├── quotaMiddleware.js  # Gestion quotas utilisateurs
│   ├── logger.js           # Winston logging
│   ├── errorHandler.js     # Gestion erreurs centralisée
│   ├── ecosystem.config.js # Configuration PM2
│   └── package.json
│
├── frontend/               # Application React
│   ├── src/
│   │   ├── components/
│   │   │   ├── Editor/
│   │   │   │   └── MonacoEditor.tsx
│   │   │   ├── PreviewPanel.tsx
│   │   │   ├── Navbar.tsx
│   │   │   └── ...
│   │   ├── pages/
│   │   │   ├── Home.tsx
│   │   │   ├── Dashboard.tsx
│   │   │   ├── Generate.tsx
│   │   │   ├── Editor.tsx
│   │   │   └── ...
│   │   ├── services/
│   │   │   ├── api.ts
│   │   │   ├── auth.service.ts
│   │   │   └── project.service.ts
│   │   ├── contexts/
│   │   │   └── AuthContext.tsx
│   │   └── App.tsx
│   ├── dist/               # Build production
│   └── package.json
│
├── supabase/               # Configuration Supabase
│   └── migrations/
│       └── create_users_trigger.sql
│
└── docs/                   # Documentation
    ├── GLACIA_CODER_RAPPORT_FINAL_VPS.md
    ├── GLACIA_CODER_PARSING_FIX_FINAL.md
    └── ...
```

## 🔧 Gestion & Maintenance

### Voir les logs

```bash
# Backend (PM2)
pm2 logs glacia-backend

# Backend (Logs structurés Winston)
ssh myvps 'tail -f /root/glacia-coder/backend/logs/combined.log'

# Nginx
tail -f /var/log/nginx/access.log
tail -f /var/log/nginx/error.log

# Supabase
docker ps | grep supabase
docker logs supabase-db
```

### Vérifier l'état des services

```bash
# Backend
pm2 status

# Supabase
docker ps --filter "name=supabase"

# Nginx
systemctl status nginx

# Health check API
curl https://glacia-code.sbs/api/health
```

### Redémarrer les services

```bash
# Backend
pm2 restart glacia-backend

# Nginx
systemctl restart nginx

# Supabase
cd /root/supabase/docker
docker-compose restart
```

### Mettre à jour le code

```bash
# Backend
cd /root/glacia-coder/backend
git pull origin main
npm install
pm2 restart glacia-backend

# Frontend
cd /root/glacia-coder/frontend
git pull origin main
npm install
npm run build
# Nginx sert automatiquement le nouveau dist/
```

## 📖 Utilisation

### 1. Créer un compte

Accédez à `https://glacia-code.sbs/signup` et créez votre compte.

### 2. Générer une application

1. Connectez-vous à votre dashboard
2. Cliquez sur "Nouveau Projet" ou allez sur `/generate`
3. Remplissez le formulaire:
   - **Nom du projet**: "Chat App"
   - **Description**: "Application de messagerie moderne"
   - **Prompt détaillé**:
   ```
   Crée une application de chat en temps réel avec:

   - Interface React + TypeScript moderne
   - Liste des conversations à gauche (sidebar)
   - Zone de messages à droite avec scroll automatique
   - Input pour envoyer messages en bas
   - Design avec Tailwind CSS (couleurs professionnelles)
   - Composants modulaires et réutilisables
   - Gestion d'état avec useState
   - Mock data pour démonstration (3-4 conversations)
   - Timestamps et avatars utilisateurs
   - Responsive design (mobile + desktop)

   Le code doit être prêt à exécuter avec npm install && npm run dev.
   Organise les composants dans des fichiers séparés.
   ```
4. Cliquez "Générer mon projet"
5. Attendez 30-60 secondes
6. Accédez à l'éditeur

### 3. Éditer le code

- Naviguez entre les fichiers générés dans le File Explorer
- Éditez directement dans Monaco Editor
- Les modifications sont sauvegardées automatiquement
- Utilisez le Preview Panel pour voir le rendu

### 4. Télécharger le projet

Cliquez sur "Download" pour obtenir un ZIP avec tous les fichiers.

## 🔐 Sécurité

### Implémenté ✅
- ✅ **HTTPS obligatoire** (Let's Encrypt)
- ✅ **Rate Limiting**:
  - 100 requêtes/minute (général)
  - 5 générations/15 minutes
- ✅ **Quota Management**: 10 générations/utilisateur
- ✅ **Row Level Security** (Supabase)
- ✅ **CORS configuré** (whitelist domaines)
- ✅ **Helmet.js** (security headers)
- ✅ **Input validation**
- ✅ **SQL injection protection** (Supabase parameterized queries)
- ✅ **XSS protection**
- ✅ **Firewall UFW** (ports 80, 443, 22)
- ✅ **Logs structurés** (Winston) pour auditing
- ✅ **Error handling centralisé**

### Schéma Base de Données

#### Table `users`
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY,
  email VARCHAR(255) NOT NULL,
  name VARCHAR(255) NOT NULL,
  api_quota INTEGER DEFAULT 10,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Trigger auto-création depuis Supabase Auth
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION handle_new_user();
```

#### Table `projects`
```sql
CREATE TABLE projects (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id),
  name VARCHAR(255) NOT NULL,
  prompt TEXT NOT NULL,
  status VARCHAR(50) DEFAULT 'generating',
  code_files JSONB,
  error_message TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index pour performance
CREATE INDEX idx_projects_user_id ON projects(user_id);
CREATE INDEX idx_projects_status ON projects(status);
```

## 🎨 Fonctionnalités Avancées

### Middleware Backend

#### Rate Limiter (`rateLimiter.js`)
- 100 requêtes/minute par IP (général)
- 5 générations/15 minutes par utilisateur
- Headers `X-RateLimit-*` dans les réponses

#### Quota Middleware (`quotaMiddleware.js`)
- Vérification quota avant génération
- Décrémentation automatique
- Erreur 429 si quota épuisé

#### Logger (`logger.js`)
- Winston avec transports:
  - Console (colorisé, développement)
  - File: `logs/combined.log`
  - File: `logs/error.log` (erreurs uniquement)
- Format JSON structuré
- Rotation automatique (future feature)

#### Error Handler (`errorHandler.js`)
- Gestion centralisée des erreurs
- Codes HTTP appropriés
- Logs structurés avec contexte
- Messages utilisateur friendly

### Frontend Features

#### Monaco Editor
- 40+ langages supportés
- Thème VS Code Dark+
- Auto-complétion
- Minimap
- Recherche/Remplacement (Ctrl+F)
- Multi-curseurs (Alt+Click)

#### Preview Panel
- Rendu HTML/CSS/JS en temps réel
- Sandbox sécurisé (iframe)
- Rechargement automatique
- Console intégrée

#### Authentication Flow
- Supabase Auth
- JWT automatique
- Session persistante
- Protected routes
- Logout propre

## 🐛 Dépannage

### Problème: "Utilisateur non trouvé"

**Solution**: Vérifier que le trigger de création user est actif

```bash
ssh myvps "docker exec supabase-db psql -U postgres -d postgres -c \"
SELECT trigger_name, event_object_table
FROM information_schema.triggers
WHERE trigger_name = 'on_auth_user_created';
\""
```

Si absent, créer le trigger:

```sql
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.users (id, email, name, api_quota)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name',
             SPLIT_PART(NEW.email, '@', 1)),
    10
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();
```

### Problème: "JSON non parsable"

**Solution**: Déjà corrigé dans v3.0.0

Le parsing JSON a été amélioré avec:
- Regex corrigées (\\s → \s)
- Nettoyage des caractères de contrôle
- Fallback automatique
- Logs détaillés (responsePreview, jsonPreview)

### Problème: Backend ne démarre pas

```bash
# Vérifier les logs
pm2 logs glacia-backend

# Vérifier le port
netstat -tulpn | grep 3001

# Vérifier la configuration
cat /root/glacia-coder/backend/.env
```

### Problème: Supabase inaccessible

```bash
# Vérifier les conteneurs
docker ps | grep supabase

# Redémarrer si nécessaire
cd /root/supabase/docker
docker-compose down
docker-compose up -d

# Vérifier les logs
docker logs supabase-db
```

### Problème: Erreur 502 Nginx

```bash
# Tester la configuration
nginx -t

# Voir les logs
tail -f /var/log/nginx/error.log

# Vérifier que le backend répond
curl http://localhost:3001/api/health
```

## 📊 Performances

- **Backend API**: < 200ms latency
- **IA Generation**: 30-60s (selon complexité)
- **Frontend Build**: 2-3s (Vite)
- **Database**: Supabase auto-scaling
- **Taux de succès**: 80-95% (générations)

### Optimisations Appliquées

1. **Parsing JSON robuste**
   - Regex optimisées
   - Cleanup caractères de contrôle
   - Retry automatique

2. **Logs structurés**
   - Winston JSON format
   - Recherche rapide
   - Debugging facilité

3. **Rate Limiting**
   - Protection DDoS
   - Fair usage
   - Performance préservée

4. **Quota Management**
   - Évite abus
   - Coûts contrôlés
   - UX transparente

## 🚀 Améliorations Futures

### Court Terme (Semaine 1-2)

- [ ] **Dashboard Quota** dans UI
  - Afficher quota restant
  - Graphique utilisation
  - Historique générations

- [ ] **Retry Automatique** amélioré
  - Si parsing échoue → retry avec prompt strict
  - Maximum 1 retry automatique
  - Remboursement quota si échec

- [ ] **Tests Automatisés**
  - Tests unitaires parsing JSON
  - Tests intégration API
  - CI/CD avec GitHub Actions

### Moyen Terme (Mois 1-2)

- [ ] **Export GitHub**
  - Intégration Octokit
  - Push automatique vers repository
  - Configuration .github/workflows

- [ ] **Templates de Projets**
  - Todo App
  - Chat App
  - Dashboard Admin
  - E-commerce
  - Blog

- [ ] **Monitoring Externe**
  - Sentry pour erreurs
  - Grafana pour métriques
  - Alertes Slack

### Long Terme (Mois 3-6)

- [ ] **Collaboration Multi-Utilisateurs**
  - Partage de projets
  - Édition simultanée
  - Comments sur code

- [ ] **Plans Premium**
  - Quota illimité
  - Support prioritaire
  - Features avancées

- [ ] **API Publique**
  - REST API pour intégrations
  - SDK JavaScript/Python
  - Documentation OpenAPI

## 🌍 Support Multilingue

Actuellement supporté:
- 🇫🇷 **Français** (principal)
- 🇬🇧 **English** (partiel)

Ajouter une langue dans `frontend/src/i18n/`

## 📞 Support

- **Documentation**: Ce README + `/docs`
- **Health Check**: https://glacia-code.sbs/api/health
- **Issues**: GitHub Issues
- **Email**: admin@glacia-code.sbs

## 📄 Licence

MIT License - Libre d'utilisation pour projets personnels et commerciaux.

Voir [LICENSE](LICENSE) pour plus de détails.

## 🙏 Crédits

- **Claude API** by Anthropic - IA génération de code
- **Monaco Editor** by Microsoft - Éditeur de code
- **Supabase** - Open Source Firebase alternative
- **React** by Meta - Framework frontend
- **Vite** by Evan You - Build tool ultra-rapide
- **TailwindCSS** by Tailwind Labs - Utility-first CSS

## 🎯 Historique des Versions

### v3.0.0-production-ready (13 Nov 2025)
- ✅ Correction parsing JSON (regex + caractères contrôle)
- ✅ Middleware intégrés (rate limiting, quota, logging, errors)
- ✅ Trigger auto-création users
- ✅ Logs Winston structurés
- ✅ 100% services VPS opérationnels
- ✅ Documentation complète

### v2.0.0 (12 Nov 2025)
- ✅ Frontend React + TypeScript déployé
- ✅ Backend Express + Supabase
- ✅ Monaco Editor intégré
- ✅ Authentification Supabase Auth
- ✅ HTTPS avec Let's Encrypt

### v1.0.0 (11 Nov 2025)
- ✅ Version initiale
- ✅ Génération de code basique
- ✅ Dashboard simple

---

**Développé avec ❤️ par l'équipe Glacia-Coder**

🌟 **Si ce projet vous aide, donnez-lui une étoile sur GitHub !**

🚀 **Production-ready et testé sur VPS réel**: https://glacia-code.sbs
