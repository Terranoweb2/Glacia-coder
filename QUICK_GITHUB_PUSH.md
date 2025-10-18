# ⚡ KongoWara - Push Rapide vers GitHub

**Guide ultra-rapide en 3 commandes**

---

## 🚀 Méthode 1 : Script Automatique (30 secondes)

```cmd
REM Double-cliquer sur :
C:\Users\HP\deploy-to-github.bat

REM Le script fait TOUT automatiquement !
```

**C'est tout ! Le script gère tout pour vous.** ✅

---

## 💻 Méthode 2 : Ligne de Commande (2 minutes)

### Prérequis
```bash
# Vérifier Git
git --version

# Si pas installé : https://git-scm.com/download/win
```

### Étapes

**1. Créer le repo sur GitHub**
- Aller sur https://github.com/new
- Nom : `kongowara-improvements`
- Public ou Private
- ⚠️ NE PAS ajouter README
- Cliquer "Create repository"

**2. Initialiser et pusher**
```bash
cd C:\Users\HP

# Init
git init
git add .
git commit -m "feat: Add KongoWara improvements kit v2.0"

# Connecter à GitHub
git remote add origin https://github.com/VOTRE-USERNAME/kongowara-improvements.git
git branch -M main
git push -u origin main
```

**3. Authentification**
- Username : votre-username
- Password : **Personal Access Token** (pas votre mot de passe)
  - Créer ici : https://github.com/settings/tokens
  - Cocher "repo"
  - Copier le token et l'utiliser comme password

---

## ✅ Vérification

Aller sur : `https://github.com/VOTRE-USERNAME/kongowara-improvements`

Vous devriez voir :
- ✅ README.md qui s'affiche
- ✅ Dossier `scripts/` avec les 5 scripts
- ✅ Toute la documentation
- ✅ ~16 fichiers au total

---

## 🆘 Problèmes ?

### "Git not found"
→ Installer Git : https://git-scm.com/download/win

### "Authentication failed"
→ Utiliser Personal Access Token : https://github.com/settings/tokens

### "Permission denied"
→ Vérifier l'URL du repo et votre username

---

## 📚 Documentation Complète

Pour plus de détails : [GITHUB_DEPLOYMENT_GUIDE.md](GITHUB_DEPLOYMENT_GUIDE.md)

---

**🎉 C'est tout ! Votre projet est sur GitHub en 2 minutes !**
