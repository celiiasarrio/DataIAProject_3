@echo off
setlocal

set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"

where terraform >nul 2>nul
if %ERRORLEVEL% EQU 0 (
  set "TERRAFORM_BIN=terraform"
) else (
  set "TERRAFORM_BIN=%SCRIPT_DIR%\terraform\terraform.exe"
)

set "DB_HOST_FILE=%TEMP%\dataia_db_host_%RANDOM%.txt"
"%TERRAFORM_BIN%" -chdir="%SCRIPT_DIR%\terraform" output -raw database_ip > "%DB_HOST_FILE%"
if errorlevel 1 exit /b 1
set /p DB_HOST=<"%DB_HOST_FILE%"
del "%DB_HOST_FILE%" >nul 2>nul

for /f "tokens=2 delims==" %%i in ('findstr /r /c:"^db_user" "%SCRIPT_DIR%\terraform\terraform.tfvars"') do set "DB_USER=%%~i"
for /f "tokens=2 delims==" %%i in ('findstr /r /c:"^db_password" "%SCRIPT_DIR%\terraform\terraform.tfvars"') do set "DB_PASSWORD=%%~i"
set "DB_USER=%DB_USER: =%"
set "DB_USER=%DB_USER:"=%"
set "DB_PASSWORD=%DB_PASSWORD: =%"
set "DB_PASSWORD=%DB_PASSWORD:"=%"

docker run --rm ^
  -e "PGPASSWORD=%DB_PASSWORD%" ^
  postgres:15-alpine ^
  psql -h "%DB_HOST%" -U "%DB_USER%" -d edem_hub_db -c "SELECT relname AS table_name, n_live_tup AS estimated_rows FROM pg_stat_user_tables ORDER BY relname;"

endlocal
