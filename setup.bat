@echo off
REM BerkAI Project Setup Script for Windows
REM This script helps new team members set up the project quickly

echo ==============================
echo Welcome to BerkAI Setup!
echo ==============================
echo.

REM Step 1: Check prerequisites
echo Step 1: Checking prerequisites...
echo -----------------------------------

set prerequisites_ok=1

where dotnet >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [X] dotnet is not installed
    echo Please install .NET 9 SDK from: https://dotnet.microsoft.com/download
    set prerequisites_ok=0
) else (
    echo [OK] dotnet is installed
)

where node >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [X] node is not installed
    echo Please install Node.js from: https://nodejs.org/
    set prerequisites_ok=0
) else (
    echo [OK] node is installed
)

where git >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [X] git is not installed
    echo Please install Git from: https://git-scm.com/
    set prerequisites_ok=0
) else (
    echo [OK] git is installed
)

if %prerequisites_ok%==0 (
    echo.
    echo Please install missing prerequisites and run this script again.
    pause
    exit /b 1
)

echo.

REM Step 2: Backend setup
echo Step 2: Setting up Backend (.NET)...
echo --------------------------------------

if not exist "backend" (
    echo [X] backend directory not found
    echo Please run this script from the project root directory.
    pause
    exit /b 1
)

cd backend

echo Restoring backend dependencies...
dotnet restore
if %ERRORLEVEL% NEQ 0 (
    echo [X] Failed to restore backend dependencies
    cd ..
    pause
    exit /b 1
)
echo [OK] Backend dependencies restored

REM Check if appsettings.Development.json exists
if not exist "src\FashionEcommerce.WebAPI\appsettings.Development.json" (
    echo [!] appsettings.Development.json not found
    echo Creating from example file...
    if exist "appsettings.Development.json.example" (
        copy appsettings.Development.json.example src\FashionEcommerce.WebAPI\appsettings.Development.json
        echo [OK] Created appsettings.Development.json
        echo [!] Please edit backend\src\FashionEcommerce.WebAPI\appsettings.Development.json with your settings
    )
)

cd ..
echo.

REM Step 3: Frontend setup
echo Step 3: Setting up Frontend (Next.js)...
echo -------------------------------------------

if not exist "frontend" (
    echo [X] frontend directory not found
    echo Please run this script from the project root directory.
    pause
    exit /b 1
)

cd frontend

echo Installing frontend dependencies (this may take a few minutes)...
call npm install
if %ERRORLEVEL% NEQ 0 (
    echo [X] Failed to install frontend dependencies
    cd ..
    pause
    exit /b 1
)
echo [OK] Frontend dependencies installed

REM Check if .env.local exists
if not exist ".env.local" (
    echo [!] .env.local not found
    echo Creating from example file...
    if exist ".env.example" (
        copy .env.example .env.local
        echo [OK] Created .env.local
        echo [!] Please edit frontend\.env.local with your settings
    )
)

cd ..
echo.

REM Step 4: Summary
echo ==================
echo Setup Complete!
echo ==================
echo.
echo Next steps:
echo.
echo 1. Configure your environment variables:
echo    - Backend: backend\src\FashionEcommerce.WebAPI\appsettings.Development.json
echo    - Frontend: frontend\.env.local
echo.
echo 2. Set up your database:
echo    cd backend\src\FashionEcommerce.WebAPI
echo    dotnet ef database update
echo.
echo 3. Start the backend (in one terminal):
echo    cd backend\src\FashionEcommerce.WebAPI
echo    dotnet watch run
echo.
echo 4. Start the frontend (in another terminal):
echo    cd frontend
echo    npm run dev
echo.
echo 5. Open your browser:
echo    http://localhost:3000
echo.
echo For more information, check:
echo    - README.md - Project overview
echo    - CONTRIBUTING.md - How to contribute
echo    - YENI_UYES_REHBERI.md - Turkish setup guide
echo.
echo Happy coding!
echo.
pause
