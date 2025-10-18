@echo off
REM KongoWara - Script d'Upload Automatique vers VPS
REM Ce script facilite l'upload des scripts d'amélioration vers le VPS

title KongoWara - Upload Scripts to VPS

echo.
echo ========================================
echo   KongoWara - Upload Scripts to VPS
echo ========================================
echo.

REM Configuration
set VPS_HOST=root@72.60.213.98
set VPS_PATH=/root/kongowara-scripts
set LOCAL_SCRIPTS=C:\Users\HP\scripts

echo Configuration:
echo   - VPS: %VPS_HOST%
echo   - Destination: %VPS_PATH%
echo   - Source: %LOCAL_SCRIPTS%
echo.

REM Vérifier que le dossier scripts existe
if not exist "%LOCAL_SCRIPTS%" (
    echo [ERREUR] Le dossier %LOCAL_SCRIPTS% n'existe pas!
    echo.
    pause
    exit /b 1
)

echo [1/4] Verification des fichiers locaux...
echo.
dir /b "%LOCAL_SCRIPTS%\*.sh"
echo.

echo [2/4] Tentative de connexion SSH au VPS...
echo.

REM Tester la connexion SSH
ssh %VPS_HOST% "echo '[OK] Connexion SSH reussie!'" 2>nul
if errorlevel 1 (
    echo [ERREUR] Impossible de se connecter au VPS!
    echo.
    echo Solutions possibles:
    echo   1. Verifier que SSH est installe ^(OpenSSH^)
    echo   2. Configurer la cle SSH dans C:\Users\HP\.ssh\
    echo   3. Utiliser WinSCP ou FileZilla manuellement
    echo.
    echo Voulez-vous continuer quand meme? ^(O/N^)
    set /p CONTINUE=^>
    if /i not "%CONTINUE%"=="O" exit /b 1
)

echo.
echo [3/4] Creation du dossier sur le VPS...
ssh %VPS_HOST% "mkdir -p %VPS_PATH%" 2>nul

echo.
echo [4/4] Upload des scripts...
echo.

REM Essayer SCP
echo Methode 1: SCP...
scp "%LOCAL_SCRIPTS%\*.sh" %VPS_HOST%:%VPS_PATH%/ 2>nul
if errorlevel 1 (
    echo [AVERTISSEMENT] SCP a echoue. Essayez WinSCP.
    echo.
    echo Instructions WinSCP:
    echo   1. Telechargez WinSCP: https://winscp.net/
    echo   2. Connectez-vous a 72.60.213.98 avec root
    echo   3. Uploadez le dossier C:\Users\HP\scripts\
    echo      vers /root/kongowara-scripts/
    echo.
    pause
    exit /b 1
)

echo.
echo ========================================
echo   Upload termine avec succes!
echo ========================================
echo.

echo Prochaines etapes sur le VPS:
echo.
echo   ssh %VPS_HOST%
echo   cd %VPS_PATH%
echo   chmod +x *.sh
echo   ./deploy-all-improvements.sh
echo.

echo Voulez-vous vous connecter maintenant au VPS? ^(O/N^)
set /p CONNECT=^>

if /i "%CONNECT%"=="O" (
    echo.
    echo Connexion au VPS...
    echo.
    ssh %VPS_HOST%
)

echo.
echo Termine!
pause
