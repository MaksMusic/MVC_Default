@echo off
REM Simple deploy script for Windows (SSH/SCP must be installed and in PATH)

echo ===== DEPLOY SPRING BOOT + DOCKER =====

REM Configure IP, user and FULL remote project path on server

set /p SERVER_IP=Enter server IP: 
set /p SSH_USER=Enter SSH user (e.g. root): 
set /p REMOTE_PATH=Enter FULL remote project path (will be created): 

echo.
echo Assume JAR is already built manually and located in build\libs\

echo.
echo Creating remote directory: %REMOTE_PATH%
ssh %SSH_USER%@%SERVER_IP% "mkdir -p %REMOTE_PATH%"
if errorlevel 1 (
    echo SSH error or cannot create remote directory. Stopping.
    exit /b 1
)

echo.
echo Copying files to server...
scp docker-compose.yml Dockerfile build\libs\*.jar %SSH_USER%@%SERVER_IP%:%REMOTE_PATH%/
if errorlevel 1 (
    echo SCP error while copying files. Stopping.
    exit /b 1
)

echo.
echo Starting docker compose on server...
ssh %SSH_USER%@%SERVER_IP% "cd %REMOTE_PATH% && docker compose up -d --build"
if errorlevel 1 (
    echo Error starting docker compose on server.
    exit /b 1
)

echo.
echo Done. Application should be running in Docker on the server.
