#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Cleaning up microservices deployment...${NC}"

# Get the project directory
PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Delete all resources
echo -e "${YELLOW}Deleting Kubernetes resources...${NC}"
kubectl delete -f "${PROJECT_DIR}/k8s/" --ignore-not-found=true

# Wait for namespace to be deleted
echo -e "${YELLOW}Waiting for namespace cleanup...${NC}"
kubectl delete namespace microservices --ignore-not-found=true

echo -e "${GREEN}✓ Cleanup completed${NC}"
