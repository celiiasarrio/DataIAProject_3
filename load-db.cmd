@echo off
setlocal

set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"

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

echo This will load db\esquema.sql and db\datos.sql into Cloud SQL.
echo Warning: db\datos.sql truncates application tables before inserting seed data.
set /p CONFIRM=Type LOAD DB to continue: 
if not "%CONFIRM%"=="LOAD DB" (
  echo Cancelled.
  exit /b 1
)

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

echo ==^> Loading schema and seed data into %DB_NAME% at %DB_HOST%...
docker run --rm ^
  -e "PGPASSWORD=%DB_PASSWORD%" ^
  -v "%SCRIPT_DIR%\db:/db:ro" ^
  postgres:15-alpine ^
  sh -c "psql -h %DB_HOST% -U %DB_USER% -d %DB_NAME% -v ON_ERROR_STOP=1 -f /db/esquema.sql && psql -h %DB_HOST% -U %DB_USER% -d %DB_NAME% -v ON_ERROR_STOP=1 -f /db/datos.sql"
if errorlevel 1 exit /b 1

echo ==^> Database loaded.

endlocal
