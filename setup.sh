#!/bin/bash

# BerkAI Project Setup Script
# This script helps new team members set up the project quickly

echo "🎉 Welcome to BerkAI Setup!"
echo "=============================="
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if commands exist
check_command() {
    if ! command -v "$1" &> /dev/null; then
        echo -e "${RED}❌ $1 is not installed${NC}"
        return 1
    else
        echo -e "${GREEN}✓ $1 is installed${NC}"
        return 0
    fi
}

# Step 1: Check prerequisites
echo "📋 Step 1: Checking prerequisites..."
echo "-----------------------------------"

prerequisites_ok=true

if ! check_command "dotnet"; then
    echo -e "${YELLOW}Please install .NET 9 SDK from: https://dotnet.microsoft.com/download${NC}"
    prerequisites_ok=false
fi

if ! check_command "node"; then
    echo -e "${YELLOW}Please install Node.js from: https://nodejs.org/${NC}"
    prerequisites_ok=false
fi

if ! check_command "git"; then
    echo -e "${YELLOW}Please install Git from: https://git-scm.com/${NC}"
    prerequisites_ok=false
fi

if [ "$prerequisites_ok" = false ]; then
    echo -e "${RED}Please install missing prerequisites and run this script again.${NC}"
    exit 1
fi

echo ""

# Step 2: Backend setup
echo "🔧 Step 2: Setting up Backend (.NET)..."
echo "--------------------------------------"

if [ ! -d "backend" ]; then
    echo -e "${RED}❌ backend directory not found${NC}"
    echo "Please run this script from the project root directory."
    exit 1
fi

cd backend

echo "Restoring backend dependencies..."
if dotnet restore; then
    echo -e "${GREEN}✓ Backend dependencies restored${NC}"
else
    echo -e "${RED}❌ Failed to restore backend dependencies${NC}"
    exit 1
fi

# Check if appsettings.Development.json exists
if [ ! -f "src/FashionEcommerce.WebAPI/appsettings.Development.json" ]; then
    echo -e "${YELLOW}⚠ appsettings.Development.json not found${NC}"
    echo "Creating from example file..."
    if [ -f "appsettings.Development.json.example" ]; then
        cp appsettings.Development.json.example src/FashionEcommerce.WebAPI/appsettings.Development.json
        echo -e "${GREEN}✓ Created appsettings.Development.json${NC}"
        echo -e "${YELLOW}⚠ Please edit backend/src/FashionEcommerce.WebAPI/appsettings.Development.json with your settings${NC}"
    fi
fi

cd ..
echo ""

# Step 3: Frontend setup
echo "⚛️  Step 3: Setting up Frontend (Next.js)..."
echo "-------------------------------------------"

if [ ! -d "frontend" ]; then
    echo -e "${RED}❌ frontend directory not found${NC}"
    echo "Please run this script from the project root directory."
    exit 1
fi

cd frontend

echo "Installing frontend dependencies (this may take a few minutes)..."
if npm install; then
    echo -e "${GREEN}✓ Frontend dependencies installed${NC}"
else
    echo -e "${RED}❌ Failed to install frontend dependencies${NC}"
    exit 1
fi

# Check if .env.local exists
if [ ! -f ".env.local" ]; then
    echo -e "${YELLOW}⚠ .env.local not found${NC}"
    echo "Creating from example file..."
    if [ -f ".env.example" ]; then
        cp .env.example .env.local
        echo -e "${GREEN}✓ Created .env.local${NC}"
        echo -e "${YELLOW}⚠ Please edit frontend/.env.local with your settings${NC}"
    fi
fi

cd ..
echo ""

# Step 4: Summary
echo "✅ Setup Complete!"
echo "=================="
echo ""
echo "Next steps:"
echo ""
echo "1. Configure your environment variables:"
echo "   - Backend: backend/src/FashionEcommerce.WebAPI/appsettings.Development.json"
echo "   - Frontend: frontend/.env.local"
echo ""
echo "2. Set up your database:"
echo "   cd backend/src/FashionEcommerce.WebAPI"
echo "   dotnet ef database update"
echo ""
echo "3. Start the backend (in one terminal):"
echo "   cd backend/src/FashionEcommerce.WebAPI"
echo "   dotnet watch run"
echo ""
echo "4. Start the frontend (in another terminal):"
echo "   cd frontend"
echo "   npm run dev"
echo ""
echo "5. Open your browser:"
echo "   http://localhost:3000"
echo ""
echo "📚 For more information, check:"
echo "   - README.md - Project overview"
echo "   - CONTRIBUTING.md - How to contribute"
echo "   - YENI_UYES_REHBERI.md - Turkish setup guide"
echo ""
echo "Happy coding! 🚀"
