#!/bin/bash

echo "=== Testing Todo API with Token ==="

# Get token
echo "1. Getting token..."
TOKEN=$(curl -s -X POST http://localhost:8081/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin"}' 2>&1)

if echo "$TOKEN" | grep -q "accessToken"; then
  TOKEN_VALUE=$(echo "$TOKEN" | sed 's/.*"accessToken":"\([^"]*\)".*/\1/')
  echo "✅ Token obtained: ${TOKEN_VALUE:0:40}..."
else
  echo "❌ Failed to get token"
  echo "$TOKEN"
  exit 1
fi

# Test GET /todos
echo ""
echo "2. Testing GET /todos..."
TODOS=$(curl -s -H "Authorization: Bearer $TOKEN_VALUE" http://localhost:8082/todos 2>&1)
echo "Response: $TODOS" | head -c 200

# Test POST /todos
echo ""
echo ""
echo "3. Testing POST /todos..."
POST_RESPONSE=$(curl -s -X POST http://localhost:8082/todos \
  -H "Authorization: Bearer $TOKEN_VALUE" \
  -H "Content-Type: application/json" \
  -d '{"content":"test task"}' 2>&1)
echo "Response: $POST_RESPONSE" | head -c 200

echo ""
echo ""
echo "Done!"
