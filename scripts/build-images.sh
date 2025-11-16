#!/bin/bash

# Development helper script for building and loading Docker images

set -e

echo "🔨 Building all Docker images..."

# Build all service images
echo "Building auth-api..."
cd services/auth-api && docker build -t auth-api:latest . && cd ../..

echo "Building todos-api..." 
cd services/todos-api && docker build -t todos-api:redis-real . && cd ../..

echo "Building users-api..."
cd services/users-api && docker build -t users-api:latest . && cd ../..

echo "Building log-processor..."
cd services/log-processor && docker build -t log-message-processor:latest . && cd ../..

echo "Building frontend..."
cd services/frontend && docker build -t todo-frontend:delete-fix . && cd ../..

echo "📦 Loading images into Minikube..."

# Load all images into minikube
minikube image load auth-api:latest
minikube image load todos-api:redis-real  
minikube image load users-api:latest
minikube image load log-message-processor:latest
minikube image load todo-frontend:delete-fix

echo "✅ All images built and loaded!"
echo ""
echo "🚀 Ready to deploy with:"
echo "   ./scripts/deploy.sh"