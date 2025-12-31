# BerkAI Backend Configuration

This directory contains example configuration files for the BerkAI backend.

## Setup Instructions

1. Copy `appsettings.Development.json.example` to `src/FashionEcommerce.WebAPI/appsettings.Development.json`:
   ```bash
   cp appsettings.Development.json.example src/FashionEcommerce.WebAPI/appsettings.Development.json
   ```

2. Edit `src/FashionEcommerce.WebAPI/appsettings.Development.json` with your actual values:

### Configuration Values

#### ConnectionStrings
- **DefaultConnection**: Your database connection string
  - For SQL Server: `Server=localhost;Database=BerkAI;Trusted_Connection=True;TrustServerCertificate=True;`
  - For PostgreSQL: `Host=localhost;Database=BerkAI;Username=your_username;Password=your_password`

#### JwtSettings
- **SecretKey**: A secure random string (minimum 32 characters)
  - Generate one using: `openssl rand -base64 32` (on Linux/Mac)
  - Or use an online generator
- **Issuer**: Keep as "BerkAI"
- **Audience**: Keep as "BerkAI-Users"
- **ExpirationMinutes**: Token expiration time (60 minutes is default)

#### GoogleAuth
- **ClientId**: Your Google OAuth 2.0 Client ID
  - Get this from: https://console.cloud.google.com/
  - Create a new OAuth 2.0 Client ID in the Credentials section
  - Set authorized redirect URIs appropriately

#### Cors
- **AllowedOrigins**: List of allowed frontend origins
  - Development: `["http://localhost:3000", "https://localhost:3000"]`
  - Production: Add your production frontend URL

## Security Notes

- **Never commit** `appsettings.Development.json` to git (it's in .gitignore)
- Keep your **SecretKey** secure and random
- Use environment variables or Azure Key Vault for production secrets
- Rotate secrets regularly

## Database Setup

After configuring the connection string, run migrations:

```bash
cd src/FashionEcommerce.WebAPI
dotnet ef database update
```

## Troubleshooting

### "Cannot connect to database"
- Verify your database server is running
- Check the connection string syntax
- Ensure the database user has proper permissions

### "JWT token validation failed"
- Ensure SecretKey is at least 32 characters
- Verify Issuer and Audience match in both backend and frontend

### "Google authentication failed"
- Verify ClientId is correct
- Check that redirect URIs are properly configured in Google Console
- Ensure the frontend URL is in the Cors AllowedOrigins list
