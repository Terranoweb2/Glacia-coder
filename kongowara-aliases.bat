@echo off
REM KongoWara VPS Aliases pour Windows
REM Utilisation: kongowara [commande]

set SCRIPT_PATH=C:\Users\HP\kongowara-vps-helper.sh

if "%1"=="" (
    bash "%SCRIPT_PATH%" menu
    exit /b
)

bash "%SCRIPT_PATH%" %*
