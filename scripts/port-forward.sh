#!/bin/bash

# Port-forward script for accessing services locally

echo "🌐 Starting port-forwards for all services..."

# Kill any existing port-forwards
pkill -f "kubectl port-forward" 2>/dev/null || true
sleep 2

echo "Setting up port-forwards..."

# Core application services
kubectl port-forward -n microservices svc/frontend 8080:80 > /dev/null 2>&1 &
kubectl port-forward -n microservices svc/auth-api 8081:8080 > /dev/null 2>&1 &
kubectl port-forward -n microservices svc/todos-api 8082:8082 > /dev/null 2>&1 &

# Monitoring services  
kubectl port-forward -n microservices svc/grafana 3000:3000 > /dev/null 2>&1 &
kubectl port-forward -n microservices svc/prometheus 9090:9090 > /dev/null 2>&1 &

# Optional services (uncomment if needed)
# kubectl port-forward -n microservices svc/zipkin 9411:9411 > /dev/null 2>&1 &
# kubectl port-forward -n microservices svc/users-api 8083:8083 > /dev/null 2>&1 &

sleep 3

echo "✅ Port-forwards configured!"
echo ""
echo "🌐 Access URLs:"
echo "   📱 Frontend TODO App:    http://localhost:8080"
echo "   🔐 Auth API:            http://localhost:8081"
echo "   📝 TODOs API:           http://localhost:8082"
echo "   📊 Grafana Dashboard:   http://localhost:3000 (admin/admin)"
echo "   📈 Prometheus:          http://localhost:9090"
echo ""
echo "🔧 To stop all port-forwards:"
echo "   pkill -f 'kubectl port-forward'"