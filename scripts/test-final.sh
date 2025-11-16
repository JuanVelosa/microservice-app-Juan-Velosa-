#!/bin/bash

# 🧪 Script de Prueba de Todos los Servicios

echo "🧪 Iniciando pruebas del sistema..."
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Test 1: Frontend Login
echo -e "${YELLOW}1️⃣  Test Frontend Login...${NC}"
RESPONSE=$(curl -s -X POST http://localhost:8081/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin"}')

if echo "$RESPONSE" | grep -q "accessToken"; then
    echo -e "${GREEN}✅ LOGIN EXITOSO${NC}"
    TOKEN=$(echo "$RESPONSE" | grep -o '"accessToken":"[^"]*"' | cut -d'"' -f4)
    echo -e "   Token: ${TOKEN:0:50}..."
else
    echo -e "${RED}❌ LOGIN FALLÓ${NC}"
    echo "   Respuesta: $RESPONSE"
fi
echo ""

# Test 2: Grafana Dashboard
echo -e "${YELLOW}2️⃣  Test Grafana Redis Dashboard...${NC}"
DASHBOARD=$(curl -s -u admin:admin http://localhost:3000/api/search | grep -i redis)

if echo "$DASHBOARD" | grep -q "Redis"; then
    echo -e "${GREEN}✅ DASHBOARD ENCONTRADA${NC}"
    echo "   $(echo $DASHBOARD | cut -c1-80)..."
else
    echo -e "${RED}❌ DASHBOARD NO ENCONTRADA${NC}"
fi
echo ""

# Test 3: Prometheus Targets
echo -e "${YELLOW}3️⃣  Test Prometheus Targets...${NC}"
TARGETS=$(curl -s http://localhost:9090/api/v1/targets 2>&1 | grep -c '"job"')

if [ "$TARGETS" -gt 1 ]; then
    echo -e "${GREEN}✅ MÚLTIPLES TARGETS DETECTADOS${NC}"
    echo "   Encontrados: $TARGETS targets"
    curl -s http://localhost:9090/api/v1/targets | grep '"job"' | head -3 | while read line; do
        echo "   - $line" | sed 's/"job": "//' | sed 's/".*//'
    done
else
    echo -e "${RED}❌ SOLO UN TARGET${NC}"
fi
echo ""

# Test 4: Redis Metrics
echo -e "${YELLOW}4️⃣  Test Redis Metrics en Prometheus...${NC}"
REDIS_METRICS=$(curl -s 'http://localhost:9090/api/v1/query?query=redis_connected_clients' 2>&1 | grep -c "redis_connected_clients")

if [ "$REDIS_METRICS" -gt 0 ]; then
    echo -e "${GREEN}✅ MÉTRICAS DE REDIS DISPONIBLES${NC}"
    CLIENTS=$(curl -s 'http://localhost:9090/api/v1/query?query=redis_connected_clients' | grep -o '"[0-9]*"' | tail -1)
    echo "   Connected Clients: $CLIENTS"
else
    echo -e "${RED}❌ NO HAY MÉTRICAS DE REDIS${NC}"
fi
echo ""

# Test 5: Todos API
echo -e "${YELLOW}5️⃣  Test Todos API...${NC}"
TODOS=$(curl -s -H "Authorization: Bearer $TOKEN" http://localhost:8082/todos 2>&1 | head -c 100)

if echo "$TODOS" | grep -q "200\|todos\|error"; then
    echo -e "${GREEN}✅ TODOS API RESPONDIENDO${NC}"
    echo "   Respuesta: ${TODOS:0:60}..."
else
    echo -e "${RED}❌ TODOS API SIN RESPUESTA${NC}"
fi
echo ""

# Test 6: Users API
echo -e "${YELLOW}6️⃣  Test Users API...${NC}"
USERS=$(curl -s -H "Authorization: Bearer $TOKEN" http://localhost:8083/users 2>&1 | head -c 100)

if echo "$USERS" | grep -q "200\|users\|admin"; then
    echo -e "${GREEN}✅ USERS API RESPONDIENDO${NC}"
    echo "   Respuesta: ${USERS:0:60}..."
else
    echo -e "${YELLOW}⚠️  USERS API SIN RESPUESTA ESPERADA${NC}"
fi
echo ""

echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ PRUEBAS COMPLETADAS${NC}"
echo ""
echo -e "${YELLOW}📊 Dashboards Disponibles:${NC}"
echo -e "   🌐 Frontend:    ${GREEN}http://localhost:8081${NC}"
echo -e "   🔐 Grafana:     ${GREEN}http://localhost:3000${NC}"
echo -e "   📊 Prometheus:  ${GREEN}http://localhost:9090${NC}"
echo ""
