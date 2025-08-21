#!/bin/bash

# Check if server is running
echo "Testing DigitalCourtServer API endpoints..."

# Server URL - change if testing remotely
BASE_URL=${1:-"http://localhost:8080"}

echo "Testing server at: $BASE_URL"
echo ""

# Test health check
echo "1. Testing health check endpoint..."
curl -s -X GET $BASE_URL/
echo -e "\n"

# Test hello endpoint
echo "2. Testing hello endpoint..."
curl -s -X GET $BASE_URL/hello
echo -e "\n"

# Test environment debug endpoint
echo "3. Testing environment debug endpoint..."
curl -s -X GET $BASE_URL/debug/env
echo -e "\n"

# Test database connection
echo "4. Testing database connection..."
curl -s -X GET $BASE_URL/db/test
echo -e "\n"

# Test health endpoint
echo "5. Testing health endpoint..."
curl -s -X GET $BASE_URL/health
echo -e "\n"

echo "Basic API testing completed!"
echo ""
echo "To test user registration and authentication, try these commands manually:"
echo ""
echo "Register a new user:"
echo "curl -X POST $BASE_URL/api/v1/users/register \\"
echo "     -H \"Content-Type: application/json\" \\"
echo "     -d '{"
echo "       \"username\": \"testuser\","
echo "       \"password\": \"securepassword123\","
echo "       \"displayName\": \"Test User\""
echo "     }'"
echo ""
echo "Login to get a JWT token:"
echo "curl -X POST $BASE_URL/api/v1/users/login \\"
echo "     -H \"Content-Type: application/json\" \\"
echo "     -d '{"
echo "       \"username\": \"testuser\","
echo "       \"password\": \"securepassword123\""
echo "     }'"
echo ""
echo "Use the token to access protected endpoints:"
echo "curl -X GET $BASE_URL/api/v1/users/me \\"
echo "     -H \"Authorization: Bearer YOUR_JWT_TOKEN_HERE\""
echo ""
