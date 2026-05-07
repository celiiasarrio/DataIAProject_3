@echo off
setlocal

set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
set "PROJECT_ID=project3grupo6"
set "REGION=europe-west1"
set "REGISTRY=%REGION%-docker.pkg.dev/%PROJECT_ID%/docker-repo"

for /f "usebackq delims=" %%i in (`powershell -NoProfile -Command "Get-Date -Format yyyyMMddHHmmss"`) do set "IMAGE_TAG=%%i"

where terraform >nul 2>nul
if %ERRORLEVEL% EQU 0 (
  set "TERRAFORM_BIN=terraform"
) else (
  if exist "%SCRIPT_DIR%\terraform\terraform.exe" (
    set "TERRAFORM_BIN=%SCRIPT_DIR%\terraform\terraform.exe"
  ) else (
    echo Terraform no esta en el PATH y no encuentro terraform\terraform.exe
    exit /b 1
  )
)

echo ==^> Resolving backend and agent URLs...
set "BACKEND_URL_FILE=%TEMP%\dataia_backend_url_%RANDOM%.txt"
set "AGENT_URL_FILE=%TEMP%\dataia_agent_url_%RANDOM%.txt"
"%TERRAFORM_BIN%" -chdir="%SCRIPT_DIR%\terraform" output -raw backend_url > "%BACKEND_URL_FILE%"
if errorlevel 1 exit /b 1
"%TERRAFORM_BIN%" -chdir="%SCRIPT_DIR%\terraform" output -raw agent_url > "%AGENT_URL_FILE%"
if errorlevel 1 exit /b 1
set /p BACKEND_URL=<"%BACKEND_URL_FILE%"
set /p AGENT_URL=<"%AGENT_URL_FILE%"
del "%BACKEND_URL_FILE%" >nul 2>nul
del "%AGENT_URL_FILE%" >nul 2>nul

if "%BACKEND_URL%"=="" (
  echo No se pudo resolver backend_url
  exit /b 1
)
if "%AGENT_URL%"=="" (
  echo No se pudo resolver agent_url
  exit /b 1
)

echo ==^> Configuring Docker for Artifact Registry...
call gcloud auth configure-docker "%REGION%-docker.pkg.dev" --quiet
if errorlevel 1 (
  echo Aviso: gcloud devolvio un codigo de salida no cero al configurar Docker.
  echo Si el mensaje anterior dice que las credenciales ya estan registradas, continuamos.
)

echo ==^> Building frontend image %IMAGE_TAG%...
docker build ^
  --build-arg VITE_BACKEND_URL="%BACKEND_URL%" ^
  --build-arg VITE_AGENT_URL="%AGENT_URL%" ^
  -t "%REGISTRY%/frontend:%IMAGE_TAG%" ^
  -t "%REGISTRY%/frontend:latest" ^
  "%SCRIPT_DIR%\frontend"
if errorlevel 1 exit /b 1

echo ==^> Pushing frontend image...
docker push "%REGISTRY%/frontend:%IMAGE_TAG%"
if errorlevel 1 exit /b 1
docker push "%REGISTRY%/frontend:latest"
if errorlevel 1 exit /b 1

echo ==^> Deploying frontend Cloud Run service...
"%TERRAFORM_BIN%" -chdir="%SCRIPT_DIR%\terraform" apply -auto-approve ^
  -var="deploy_services=true" ^
  -var="deploy_backend=true" ^
  -var="deploy_frontend=true" ^
  -var="deploy_agent=true" ^
  -var="backend_image_tag=latest" ^
  -var="agent_image_tag=latest" ^
  -var="frontend_image_tag=%IMAGE_TAG%"
if errorlevel 1 exit /b 1

echo ==^> Frontend URL:
"%TERRAFORM_BIN%" -chdir="%SCRIPT_DIR%\terraform" output -raw frontend_url
echo.

endlocal
