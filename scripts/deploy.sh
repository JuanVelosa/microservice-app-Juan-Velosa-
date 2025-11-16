#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Starting microservice deployment to Kubernetes...${NC}"

# Get the project directory
PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Configure Docker to use Minikube's Docker daemon
echo -e "${YELLOW}Configuring Docker to use Minikube...${NC}"
eval $(minikube docker-env)

# Build all Docker images
echo -e "${YELLOW}Building Docker images...${NC}"

services=("users-api" "auth-api" "todos-api" "log-message-processor" "frontend")

for service in "${services[@]}"; do
    echo -e "${YELLOW}Building ${service}...${NC}"
    docker build -t ${service}:latest "${PROJECT_DIR}/${service}"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ ${service} built successfully${NC}"
    else
        echo -e "${RED}✗ Failed to build ${service}${NC}"
        exit 1
    fi
done

# Apply Kubernetes manifests
echo -e "${YELLOW}Applying Kubernetes manifests...${NC}"

# Create namespace and resources
kubectl apply -f "${PROJECT_DIR}/k8s/01-namespace.yaml"
kubectl apply -f "${PROJECT_DIR}/k8s/02-configmap.yaml"
kubectl apply -f "${PROJECT_DIR}/k8s/03-redis.yaml"
kubectl apply -f "${PROJECT_DIR}/k8s/04-zipkin.yaml"
kubectl apply -f "${PROJECT_DIR}/k8s/05-users-api.yaml"
kubectl apply -f "${PROJECT_DIR}/k8s/06-auth-api.yaml"
kubectl apply -f "${PROJECT_DIR}/k8s/07-todos-api.yaml"
kubectl apply -f "${PROJECT_DIR}/k8s/08-log-processor.yaml"
kubectl apply -f "${PROJECT_DIR}/k8s/09-frontend.yaml"

echo -e "${GREEN}✓ All manifests applied${NC}"

# Wait for deployments to be ready
echo -e "${YELLOW}Waiting for deployments to be ready...${NC}"
kubectl wait --for=condition=available --timeout=300s deployment/users-api -n microservices || true
kubectl wait --for=condition=available --timeout=300s deployment/auth-api -n microservices || true
kubectl wait --for=condition=available --timeout=300s deployment/todos-api -n microservices || true
kubectl wait --for=condition=available --timeout=300s deployment/frontend -n microservices || true
kubectl wait --for=condition=available --timeout=300s deployment/redis -n microservices || true
kubectl wait --for=condition=available --timeout=300s deployment/zipkin -n microservices || true

# Show deployment status
echo -e "${YELLOW}Deployment Status:${NC}"
kubectl get deployments -n microservices
echo -e "${YELLOW}Services:${NC}"
kubectl get services -n microservices

# Get frontend URL
echo -e "${YELLOW}Getting application URLs...${NC}"
MINIKUBE_IP=$(minikube ip)
FRONTEND_PORT=$(kubectl get service frontend -n microservices -o jsonpath='{.spec.ports[0].nodePort}')

echo -e "${GREEN}✓ Deployment completed successfully!${NC}"
echo -e "${YELLOW}Frontend URL: http://${MINIKUBE_IP}:${FRONTEND_PORT}${NC}"
echo ""
echo -e "${YELLOW}Services:${NC}"
echo "  - Frontend: http://${MINIKUBE_IP}:${FRONTEND_PORT}"
echo "  - Auth API: http://${MINIKUBE_IP}:$(kubectl get service auth-api -n microservices -o jsonpath='{.spec.ports[0].port}')"
echo "  - Users API: http://${MINIKUBE_IP}:$(kubectl get service users-api -n microservices -o jsonpath='{.spec.ports[0].port}')"
echo "  - Todos API: http://${MINIKUBE_IP}:$(kubectl get service todos-api -n microservices -o jsonpath='{.spec.ports[0].port}')"
echo "  - Redis: ${MINIKUBE_IP}:$(kubectl get service redis -n microservices -o jsonpath='{.spec.ports[0].port}')"
echo "  - Zipkin: http://${MINIKUBE_IP}:$(kubectl get service zipkin -n microservices -o jsonpath='{.spec.ports[0].port}')/zipkin"

echo -e "${GREEN}Done!${NC}"
