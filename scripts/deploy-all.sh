#!/bin/bash

echo "🚀 Iniciando despliegue completo de microservicios..."

# Cambiar al directorio del proyecto
cd /Users/juanmanuelvelosavalencia/Documents/microservice-app-Juan-Velosa-

echo "🔧 Configurando Docker para Minikube..."
eval $(minikube docker-env)

echo "🏗️ Construyendo todas las imágenes Docker..."
docker build -t frontend services/frontend/ &
docker build -t auth-api services/auth-api/ &
docker build -t todos-api services/todos-api/ &
docker build -t users-api services/users-api/ &
docker build -t log-message-processor services/log-processor/ &

# Esperar que todas las imágenes se construyan
wait

echo "📦 Aplicando todos los manifiestos de Kubernetes..."
kubectl apply -f deployment/kubernetes/01-namespace.yaml
kubectl apply -f deployment/kubernetes/02-configmap.yaml
kubectl apply -f deployment/kubernetes/12-secrets.yaml
kubectl apply -f deployment/kubernetes/03-redis.yaml
kubectl apply -f deployment/kubernetes/04-zipkin.yaml
kubectl apply -f deployment/kubernetes/05-users-api.yaml
kubectl apply -f deployment/kubernetes/06-auth-api.yaml
kubectl apply -f deployment/kubernetes/07-todos-api.yaml
kubectl apply -f deployment/kubernetes/08-log-processor.yaml
kubectl apply -f deployment/kubernetes/09-frontend.yaml
kubectl apply -f deployment/kubernetes/10-prometheus-clean.yaml
kubectl apply -f deployment/kubernetes/11-grafana-clean.yaml
kubectl apply -f deployment/kubernetes/grafana-dashboards.yaml
kubectl apply -f deployment/kubernetes/13-hpa.yaml
kubectl apply -f deployment/kubernetes/14-network-policies.yaml

echo "⏳ Esperando que todos los pods estén listos..."
kubectl wait --for=condition=ready pod --all -n microservices --timeout=300s

echo "🔌 Configurando port-forwarding..."
pkill -f "kubectl port-forward" 2>/dev/null || true
kubectl port-forward -n microservices svc/frontend 8080:8081 &
kubectl port-forward -n microservices svc/grafana 3000:3000 &
kubectl port-forward -n microservices svc/prometheus 9090:9090 &

echo "✅ Despliegue completo terminado!"
echo ""
echo "🌐 Accesos disponibles:"
echo "   Frontend:   http://localhost:8080"
echo "   Grafana:    http://localhost:3000 (admin/admin)"
echo "   Prometheus: http://localhost:9090"
echo ""
echo "📊 Verificar estado: kubectl get pods -n microservices"