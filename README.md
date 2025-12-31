# 🛍️ BerkAI - AI-Powered Fashion E-Commerce Platform

BerkAI is a modern fashion e-commerce platform with integrated AI-powered virtual try-on capabilities, enabling customers to visualize how clothing items will look on them before making a purchase.

## 🌟 Features

- **Full-Stack E-Commerce**: Complete shopping experience with product browsing, cart management, and checkout
- **AI Virtual Try-On**: Powered by HR-VITON for realistic clothing visualization
- **Modern Tech Stack**: .NET 9 backend with Next.js 16 frontend
- **Google Authentication**: Secure OAuth2 integration
- **Responsive Design**: Mobile-first approach with Tailwind CSS
- **State Management**: Zustand for efficient client-side state
- **Type-Safe**: Full TypeScript implementation on frontend

## 🏗️ Architecture

```
BerkAI/
├── backend/              # .NET 9 Web API
│   └── src/
│       ├── FashionEcommerce.Domain/         # Domain models and entities
│       ├── FashionEcommerce.Application/    # Business logic and services
│       ├── FashionEcommerce.Infrastructure/ # Data access and external services
│       └── FashionEcommerce.WebAPI/         # API endpoints and controllers
├── frontend/             # Next.js 16 React application
│   ├── app/              # App router pages
│   ├── components/       # Reusable React components
│   ├── lib/              # Utilities, API clients, and stores
│   └── public/           # Static assets
└── HR_VITON_*           # AI virtual try-on system
```

## 🚀 Quick Start

### Prerequisites

Before you begin, ensure you have the following installed:

- **Backend**:
  - [.NET 9 SDK](https://dotnet.microsoft.com/download/dotnet/9.0) (required)
  - [SQL Server](https://www.microsoft.com/sql-server) or [PostgreSQL](https://www.postgresql.org/) (for database)
  
- **Frontend**:
  - [Node.js](https://nodejs.org/) v18 or higher
  - [npm](https://www.npmjs.com/), [yarn](https://yarnpkg.com/), or [pnpm](https://pnpm.io/)

- **AI/ML** (optional, for virtual try-on):
  - Python 3.8+
  - CUDA-capable GPU (recommended)
  - Google Colab account (for training)

### 1️⃣ Clone the Repository

```bash
git clone https://github.com/bberkaysari/BerkAI.git
cd BerkAI
```

### 2️⃣ Backend Setup (.NET)

```bash
# Navigate to backend directory
cd backend

# Restore dependencies
dotnet restore

# Update database connection string in appsettings.json
# (Create appsettings.Development.json for local settings)

# Apply database migrations
cd src/FashionEcommerce.WebAPI
dotnet ef database update

# Run the API
dotnet run
```

The API will be available at `https://localhost:5001` (or the port specified in launchSettings.json)

### 3️⃣ Frontend Setup (Next.js)

```bash
# Navigate to frontend directory (from project root)
cd frontend

# Install dependencies
npm install
# or
yarn install
# or
pnpm install

# Create .env.local file with required environment variables
# (See .env.example if available, or check documentation)

# Run development server
npm run dev
# or
yarn dev
# or
pnpm dev
```

The application will be available at `http://localhost:3000`

### 4️⃣ Environment Variables

#### Backend (`backend/src/FashionEcommerce.WebAPI/appsettings.Development.json`)

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Your database connection string"
  },
  "JwtSettings": {
    "SecretKey": "your-secret-key-here",
    "Issuer": "BerkAI",
    "Audience": "BerkAI-Users",
    "ExpirationMinutes": 60
  },
  "GoogleAuth": {
    "ClientId": "your-google-client-id"
  }
}
```

#### Frontend (`frontend/.env.local`)

```env
NEXT_PUBLIC_API_URL=http://localhost:5000
NEXT_PUBLIC_GOOGLE_CLIENT_ID=your-google-client-id
```

## 📚 Development

### Backend Development

```bash
# Run in watch mode (auto-reload on changes)
cd backend/src/FashionEcommerce.WebAPI
dotnet watch run

# Run tests (if available)
dotnet test

# Create new migration
dotnet ef migrations add MigrationName

# Build for production
dotnet build --configuration Release
```

### Frontend Development

```bash
cd frontend

# Run development server with hot reload
npm run dev

# Run linter
npm run lint

# Build for production
npm run build

# Start production server
npm run start
```

### Database Management

The project uses Entity Framework Core for database management.

```bash
# Add a new migration
cd backend/src/FashionEcommerce.WebAPI
dotnet ef migrations add YourMigrationName

# Update database
dotnet ef database update

# Rollback to previous migration
dotnet ef database update PreviousMigrationName

# Remove last migration (if not applied)
dotnet ef migrations remove
```

## 🤖 AI Virtual Try-On Setup

For detailed instructions on setting up and training the HR-VITON virtual try-on model, see [HR_VITON_README.md](./HR_VITON_README.md).

Quick overview:
1. The system uses HR-VITON for high-resolution virtual try-on
2. Training requires Google Colab Pro+ and significant compute resources
3. The inference server (`HR_VITON_Inference_Server.py`) can be integrated with the backend

## 🧪 Testing

### Backend Tests
```bash
cd backend
dotnet test
```

### Frontend Tests
```bash
cd frontend
npm test
# or
yarn test
```

## 📖 Documentation

- **Backend API Documentation**: Available at `/swagger` when running the API
- **HR-VITON Setup**: See [HR_VITON_README.md](./HR_VITON_README.md)
- **Contributing Guidelines**: See [CONTRIBUTING.md](./CONTRIBUTING.md)

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](./CONTRIBUTING.md) for details on:

- Code of conduct
- Development workflow
- Coding standards
- Pull request process
- Testing requirements

## 📦 Technology Stack

### Backend
- **.NET 9**: Modern C# web framework
- **Entity Framework Core**: ORM for database access
- **JWT Authentication**: Secure token-based auth
- **Google Auth**: OAuth2 integration
- **Clean Architecture**: Domain-driven design

### Frontend
- **Next.js 16**: React framework with App Router
- **React 19**: Latest React features
- **TypeScript**: Type-safe development
- **Tailwind CSS 4**: Utility-first styling
- **Zustand**: Lightweight state management
- **React Query**: Server state management
- **Axios**: HTTP client
- **React Hook Form**: Form validation
- **Zod**: Schema validation

### AI/ML
- **HR-VITON**: High-resolution virtual try-on
- **PyTorch**: Deep learning framework
- **SAM (Segment Anything)**: Advanced segmentation
- **MediaPipe**: Face detection and normalization

## 🔒 Security

- All API endpoints are protected with JWT authentication
- Google OAuth2 integration for secure login
- Environment variables for sensitive configuration
- Input validation on both client and server
- SQL injection prevention through EF Core parameterization

## 🚢 Deployment

### Backend
```bash
cd backend
dotnet publish -c Release -o ./publish
# Deploy the contents of ./publish to your server
```

### Frontend
```bash
cd frontend
npm run build
# Deploy using Vercel, Netlify, or your preferred platform
```

For detailed deployment instructions, see the deployment documentation in each respective directory.

## 📝 License

[Add your license information here]

## 👥 Team

Created and maintained by the BerkAI team.

## 📞 Support

For questions, issues, or contributions:
- Create an issue in the GitHub repository
- Contact the development team
- Check existing documentation

## 🎯 Roadmap

- [ ] Complete AI virtual try-on integration
- [ ] Add payment gateway integration
- [ ] Implement order tracking system
- [ ] Add product reviews and ratings
- [ ] Mobile application (React Native)
- [ ] Admin dashboard enhancements
- [ ] Performance optimizations
- [ ] Multi-language support

## 🙏 Acknowledgments

- HR-VITON team for the virtual try-on model
- Next.js team for the excellent framework
- .NET community for robust tools and libraries

---

**Built with ❤️ by the BerkAI team**
