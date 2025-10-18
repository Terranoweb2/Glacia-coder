# Contributing to KongoWara

Merci de votre intérêt pour contribuer à KongoWara ! 🎉

## 📋 Comment Contribuer

### 1. Fork et Clone

```bash
# Fork le projet sur GitHub
# Puis cloner votre fork
git clone https://github.com/votre-username/kongowara-improvements.git
cd kongowara-improvements
```

### 2. Créer une Branche

```bash
git checkout -b feature/amazing-feature
# ou
git checkout -b fix/bug-fix
```

### 3. Faire vos Modifications

- Suivre le style de code existant
- Commenter le code si nécessaire
- Ajouter des tests si applicable
- Mettre à jour la documentation

### 4. Commit

```bash
git add .
git commit -m "feat: Add amazing feature"
```

### Format des Commits

Utiliser la convention [Conventional Commits](https://www.conventionalcommits.org/) :

- `feat:` Nouvelle fonctionnalité
- `fix:` Correction de bug
- `docs:` Documentation
- `style:` Formatage
- `refactor:` Refactoring
- `test:` Tests
- `chore:` Maintenance

### 5. Push et Pull Request

```bash
git push origin feature/amazing-feature
```

Puis créer une Pull Request sur GitHub.

## 📝 Guidelines

### Code Style

- Indentation : 2 espaces
- Quotes : Simple quotes pour JS/Bash
- Ligne max : 80-100 caractères
- Commentaires en français ou anglais

### Scripts Bash

- Toujours `set -e` en début
- Fonctions bien nommées
- Logs avec couleurs
- Gestion d'erreurs

### Documentation

- Markdown pour tous les docs
- Exemples concrets
- Screenshots si utile
- Table des matières si >50 lignes

## 🧪 Tests

Avant de soumettre :

```bash
# Tester les scripts
shellcheck scripts/*.sh

# Vérifier la documentation
# (pas de liens cassés, etc.)
```

## 🚫 Ce qu'il ne faut PAS faire

- ❌ Commiter des secrets/passwords
- ❌ Commiter node_modules
- ❌ Casser les features existantes
- ❌ Ignorer les warnings

## ✅ Checklist Pull Request

- [ ] Code testé localement
- [ ] Documentation mise à jour
- [ ] Commits bien formatés
- [ ] Pas de secrets committé
- [ ] Changelog mis à jour si nécessaire

## 📞 Questions ?

Ouvrez une [Issue](https://github.com/votre-username/kongowara-improvements/issues) !

---

**Merci pour votre contribution ! 🙏**
