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

echo This will destroy Terraform-managed resources in project3grupo6.
echo It does not delete the remote tfstate bucket itself.
set /p CONFIRM=Type DESTROY project3grupo6 to continue: 
if not "%CONFIRM%"=="DESTROY project3grupo6" (
  echo Cancelled.
  exit /b 1
)

echo ==^> Initializing Terraform...
"%TERRAFORM_BIN%" -chdir="%SCRIPT_DIR%\terraform" init
if errorlevel 1 exit /b 1

echo ==^> Destroying Cloud resources managed by Terraform...
"%TERRAFORM_BIN%" -chdir="%SCRIPT_DIR%\terraform" destroy -auto-approve
if errorlevel 1 exit /b 1

echo ==^> Destroy complete.

endlocal
