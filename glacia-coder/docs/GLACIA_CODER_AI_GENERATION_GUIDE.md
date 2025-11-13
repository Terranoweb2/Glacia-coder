# 🤖 Guide d'Implémentation - Génération IA

**Date**: 12 Novembre 2025
**Projet**: Glacia-Coder - AI Code Generation

---

## 🎯 Problème Actuel

Quand vous créez un projet :
- ✅ Le projet est créé dans la base de données
- ✅ Le status est `generating`
- ❌ **Aucun code n'est généré** (`code_files = []`)
- ❌ L'éditeur est vide car pas de fichiers

**Pour tester**, j'ai manuellement ajouté 3 fichiers au projet "Chat App". Rafraîchissez la page de l'éditeur pour les voir.

---

## 🏗️ Architecture à Implémenter

```
┌─────────────────────────────────────────────────────────┐
│                    Frontend (React)                     │
│  https://glacia-code.sbs/generate                       │
└───────────────────────┬─────────────────────────────────┘
                        │
                        │ 1. POST /api/projects/generate
                        │    { name, description, prompt }
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│              Backend API (Node.js/Express)              │
│              Port 3001 ou 5000                          │
│                                                          │
│  Route: POST /api/projects/generate                     │
│  ├─ Vérifier auth JWT                                   │
│  ├─ Créer projet Supabase (status: generating)         │
│  ├─ Appeler Claude API avec le prompt                  │
│  ├─ Parser la réponse (extraire fichiers)              │
│  ├─ Mettre à jour projet (code_files + status)         │
│  └─ Retourner projet_id                                 │
└───────────────────────┬─────────────────────────────────┘
                        │
                        │ 2. POST https://api.anthropic.com/v1/messages
                        │    { model: "claude-3-5-sonnet", prompt: ... }
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│               Claude API (Anthropic)                    │
│  Génère le code basé sur le prompt                      │
└───────────────────────┬─────────────────────────────────┘
                        │
                        │ 3. Response avec fichiers générés
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│                   Supabase Database                     │
│  UPDATE projects SET                                    │
│    status = 'completed',                                │
│    code_files = [...]                                   │
└─────────────────────────────────────────────────────────┘
```

---

## 📋 Étapes d'Implémentation

### Étape 1: Créer le Backend API

**Fichier**: `/root/glacia-coder/backend/server.js`

```javascript
const express = require('express');
const cors = require('cors');
const { createClient } = require('@supabase/supabase-js');
const Anthropic = require('@anthropic-ai/sdk');

const app = express();
app.use(cors());
app.use(express.json());

// Supabase Client (Service Role pour bypass RLS)
const supabase = createClient(
  'https://supabase.glacia-code.sbs',
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

// Claude API Client
const anthropic = new Anthropic({
  apiKey: process.env.ANTHROPIC_API_KEY,
});

// Route de génération
app.post('/api/projects/generate', async (req, res) => {
  try {
    const { name, description, prompt, userId } = req.body;

    // 1. Créer le projet dans Supabase
    const { data: project, error: dbError } = await supabase
      .from('projects')
      .insert({
        user_id: userId,
        name,
        description,
        prompt,
        status: 'generating',
        code_files: [],
      })
      .select()
      .single();

    if (dbError) throw dbError;

    // 2. Appeler Claude API en arrière-plan
    generateCode(project.id, prompt);

    // 3. Retourner immédiatement le projet
    res.json({ success: true, project_id: project.id });

  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Fonction de génération asynchrone
async function generateCode(projectId, userPrompt) {
  try {
    // Prompt système pour Claude
    const systemPrompt = `Tu es un générateur de code expert.
L'utilisateur va te demander de créer une application web.
Tu dois générer TOUS les fichiers nécessaires au format JSON suivant :

{
  "files": [
    {
      "name": "App.tsx",
      "path": "src/App.tsx",
      "content": "le code complet ici"
    },
    {
      "name": "package.json",
      "path": "package.json",
      "content": "le package.json complet"
    }
  ]
}

Génère une application React + TypeScript complète et fonctionnelle.`;

    // Appel à Claude API
    const message = await anthropic.messages.create({
      model: 'claude-3-5-sonnet-20241022',
      max_tokens: 8000,
      system: systemPrompt,
      messages: [
        {
          role: 'user',
          content: userPrompt,
        },
      ],
    });

    // Parser la réponse
    const responseText = message.content[0].text;
    const jsonMatch = responseText.match(/\{[\s\S]*"files"[\s\S]*\}/);

    if (!jsonMatch) {
      throw new Error('Format de réponse invalide');
    }

    const generatedData = JSON.parse(jsonMatch[0]);
    const files = generatedData.files;

    // Mettre à jour le projet dans Supabase
    const { error: updateError } = await supabase
      .from('projects')
      .update({
        status: 'completed',
        code_files: files,
        updated_at: new Date().toISOString(),
      })
      .eq('id', projectId);

    if (updateError) throw updateError;

    console.log(`Project ${projectId} generated successfully`);

  } catch (error) {
    console.error('Generation error:', error);

    // Marquer le projet comme échoué
    await supabase
      .from('projects')
      .update({
        status: 'error',
        error_message: error.message,
      })
      .eq('id', projectId);
  }
}

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

const PORT = process.env.PORT || 3001;
app.listen(PORT, () => {
  console.log(`Backend API running on port ${PORT}`);
});
```

---

### Étape 2: Configurer les Variables d'Environnement

**Fichier**: `/root/glacia-coder/backend/.env`

```env
# Supabase
SUPABASE_URL=https://supabase.glacia-code.sbs
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyAgCiAgICAicm9sZSI6ICJzZXJ2aWNlX3JvbGUiLAogICAgImlzcyI6ICJzdXBhYmFzZS1kZW1vIiwKICAgICJpYXQiOiAxNjQxNzY5MjAwLAogICAgImV4cCI6IDE3OTk1MzU2MDAKfQ.DaYlNEoUrrEn2Ig7tqibS-PHK5vgusbcbo7X36XVt4Q

# Claude API (Anthropic)
ANTHROPIC_API_KEY=votre_clé_ici

# Server
PORT=3001
NODE_ENV=production
```

**⚠️ Important**: Vous devez créer un compte Anthropic et obtenir une clé API sur https://console.anthropic.com/

---

### Étape 3: Installer les Dépendances

```bash
ssh myvps
cd /root/glacia-coder
mkdir -p backend
cd backend

# Créer package.json
cat > package.json << 'EOF'
{
  "name": "glacia-coder-backend",
  "version": "1.0.0",
  "main": "server.js",
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "@supabase/supabase-js": "^2.47.0",
    "@anthropic-ai/sdk": "^0.27.0",
    "dotenv": "^16.3.1"
  },
  "devDependencies": {
    "nodemon": "^3.0.1"
  }
}
EOF

# Installer
npm install
```

---

### Étape 4: Configurer Nginx pour le Backend

**Fichier**: `/etc/nginx/sites-available/glacia-code.sbs`

Ajouter cette section :

```nginx
# Backend API
location /api/ {
    proxy_pass http://localhost:3001/api/;
    proxy_http_version 1.1;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;

    # CORS
    add_header Access-Control-Allow-Origin "https://glacia-code.sbs" always;
    add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS" always;
    add_header Access-Control-Allow-Headers "Authorization, Content-Type" always;
    add_header Access-Control-Allow-Credentials "true" always;

    if ($request_method = OPTIONS) {
        return 204;
    }
}
```

Recharger Nginx :
```bash
nginx -t && systemctl reload nginx
```

---

### Étape 5: Démarrer le Backend avec PM2

```bash
cd /root/glacia-coder/backend
pm2 start server.js --name glacia-backend
pm2 save
```

---

### Étape 6: Modifier le Frontend

**Fichier**: Frontend `src/pages/Generate.tsx`

Remplacer la fonction `handleSubmit` :

```typescript
const handleSubmit = async (e: React.FormEvent) => {
  e.preventDefault();
  if (!projectName.trim() || !prompt.trim()) return;

  setIsGenerating(true);

  try {
    // Obtenir l'utilisateur actuel
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) throw new Error('Non authentifié');

    // Appeler le backend
    const response = await fetch('https://glacia-code.sbs/api/projects/generate', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        name: projectName,
        description: projectDescription,
        prompt: prompt,
        userId: user.id,
      }),
    });

    if (!response.ok) {
      throw new Error('Erreur lors de la génération');
    }

    const data = await response.json();

    // Rediriger vers l'éditeur
    navigate(`/editor/${data.project_id}`);

  } catch (error) {
    console.error('Error:', error);
    alert('Erreur lors de la création du projet');
  } finally {
    setIsGenerating(false);
  }
};
```

---

## 🧪 Tester la Génération

### 1. Vérifier que le backend est démarré
```bash
ssh myvps 'pm2 list'
ssh myvps 'curl http://localhost:3001/health'
```

### 2. Tester l'endpoint de génération
```bash
curl -X POST https://glacia-code.sbs/api/projects/generate \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test App",
    "description": "Application de test",
    "prompt": "Créer une application React simple avec un compteur",
    "userId": "USER_ID_ICI"
  }'
```

### 3. Créer un projet depuis le frontend
1. Aller sur https://glacia-code.sbs/generate
2. Remplir le formulaire
3. Cliquer sur "Générer"
4. Attendre (~10-30 secondes selon la complexité)
5. Vérifier que l'éditeur affiche les fichiers

---

## 💰 Coûts Claude API

**Prix Claude 3.5 Sonnet** :
- Input: $3 / 1M tokens (~$0.003 per 1K)
- Output: $15 / 1M tokens (~$0.015 per 1K)

**Estimation par génération** :
- Prompt: ~500 tokens = $0.0015
- Réponse: ~2000 tokens = $0.03
- **Total par projet**: ~$0.03 (3 centimes)

Pour 1000 projets générés : ~$30

---

## 🔄 Améliorations Futures

### 1. File d'Attente avec Bull/Redis
Pour gérer plusieurs générations simultanées

### 2. WebSocket pour Progression en Temps Réel
```typescript
// Backend émet des événements
io.emit('generation-progress', {
  projectId,
  status: 'Generating React components...',
  progress: 45
});
```

### 3. Templates Pré-Définis
Accélérer la génération avec des templates de base

### 4. Cache des Générations Similaires
Réduire les coûts en réutilisant le code similaire

---

## 📊 Monitoring

### Logs Backend
```bash
# Logs PM2
ssh myvps 'pm2 logs glacia-backend'

# Logs en direct
ssh myvps 'pm2 logs glacia-backend --lines 100'
```

### Vérifier l'État des Projets
```bash
ssh myvps "docker exec supabase-db psql -U postgres -d postgres -c \"
SELECT status, COUNT(*)
FROM public.projects
GROUP BY status;
\""
```

---

## 🎯 Résumé

**Actuellement** :
- ✅ Frontend créé et déployé
- ✅ Supabase Auth fonctionne
- ✅ Dashboard et Éditeur opérationnels
- ❌ **Génération IA non implémentée**

**Pour activer la génération** :
1. Créer le backend Express
2. Obtenir une clé API Claude
3. Configurer les variables d'environnement
4. Modifier le frontend pour appeler le backend
5. Tester la génération

**Effort estimé** : 2-4 heures

---

**📅 Date**: 12 Novembre 2025
**✅ Statut**: Guide complet pour implémenter la génération IA
