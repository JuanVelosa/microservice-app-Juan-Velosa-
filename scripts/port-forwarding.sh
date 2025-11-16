#!/bin/bash

# 🔌 Script de Port Forwarding para acceso local

set -e

echo "🚀 Iniciando port forwarding para todos los servicios..."
echo ""

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Port forwarding en background
echo -e "${BLUE}📡 Configurando puertos locales...${NC}"
echo ""

# Grafana: localhost:3000 → grafana:3000
kubectl port-forward -n microservices svc/grafana 3000:3000 > /dev/null 2>&1 &
echo -e "${GREEN}✓${NC} Grafana:   http://localhost:3000 (admin/admin)"

# Prometheus: localhost:9090 → prometheus:9090
kubectl port-forward -n microservices svc/prometheus 9090:9090 > /dev/null 2>&1 &
echo -e "${GREEN}✓${NC} Prometheus: http://localhost:9090"

# Frontend: localhost:8081 → frontend:8081
kubectl port-forward -n microservices svc/frontend 8081:8081 > /dev/null 2>&1 &
echo -e "${GREEN}✓${NC} Frontend:   http://localhost:8081 (admin/admin)"

# Todos API: localhost:8082 → todos-api:8082
kubectl port-forward -n microservices svc/todos-api 8082:8082 > /dev/null 2>&1 &
echo -e "${GREEN}✓${NC} Todos API:  http://localhost:8082"

# Users API: localhost:8083 → users-api:8083
kubectl port-forward -n microservices svc/users-api 8083:8083 > /dev/null 2>&1 &
echo -e "${GREEN}✓${NC} Users API:  http://localhost:8083"

# Auth API: localhost:8080 → auth-api:8080
kubectl port-forward -n microservices svc/auth-api 8080:8080 > /dev/null 2>&1 &
echo -e "${GREEN}✓${NC} Auth API:   http://localhost:8080"

# Redis: localhost:6379 → redis:6379
kubectl port-forward -n microservices svc/redis 6379:6379 > /dev/null 2>&1 &
echo -e "${GREEN}✓${NC} Redis:      localhost:6379"

# Zipkin: localhost:9411 → zipkin:9411
kubectl port-forward -n microservices svc/zipkin 9411:9411 > /dev/null 2>&1 &
echo -e "${GREEN}✓${NC} Zipkin:     http://localhost:9411"

echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}📌 URLs de Acceso Local:${NC}"
echo ""
echo -e "  🌐 Frontend:    ${GREEN}http://localhost:8081${NC}"
echo -e "  🔐 Grafana:     ${GREEN}http://localhost:3000${NC} (admin/admin)"
echo -e "  📊 Prometheus:  ${GREEN}http://localhost:9090${NC}"
echo -e "  📝 Zipkin:      ${GREEN}http://localhost:9411${NC}"
echo ""
echo -e "  🔌 APIs Internas:"
echo -e "     Auth API:    ${GREEN}http://localhost:8080${NC}"
echo -e "     Todos API:   ${GREEN}http://localhost:8082${NC}"
echo -e "     Users API:   ${GREEN}http://localhost:8083${NC}"
echo -e "     Redis:       ${GREEN}localhost:6379${NC}"
echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}⚠️  Este script mantiene los port-forwards activos.${NC}"
echo -e "${YELLOW}Presiona CTRL+C para detener.${NC}"
echo ""

# Mantener los procesos vivos
wait
