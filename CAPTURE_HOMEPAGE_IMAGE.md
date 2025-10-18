# 📸 Guide de Capture de l'Image de la Page d'Accueil

## 🎯 Objectif

Capturer une image professionnelle de la page d'accueil KongoWara pour l'ajouter au dépôt GitHub.

---

## ⚡ Méthode Rapide (2 minutes)

### Option 1 : Capture d'Écran Complète (RECOMMANDÉ)

**Sur Windows :**

1. **Ouvrir le site** : https://kongowara.com
2. **Maximiser la fenêtre** du navigateur
3. **Appuyer sur** : `Win + Shift + S`
4. **Choisir** "Capture fenêtre"
5. **Coller** dans Paint : `Ctrl + V`
6. **Enregistrer sous** : `C:\Users\HP\.github\images\homepage-screenshot.png`

### Option 2 : Outil de Développeur Chrome/Edge

1. **Ouvrir** https://kongowara.com
2. **Appuyer sur** `F12` (DevTools)
3. **Appuyer sur** `Ctrl + Shift + P`
4. **Taper** : "Capture full size screenshot"
5. **Appuyer sur** Entrée
6. **Déplacer** le fichier téléchargé vers : `C:\Users\HP\.github\images\homepage-screenshot.png`

### Option 3 : Extension Navigateur (Plus Professionnel)

**Extensions recommandées :**
- **Awesome Screenshot** (Chrome/Edge)
- **Fireshot** (Chrome/Edge/Firefox)

**Étapes :**
1. Installer l'extension
2. Ouvrir https://kongowara.com
3. Cliquer sur l'icône de l'extension
4. Choisir "Capture Entire Page"
5. Enregistrer comme : `homepage-screenshot.png`
6. Déplacer vers : `C:\Users\HP\.github\images\`

---

## 🎨 Spécifications Image

### Format
- **Type** : PNG (meilleure qualité) ou JPG (plus léger)
- **Nom** : `homepage-screenshot.png`
- **Emplacement** : `C:\Users\HP\.github\images\`

### Qualité
- **Résolution** : 1920x1080 minimum
- **Type de capture** : Full page (toute la page)
- **Sections à inclure** :
  - ✅ Navigation header avec logo
  - ✅ Hero section (section principale)
  - ✅ Fonctionnalités (Features)
  - ✅ Calculateur d'échange
  - ✅ Footer

### Optimisation (Optionnel)
Si l'image est > 2 MB :
- Utiliser https://tinypng.com pour compresser
- Viser 500 KB - 1 MB maximum

---

## 🔧 Après Capture

### Vérifier l'Image

```bash
# Vérifier que le fichier existe
dir "C:\Users\HP\.github\images\homepage-screenshot.png"

# Vérifier la taille
# (doit être < 2 MB pour GitHub)
```

### Alternative : Capture Multiple

Vous pouvez capturer plusieurs variantes :

```
.github/images/
  ├── homepage-screenshot.png        (capture complète)
  ├── homepage-hero.png              (section hero uniquement)
  └── homepage-features.png          (section features)
```

---

## ✅ Checklist Rapide

- [ ] Site ouvert sur https://kongowara.com
- [ ] Fenêtre navigateur maximisée
- [ ] Capture effectuée (full page)
- [ ] Image enregistrée dans `.github/images/`
- [ ] Nom du fichier : `homepage-screenshot.png`
- [ ] Taille < 2 MB
- [ ] Image vérifiée (ouverture OK)

---

## 🚀 Après la Capture

**Dites simplement :** "Image capturée"

Je vais alors :
1. ✅ Mettre à jour le README avec l'image
2. ✅ Ajouter l'image au commit Git
3. ✅ Pousser vers GitHub

---

## 📊 Résultat Final

L'image apparaîtra dans le README comme ceci :

```markdown
## 🎨 Aperçu de la Plateforme

![KongoWara Homepage](/.github/images/homepage-screenshot.png)
```

---

## 🆘 Problèmes ?

### Image trop grande (> 2 MB)

**Solution 1 :** Compresser en ligne
- https://tinypng.com
- https://squoosh.app

**Solution 2 :** Convertir en JPG
- Ouvrir dans Paint
- Enregistrer sous > JPG (qualité 85%)

### Impossible de capturer

**Alternative :** Utiliser un screenshot existant
- Si vous avez déjà des screenshots du site
- Ou je peux créer un placeholder temporaire

---

## ⏱️ Temps Estimé

- **Capture** : 30 secondes
- **Enregistrement** : 30 secondes
- **Vérification** : 30 secondes

**Total : 2 minutes** ⚡

---

**🎯 Prêt ? Capturez l'image et dites "Image capturée" !**
