@echo off
setlocal

set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
set "PROJECT_ID=project3grupo6"
set "REGION=europe-west1"
set "REGISTRY=%REGION%-docker.pkg.dev/%PROJECT_ID%/docker-repo"
set "BACKEND_SERVICE=%PROJECT_ID%-backend"
set "AGENT_SERVICE=%PROJECT_ID%-agent"
for /f "usebackq delims=" %%i in (`powershell -NoProfile -Command "Get-Date -Format yyyyMMddHHmmss"`) do set "IMAGE_TAG=%%i"
set "FRONTEND_FINAL_TAG=%IMAGE_TAG%-final"

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

echo ==^> Using Terraform: "%TERRAFORM_BIN%"

echo ==^> Creating Artifact Registry (if not exists)...
"%TERRAFORM_BIN%" -chdir="%SCRIPT_DIR%\terraform" init
if errorlevel 1 exit /b 1
"%TERRAFORM_BIN%" -chdir="%SCRIPT_DIR%\terraform" apply -target=google_artifact_registry_repository.docker -auto-approve
if errorlevel 1 exit /b 1

echo ==^> Building backend image...
docker build -t "%REGISTRY%/backend:%IMAGE_TAG%" -t "%REGISTRY%/backend:latest" "%SCRIPT_DIR%\backend"
if errorlevel 1 exit /b 1

echo ==^> Pushing backend image...
docker push "%REGISTRY%/backend:%IMAGE_TAG%"
if errorlevel 1 exit /b 1
docker push "%REGISTRY%/backend:latest"
if errorlevel 1 exit /b 1

echo ==^> Building agent image...
docker build -t "%REGISTRY%/agent:%IMAGE_TAG%" -t "%REGISTRY%/agent:latest" "%SCRIPT_DIR%\agent"
if errorlevel 1 exit /b 1

echo ==^> Pushing agent image...
docker push "%REGISTRY%/agent:%IMAGE_TAG%"
if errorlevel 1 exit /b 1
docker push "%REGISTRY%/agent:latest"
if errorlevel 1 exit /b 1

echo ==^> Building frontend image...
docker build -t "%REGISTRY%/frontend:%IMAGE_TAG%" -t "%REGISTRY%/frontend:latest" "%SCRIPT_DIR%\frontend"
if errorlevel 1 exit /b 1

echo ==^> Pushing frontend image...
docker push "%REGISTRY%/frontend:%IMAGE_TAG%"
if errorlevel 1 exit /b 1
docker push "%REGISTRY%/frontend:latest"
if errorlevel 1 exit /b 1

echo ==^> Deploying infrastructure...
"%TERRAFORM_BIN%" -chdir="%SCRIPT_DIR%\terraform" apply -auto-approve -var="deploy_services=true" -var="backend_image_tag=%IMAGE_TAG%" -var="agent_image_tag=%IMAGE_TAG%" -var="frontend_image_tag=%IMAGE_TAG%"
if errorlevel 1 exit /b 1

if "%LOAD_DB%"=="1" (
  echo ==^> Resolving database connection...
  set "DB_HOST_FILE=%TEMP%\dataia_db_host_%RANDOM%.txt"
  set "DB_NAME_FILE=%TEMP%\dataia_db_name_%RANDOM%.txt"
  "%TERRAFORM_BIN%" -chdir="%SCRIPT_DIR%\terraform" output -raw database_ip > "%DB_HOST_FILE%"
  if errorlevel 1 exit /b 1
  "%TERRAFORM_BIN%" -chdir="%SCRIPT_DIR%\terraform" output -raw database_name > "%DB_NAME_FILE%"
  if errorlevel 1 exit /b 1
  set /p DB_HOST=<"%DB_HOST_FILE%"
  set /p DB_NAME=<"%DB_NAME_FILE%"
  del "%DB_HOST_FILE%" >nul 2>nul
  del "%DB_NAME_FILE%" >nul 2>nul

  for /f "tokens=2 delims==" %%i in ('findstr /r /c:"^db_user" "%SCRIPT_DIR%\terraform\terraform.tfvars"') do set "DB_USER=%%~i"
  for /f "tokens=2 delims==" %%i in ('findstr /r /c:"^db_password" "%SCRIPT_DIR%\terraform\terraform.tfvars"') do set "DB_PASSWORD=%%~i"
  set "DB_USER=%DB_USER: =%"
  set "DB_USER=%DB_USER:"=%"
  set "DB_PASSWORD=%DB_PASSWORD: =%"
  set "DB_PASSWORD=%DB_PASSWORD:"=%"

  if "%DB_HOST%"=="" (
    echo No se pudo resolver la IP de Cloud SQL
    exit /b 1
  )
  if "%DB_USER%"=="" (
    echo No se pudo leer db_user desde terraform\terraform.tfvars
    exit /b 1
  )
  if "%DB_PASSWORD%"=="" (
    echo No se pudo leer db_password desde terraform\terraform.tfvars
    exit /b 1
  )

  echo ==^> Loading database schema and data with Docker postgres client...
  echo Aviso: db\datos.sql hace TRUNCATE de tablas antes de insertar datos.
  docker run --rm ^
    -e "PGPASSWORD=%DB_PASSWORD%" ^
    -v "%SCRIPT_DIR%\db:/db:ro" ^
    postgres:15-alpine ^
    sh -c "psql -h %DB_HOST% -U %DB_USER% -d %DB_NAME% -f /db/esquema.sql && psql -h %DB_HOST% -U %DB_USER% -d %DB_NAME% -f /db/datos.sql"
  if errorlevel 1 exit /b 1
) else (
  echo ==^> Skipping database seed. Set LOAD_DB=1 to reload db\datos.sql intentionally.
)

echo ==^> Resolving deployed service URLs...
for /f "usebackq delims=" %%i in (`call gcloud run services describe "%BACKEND_SERVICE%" --region "%REGION%" --format "value(status.url)"`) do set "BACKEND_URL=%%i"
if errorlevel 1 exit /b 1
for /f "usebackq delims=" %%i in (`call gcloud run services describe "%AGENT_SERVICE%" --region "%REGION%" --format "value(status.url)"`) do set "AGENT_URL=%%i"
if errorlevel 1 exit /b 1

if "%BACKEND_URL%"=="" (
  echo No se pudo resolver la URL del backend
  exit /b 1
)
if "%AGENT_URL%"=="" (
  echo No se pudo resolver la URL del agente
  exit /b 1
)

echo ==^> Rebuilding frontend image with backend and agent URLs...
docker build ^
  --build-arg VITE_BACKEND_URL="%BACKEND_URL%" ^
  --build-arg VITE_AGENT_URL="%AGENT_URL%" ^
  -t "%REGISTRY%/frontend:%FRONTEND_FINAL_TAG%" ^
  -t "%REGISTRY%/frontend:latest" ^
  "%SCRIPT_DIR%\frontend"
if errorlevel 1 exit /b 1

echo ==^> Pushing rebuilt frontend image...
docker push "%REGISTRY%/frontend:%FRONTEND_FINAL_TAG%"
if errorlevel 1 exit /b 1
docker push "%REGISTRY%/frontend:latest"
if errorlevel 1 exit /b 1

echo ==^> Refreshing infrastructure with the final frontend image...
"%TERRAFORM_BIN%" -chdir="%SCRIPT_DIR%\terraform" apply -auto-approve -var="deploy_services=true" -var="backend_image_tag=%IMAGE_TAG%" -var="agent_image_tag=%IMAGE_TAG%" -var="frontend_image_tag=%FRONTEND_FINAL_TAG%"
if errorlevel 1 exit /b 1

echo ==^> Done!
"%TERRAFORM_BIN%" -chdir="%SCRIPT_DIR%\terraform" output frontend_url

endlocal
