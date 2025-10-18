@echo off
REM ========================================
REM KongoWara Admin Panel - Complete Deployment Script (Windows)
REM ========================================
REM This script deploys ALL remaining admin panel phases (2-6)
REM Total files to deploy: 10 files
REM
REM Prerequisites:
REM - SSH client installed (OpenSSH, PuTTY with pscp, or WinSCP)
REM - Files present in C:\Users\HP\ directory
REM
REM Usage:
REM   DEPLOY_ALL_PHASES.bat
REM ========================================

echo =========================================
echo KongoWara Admin Panel - Deployment Script
echo =========================================
echo.

REM Configuration
set VPS_HOST=72.60.213.98
set VPS_USER=root
set VPS_PASS=lycoshoster@TOH2026
set VPS_BASE=/home/kongowara/kongowara-app/frontend/src/pages/admin
set LOCAL_BASE=C:\Users\HP

echo Configuration:
echo   VPS: %VPS_USER%@%VPS_HOST%
echo   Destination: %VPS_BASE%
echo.

REM Check if sshpass is available (Linux subsystem)
where sshpass >nul 2>&1
if %errorlevel% equ 0 (
    echo Using sshpass for authentication...
    set SSH_CMD=sshpass -p "%VPS_PASS%" ssh -o StrictHostKeyChecking=no %VPS_USER%@%VPS_HOST%
    set SCP_CMD=sshpass -p "%VPS_PASS%" scp -o StrictHostKeyChecking=no
) else (
    echo Using standard SSH (password prompt required)...
    set SSH_CMD=ssh %VPS_USER%@%VPS_HOST%
    set SCP_CMD=scp
)

REM Step 1: Create directories
echo.
echo Step 1/5: Creating directories on VPS...
%SSH_CMD% "mkdir -p %VPS_BASE%/users"
%SSH_CMD% "mkdir -p %VPS_BASE%/kyc"
%SSH_CMD% "mkdir -p %VPS_BASE%/rates"
echo    Done: Directories created
echo.

REM Step 2: Upload Phase 2 files
echo Step 2/5: Uploading Phase 2 files (Users Management)...
%SCP_CMD% "%LOCAL_BASE%\admin-users.js" %VPS_USER%@%VPS_HOST%:%VPS_BASE%/users.js
echo    Done: admin-users.js uploaded

%SCP_CMD% "%LOCAL_BASE%\admin-user-details.js" %VPS_USER%@%VPS_HOST%:%VPS_BASE%/users/[userId].js
echo    Done: admin-user-details.js uploaded
echo.

REM Step 3: Upload Phase 3 files
echo Step 3/5: Uploading Phase 3 files (KYC Management)...
%SCP_CMD% "%LOCAL_BASE%\admin-kyc.js" %VPS_USER%@%VPS_HOST%:%VPS_BASE%/kyc.js
echo    Done: admin-kyc.js uploaded

%SCP_CMD% "%LOCAL_BASE%\admin-kyc-review.js" %VPS_USER%@%VPS_HOST%:%VPS_BASE%/kyc/[userId].js
echo    Done: admin-kyc-review.js uploaded
echo.

REM Step 4: Upload Phase 4-6 files
echo Step 4/5: Uploading Phase 4-6 files...

REM Phase 4
%SCP_CMD% "%LOCAL_BASE%\admin-transactions.js" %VPS_USER%@%VPS_HOST%:%VPS_BASE%/transactions.js
echo    Done: admin-transactions.js uploaded

%SCP_CMD% "%LOCAL_BASE%\admin-analytics.js" %VPS_USER%@%VPS_HOST%:%VPS_BASE%/analytics.js
echo    Done: admin-analytics.js uploaded

REM Phase 5
%SCP_CMD% "%LOCAL_BASE%\admin-rates.js" %VPS_USER%@%VPS_HOST%:%VPS_BASE%/rates.js
echo    Done: admin-rates.js uploaded

%SCP_CMD% "%LOCAL_BASE%\admin-rates-create.js" %VPS_USER%@%VPS_HOST%:%VPS_BASE%/rates/create.js
echo    Done: admin-rates-create.js uploaded

REM Phase 6
%SCP_CMD% "%LOCAL_BASE%\admin-settings.js" %VPS_USER%@%VPS_HOST%:%VPS_BASE%/settings.js
echo    Done: admin-settings.js uploaded

%SCP_CMD% "%LOCAL_BASE%\admin-logs.js" %VPS_USER%@%VPS_HOST%:%VPS_BASE%/logs.js
echo    Done: admin-logs.js uploaded
echo.

REM Step 5: Restart frontend
echo Step 5/5: Restarting frontend container...
%SSH_CMD% "cd /home/kongowara/kongowara-app && docker compose restart frontend"
echo    Waiting 20 seconds for rebuild...
timeout /t 20 /nobreak >nul
echo    Done: Frontend restarted
echo.

REM Verify deployment
echo Step 6/6: Verifying deployment...
%SSH_CMD% "ls -lah %VPS_BASE%/*.js"
%SSH_CMD% "ls -lah %VPS_BASE%/users/"
%SSH_CMD% "ls -lah %VPS_BASE%/kyc/"
%SSH_CMD% "ls -lah %VPS_BASE%/rates/"
echo.

echo =========================================
echo DEPLOYMENT COMPLETE!
echo =========================================
echo.
echo Deployed Pages:
echo    https://kongowara.com/admin/users
echo    https://kongowara.com/admin/users/[userId]
echo    https://kongowara.com/admin/kyc
echo    https://kongowara.com/admin/kyc/[userId]
echo    https://kongowara.com/admin/transactions
echo    https://kongowara.com/admin/analytics
echo    https://kongowara.com/admin/rates
echo    https://kongowara.com/admin/rates/create
echo    https://kongowara.com/admin/settings
echo    https://kongowara.com/admin/logs
echo.
echo Next Steps:
echo    1. Open https://kongowara.com/admin in browser
echo    2. Login as admin user
echo    3. Test navigation between pages
echo.
echo Press any key to exit...
pause >nul
