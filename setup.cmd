@echo off
setlocal EnableExtensions
cd /d "%~dp0"

if "%~1"=="" goto help
if /i "%~1"=="help" goto help
if /i "%~1"=="-h" goto help
if /i "%~1"=="--help" goto help
if /i "%~1"=="init" goto init
if /i "%~1"=="commit" goto commit

echo [ERROR] Unknown command: %~1
echo.
goto usage_error

:init
where node >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Node.js is required but was not found in PATH. 1>&2
    exit /b 1
)

where npm.cmd >nul 2>&1
if errorlevel 1 (
    echo [ERROR] npm is required but was not found in PATH. 1>&2
    exit /b 1
)

echo Installing dependencies...
call npm.cmd install
if errorlevel 1 (
    echo [ERROR] npm install failed. 1>&2
    exit /b 1
)

echo Fixing npm audit issues...
call npm.cmd audit fix
if errorlevel 1 (
    echo [ERROR] npm audit fix failed. 1>&2
    exit /b 1
)

if not exist ".env.example" (
    echo [ERROR] .env.example was not found; .env was not created. 1>&2
    exit /b 1
)

if exist ".env" (
    echo .env already exists; it was not overwritten.
) else (
    copy /y ".env.example" ".env" >nul
    if errorlevel 1 (
        echo [ERROR] Could not create .env. 1>&2
        exit /b 1
    )
    echo Created .env from .env.example.
)

echo Project initialization complete.
exit /b 0

:commit
where git >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Git is required but was not found in PATH. 1>&2
    exit /b 1
)

set "COMMIT_MESSAGE="
set /p "COMMIT_MESSAGE=Commit message: "
if not defined COMMIT_MESSAGE (
    echo [ERROR] Commit message cannot be empty. 1>&2
    exit /b 1
)

git add .
if errorlevel 1 (
    echo [ERROR] git add failed. 1>&2
    exit /b 1
)

git commit -m "%COMMIT_MESSAGE%"
if errorlevel 1 (
    echo [ERROR] git commit failed. 1>&2
    exit /b 1
)

git push
if errorlevel 1 (
    echo [ERROR] git push failed. 1>&2
    exit /b 1
)

exit /b 0

:help
echo Under the Same Sky - Command Prompt setup helper
echo.
echo Usage:
echo   setup.cmd ^<command^>
echo.
echo Commands:
echo   init     Install dependencies, fix npm audit issues, and create .env
echo   commit   Prompt for a message, stage all changes, commit, and push
echo   help     Show this help
echo.
echo Examples:
echo   setup.cmd init
echo   setup.cmd commit
echo   setup.cmd help
echo.
echo Requirements:
echo   - Node.js and npm for the init command
echo   - Git for the commit command
exit /b 0

:usage_error
echo Usage: setup.cmd ^<init^|commit^|help^>
echo   init    Install dependencies, fix audit issues, and create .env
echo   commit  Stage, commit, and push all changes
echo   help    Show this help
exit /b 1
