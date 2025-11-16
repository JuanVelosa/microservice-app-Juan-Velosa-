#!/bin/bash

echo "🔧 PRUEBA FINAL DEL FRONTEND CORREGIDO"
echo "======================================"

# Test directo via NodePort
echo "1. Probando via NodePort (192.168.49.2:30081)..."
NODEPORT_TEST=$(timeout 10s curl -s http://192.168.49.2:30081/ 2>/dev/null | wc -c)
if [ "$NODEPORT_TEST" -gt 1000 ]; then
    echo "✅ NodePort OK ($NODEPORT_TEST bytes)"
    echo "   🌐 Acceso directo: http://192.168.49.2:30081"
else
    echo "❌ NodePort FAIL ($NODEPORT_TEST bytes)"
fi

# Test via port-forward 8080
echo ""
echo "2. Probando via port-forward (localhost:8080)..."
PORTFORWARD_TEST=$(timeout 10s curl -s http://localhost:8080/ 2>/dev/null | wc -c)
if [ "$PORTFORWARD_TEST" -gt 1000 ]; then
    echo "✅ Port-forward OK ($PORTFORWARD_TEST bytes)"
    echo "   🌐 Acceso local: http://localhost:8080"
else
    echo "❌ Port-forward FAIL ($PORTFORWARD_TEST bytes)"
fi

# Restart port-forwards on correct ports
echo ""
echo "3. Configurando todos los port-forwards..."
pkill -f "kubectl port-forward" 2>/dev/null || true
sleep 3

kubectl port-forward -n microservices svc/frontend 8081:8081 &>/dev/null &
kubectl port-forward -n microservices svc/todos-api 8082:8082 &>/dev/null &
kubectl port-forward -n microservices svc/grafana 3000:3000 &>/dev/null &
kubectl port-forward -n microservices svc/prometheus 9090:9090 &>/dev/null &

sleep 8

# Final test on 8081
echo ""
echo "4. Prueba final en puerto 8081..."
FINAL_TEST=$(timeout 10s curl -s http://localhost:8081/ 2>/dev/null | wc -c)
if [ "$FINAL_TEST" -gt 1000 ]; then
    echo "✅ Frontend FUNCIONANDO! ($FINAL_TEST bytes)"
    echo "   🎯 URL: http://localhost:8081"
    echo "   👤 Login: admin/admin"
else
    echo "❌ Frontend aún con problemas ($FINAL_TEST bytes)"
    echo "   💡 Usa NodePort: http://192.168.49.2:30081"
fi

echo ""
echo "🔍 Estado de los pods:"
kubectl get pods -n microservices -l app=frontend

echo ""
echo "📊 URLs disponibles:"
echo "   • Frontend: http://localhost:8081 o http://192.168.49.2:30081"
echo "   • Grafana: http://localhost:3000 o http://192.168.49.2:30300"  
echo "   • Prometheus: http://localhost:9090 o http://192.168.49.2:30090"