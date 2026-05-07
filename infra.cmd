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

echo ==^> Initializing Terraform...
"%TERRAFORM_BIN%" -chdir="%SCRIPT_DIR%\terraform" init
if errorlevel 1 exit /b 1

echo ==^> Applying base infrastructure only...
"%TERRAFORM_BIN%" -chdir="%SCRIPT_DIR%\terraform" apply -auto-approve -var="deploy_services=false"
if errorlevel 1 exit /b 1

echo ==^> Base infrastructure ready.
"%TERRAFORM_BIN%" -chdir="%SCRIPT_DIR%\terraform" output

endlocal
