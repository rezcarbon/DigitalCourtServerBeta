# DigitalCourtServer

💧 A project built with the Vapor web framework for digital court proceedings.

## Getting Started

### Prerequisites
- Swift 5.10 or later
- Docker (for local development with MongoDB)

## Local Development

### Option 1: Using Docker (Recommended)

1. Make sure Docker is installed and running on your system
2. Start the services (MongoDB and the app):
```bash
docker-compose -f docker-compose.local.yml up
```

3. The server will be available at http://localhost:8080

4. To stop the services:
```bash
docker-compose -f docker-compose.local.yml down
```

### Option 2: Direct Local Development

If you prefer to run the app directly without Docker:

1. Install MongoDB locally:
   - On macOS with Homebrew:
     ```bash
     brew tap mongodb/brew
     brew install mongodb-community@6.0
     brew services start mongodb-community@6.0
     ```
   - Or download from [MongoDB Community Server](https://www.mongodb.com/try/download/community)

2. Create a `.env` file:
```bash
cp .env.example .env
```

3. Update the `.env` file with your MongoDB connection details if needed:
```env
# For a local MongoDB instance
DATABASE_URL=mongodb://localhost:27017/admin
JWT_SECRET=your-super-secret-jwt-key-minimum-32-characters
LOG_LEVEL=info
```

4. Build and run the project:
```bash
swift build
swift run
```

## DigitalOcean Deployment

This app is configured for deployment to DigitalOcean App Platform.

### Environment Variables

When deploying to DigitalOcean, set these environment variables in the App Platform dashboard:

- `JWT_SECRET` - A strong secret key (minimum 32 characters)
- `LOG_LEVEL` - (Optional) Log level (debug, info, warning, error)

The `DATABASE_URL` is automatically configured through the DigitalOcean database connection.

### Database Configuration

The app uses a MongoDB database cluster. Make sure to:

1. Add your app's IP to the database cluster's trusted sources
2. Verify that the database cluster is in the same region as your app
3. Check that the connection details in `.do/app.yaml` are correct

## Testing the API

You can test the API endpoints with the provided script:
```bash
./test-api.sh
```

Or manually with curl:

1. Register a new user:
```bash
curl -X POST http://localhost:8080/api/v1/users/register \
     -H "Content-Type: application/json" \
     -d '{
       "username": "testuser",
       "password": "securepassword123",
       "displayName": "Test User"
     }'
```

2. Login to get a JWT token:
```bash
curl -X POST http://localhost:8080/api/v1/users/login \
     -H "Content-Type: application/json" \
     -d '{
       "username": "testuser",
       "password": "securepassword123"
     }'
```

3. Use the token to access protected endpoints:
```bash
curl -X GET http://localhost:8080/api/v1/users/me \
     -H "Authorization: Bearer YOUR_JWT_TOKEN_HERE"
```

## Useful Endpoints

- `GET /` - Health check
- `GET /hello` - Simple test endpoint
- `GET /health` - Detailed health check
- `GET /db/test` - Database connection test
- `GET /debug/env` - Environment variables check
- `POST /api/v1/users/register` - User registration
- `POST /api/v1/users/login` - User login
- `GET /api/v1/users/me` - Get user profile (JWT protected)

## Troubleshooting Database Issues

If you encounter "Connection Refused" errors:

1. Check that your MongoDB instance is running
2. Verify the connection string format
3. Ensure your IP is in the database's list of trusted sources
4. Check that the database and app are in the same region (for DigitalOcean)
5. Verify network/firewall settings

### See more

- [Vapor Website](https://vapor.codes)
- [Vapor Documentation](https://docs.vapor.codes)
- [Vapor GitHub](https://github.com/vapor)
- [Vapor Community](https://github.com/vapor-community)