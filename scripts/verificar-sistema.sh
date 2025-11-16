#!/bin/bash

echo "================================="
echo "VERIFICACIÓN FINAL DEL SISTEMA"
echo "================================="

# Kill any existing port-forwards
pkill -f "kubectl port-forward" 2>/dev/null

# Start fresh port-forwards
echo "Iniciando port-forwards..."
kubectl port-forward -n microservices svc/frontend 8081:8081 >/dev/null 2>&1 &
kubectl port-forward -n microservices svc/grafana 3000:3000 >/dev/null 2>&1 &
kubectl port-forward -n microservices svc/prometheus 9090:9090 >/dev/null 2>&1 &
kubectl port-forward -n microservices svc/todos-api 8082:8082 >/dev/null 2>&1 &
kubectl port-forward -n microservices svc/auth-api 8080:8080 >/dev/null 2>&1 &

sleep 5

echo ""
echo "1. Testing Frontend..."
FRONTEND_TEST=$(curl -s --max-time 3 http://localhost:8081/ 2>/dev/null | head -c 50)
if [ ! -z "$FRONTEND_TEST" ]; then
    echo "✅ Frontend OK"
else
    echo "❌ Frontend FAIL"
fi

echo ""
echo "2. Testing Login..."
LOGIN_RESPONSE=$(curl -s --max-time 5 -X POST http://localhost:8081/login -H "Content-Type: application/json" -d '{"username":"admin","password":"admin"}' 2>/dev/null)
if echo "$LOGIN_RESPONSE" | grep -q "accessToken"; then
    echo "✅ Login OK"
    TOKEN=$(echo "$LOGIN_RESPONSE" | sed 's/.*"accessToken":"\([^"]*\)".*/\1/')
    echo "   Token: ${TOKEN:0:40}..."
else
    echo "❌ Login FAIL"
    echo "   Response: $LOGIN_RESPONSE"
fi

echo ""
echo "3. Testing Todos API..."
if [ ! -z "$TOKEN" ]; then
    TODOS_RESPONSE=$(curl -s --max-time 5 -H "Authorization: Bearer $TOKEN" http://localhost:8082/todos 2>/dev/null)
    if echo "$TODOS_RESPONSE" | grep -v "invalid token" | grep -q -E "\[|\{"; then
        echo "✅ Todos API OK"
        echo "   Response: $TODOS_RESPONSE"
    else
        echo "❌ Todos API FAIL"
        echo "   Response: $TODOS_RESPONSE"
    fi
else
    echo "❌ Cannot test Todos - no token"
fi

echo ""
echo "4. Testing Grafana..."
GRAFANA_TEST=$(curl -s --max-time 3 http://localhost:3000/ 2>/dev/null)
if echo "$GRAFANA_TEST" | grep -q "Found\|login"; then
    echo "✅ Grafana OK"
else
    echo "❌ Grafana FAIL"
fi

echo ""
echo "5. Testing Prometheus..."
PROMETHEUS_TEST=$(curl -s --max-time 3 http://localhost:9090/ 2>/dev/null)
if echo "$PROMETHEUS_TEST" | grep -q "Found\|Prometheus"; then
    echo "✅ Prometheus OK"
else
    echo "❌ Prometheus FAIL"
fi

echo ""
echo "================================="
echo "Pod Status:"
kubectl get pods -n microservices | grep -E "(NAME|frontend|grafana|prometheus|todos-api|auth-api)"

echo ""
echo "Port-forwards active:"
ps aux | grep "kubectl port-forward" | grep -v grep | wc -l

echo "================================="