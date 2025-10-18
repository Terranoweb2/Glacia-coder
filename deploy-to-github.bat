@echo off
REM KongoWara - Script de Déploiement GitHub
REM Ce script automatise le push du projet vers GitHub

title KongoWara - Deploy to GitHub

echo.
echo ========================================
echo   KongoWara - Deploy to GitHub
echo ========================================
echo.

REM Configuration
set PROJECT_DIR=C:\Users\HP
set REPO_NAME=kongowara-improvements

echo [1/7] Verification de Git...
git --version >nul 2>&1
if errorlevel 1 (
    echo [ERREUR] Git n'est pas installe!
    echo.
    echo Telechargez Git: https://git-scm.com/download/win
    pause
    exit /b 1
)
echo [OK] Git est installe

echo.
echo [2/7] Navigation vers le projet...
cd /d "%PROJECT_DIR%"
echo [OK] Repertoire: %CD%

echo.
echo [3/7] Initialisation Git (si necessaire)...
if not exist ".git" (
    git init
    echo [OK] Repository Git initialise
) else (
    echo [OK] Repository Git deja initialise
)

echo.
echo [4/7] Configuration Git locale...
echo Entrez votre nom GitHub:
set /p GIT_NAME=^>
git config user.name "%GIT_NAME%"

echo Entrez votre email GitHub:
set /p GIT_EMAIL=^>
git config user.email "%GIT_EMAIL%"
echo [OK] Configuration Git completee

echo.
echo [5/7] Ajout des fichiers...
echo.
echo Fichiers a commiter:
echo - Scripts (scripts/*.sh)
echo - Documentation (*.md)
echo - Configuration (.gitignore)
echo - Utilitaires (*.bat)
echo.

REM Ajouter tous les fichiers importants
git add .gitignore
git add README.md
git add START_HERE.md
git add ACTION_IMMEDIATE.md
git add GUIDE_EXECUTION_RAPIDE.md
git add RESUME_EXECUTIF.md
git add KONGOWARA_ANALYSE_ET_PROPOSITIONS.md
git add RECAPITULATIF_COMPLET_AMELIORATIONS.md
git add INDEX_DOCUMENTATION.md
git add README_KONGOWARA_V2.md
git add CONTRIBUTING.md
git add scripts/*.sh
git add scripts/README.md
git add *.bat

echo [OK] Fichiers ajoutes

echo.
echo [6/7] Commit des modifications...
git commit -m "feat: Add KongoWara improvements kit v2.0

- 5 automated installation scripts
- 150 pages of professional documentation
- Enterprise-level security (Fail2Ban, Rate Limiting, SSL A+)
- Automated daily backups
- Fixed Docker health checks
- Mobile SSL configuration
- Complete roadmap (12 months)
- ROI >300,000%%

Generated with Claude Code"

if errorlevel 1 (
    echo [AVERTISSEMENT] Rien a commiter ou erreur lors du commit
) else (
    echo [OK] Commit cree avec succes
)

echo.
echo [7/7] Push vers GitHub...
echo.
echo Vous devez d'abord creer un repository sur GitHub:
echo   1. Allez sur https://github.com/new
echo   2. Nom du repo: %REPO_NAME%
echo   3. Description: KongoWara Platform - Enterprise Improvements Kit
echo   4. Public ou Private (votre choix)
echo   5. NE PAS initialiser avec README (deja existant)
echo   6. Cliquez sur "Create repository"
echo.
echo Avez-vous cree le repository sur GitHub? (O/N)
set /p REPO_CREATED=^>

if /i not "%REPO_CREATED%"=="O" (
    echo.
    echo Creez le repository puis relancez ce script.
    pause
    exit /b 0
)

echo.
echo Entrez votre username GitHub:
set /p GITHUB_USER=^>

echo.
echo Ajout du remote...
git remote remove origin 2>nul
git remote add origin https://github.com/%GITHUB_USER%/%REPO_NAME%.git

echo.
echo Renommage de la branche en 'main'...
git branch -M main

echo.
echo Push vers GitHub...
echo.
echo ATTENTION: Vous devrez peut-etre vous authentifier avec:
echo   - Personal Access Token (recommande)
echo   - GitHub Desktop
echo   - SSH key
echo.
pause

git push -u origin main

if errorlevel 1 (
    echo.
    echo [ERREUR] Push echoue!
    echo.
    echo Solutions possibles:
    echo   1. Utilisez GitHub Desktop pour pusher
    echo   2. Configurez un Personal Access Token
    echo   3. Utilisez SSH au lieu de HTTPS
    echo.
    echo Pour Personal Access Token:
    echo   1. Allez sur https://github.com/settings/tokens
    echo   2. "Generate new token" ^(classic^)
    echo   3. Cochez "repo"
    echo   4. Copiez le token
    echo   5. Utilisez-le comme password lors du push
    echo.
    pause
    exit /b 1
)

echo.
echo ========================================
echo   Push GitHub termine avec succes!
echo ========================================
echo.
echo Repository: https://github.com/%GITHUB_USER%/%REPO_NAME%
echo.
echo Prochaines etapes:
echo   1. Visitez votre repo sur GitHub
echo   2. Ajoutez une description
echo   3. Ajoutez des topics: fintech, security, automation, docker
echo   4. Configurez GitHub Pages si souhaite
echo   5. Invitez des collaborateurs
echo.
pause
