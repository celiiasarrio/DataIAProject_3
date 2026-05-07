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

echo ==^> Configuring Docker for Artifact Registry...
call gcloud auth configure-docker "%REGION%-docker.pkg.dev" --quiet
if errorlevel 1 (
  echo Aviso: gcloud devolvio un codigo de salida no cero al configurar Docker.
  echo Si el mensaje anterior dice que las credenciales ya estan registradas, continuamos.
)

echo ==^> Building backend image %IMAGE_TAG%...
docker build -t "%REGISTRY%/backend:%IMAGE_TAG%" -t "%REGISTRY%/backend:latest" "%SCRIPT_DIR%\backend"
if errorlevel 1 exit /b 1

echo ==^> Pushing backend image...
docker push "%REGISTRY%/backend:%IMAGE_TAG%"
if errorlevel 1 exit /b 1
docker push "%REGISTRY%/backend:latest"
if errorlevel 1 exit /b 1

echo ==^> Deploying backend Cloud Run service...
"%TERRAFORM_BIN%" -chdir="%SCRIPT_DIR%\terraform" apply -auto-approve ^
  -var="deploy_services=true" ^
  -var="deploy_backend=true" ^
  -var="deploy_frontend=false" ^
  -var="deploy_agent=false" ^
  -var="backend_image_tag=%IMAGE_TAG%"
if errorlevel 1 exit /b 1

echo ==^> Backend URL:
"%TERRAFORM_BIN%" -chdir="%SCRIPT_DIR%\terraform" output -raw backend_url
echo.

endlocal
