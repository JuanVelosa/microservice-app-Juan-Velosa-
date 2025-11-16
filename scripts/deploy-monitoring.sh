#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
cat << "EOF"
╔════════════════════════════════════════════════════════════════════════════╗
║                                                                            ║
║         Despliegue de Monitoreo (Prometheus + Grafana)                   ║
║                                                                            ║
╚════════════════════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Get the project directory
PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo -e "${YELLOW}Paso 1: Verificando que Kubernetes esté disponible...${NC}"
kubectl get nodes > /dev/null 2>&1 || {
    echo -e "${RED}✗ Kubernetes no está disponible${NC}"
    exit 1
}
echo -e "${GREEN}✓ Kubernetes disponible${NC}"

echo ""
echo -e "${YELLOW}Paso 2: Verificando namespace microservices...${NC}"
kubectl get namespace microservices > /dev/null 2>&1 || {
    echo -e "${YELLOW}Creando namespace microservices...${NC}"
    kubectl create namespace microservices
}
echo -e "${GREEN}✓ Namespace existe${NC}"

echo ""
echo -e "${YELLOW}Paso 3: Desplegando Prometheus...${NC}"
kubectl apply -f "${PROJECT_DIR}/k8s/10-prometheus.yaml"
echo -e "${GREEN}✓ Prometheus desplegado${NC}"

echo ""
echo -e "${YELLOW}Paso 4: Desplegando Grafana...${NC}"
kubectl apply -f "${PROJECT_DIR}/k8s/11-grafana.yaml"
echo -e "${GREEN}✓ Grafana desplegado${NC}"

echo ""
echo -e "${YELLOW}Paso 5: Esperando a que los pods estén listos...${NC}"
kubectl wait --for=condition=available --timeout=120s deployment/prometheus -n microservices 2>/dev/null || true
kubectl wait --for=condition=available --timeout=120s deployment/grafana -n microservices 2>/dev/null || true
sleep 5

echo -e "${GREEN}✓ Pods en ejecución${NC}"

echo ""
echo -e "${YELLOW}Paso 6: Obteniendo URLs de acceso...${NC}"
MINIKUBE_IP=$(minikube ip)
PROMETHEUS_PORT=$(kubectl get service prometheus -n microservices -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null || echo "9090")
GRAFANA_PORT=$(kubectl get service grafana -n microservices -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null || echo "3000")

echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║${NC}                   ${GREEN}✓ MONITOREO DESPLEGADO EXITOSAMENTE${NC}                   ${BLUE}║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════════════════╝${NC}"

echo ""
echo -e "${YELLOW}URLs de Acceso:${NC}"
echo ""
echo -e "${GREEN}Prometheus:${NC}"
echo "  URL: http://${MINIKUBE_IP}:${PROMETHEUS_PORT}"
echo "  Acceso: Sin autenticación"
echo ""
echo -e "${GREEN}Grafana:${NC}"
echo "  URL: http://${MINIKUBE_IP}:${GRAFANA_PORT}"
echo "  Usuario: admin"
echo "  Contraseña: admin"
echo ""

echo -e "${YELLOW}Pasos siguientes:${NC}"
echo "  1. Abre Grafana en: http://${MINIKUBE_IP}:${GRAFANA_PORT}"
echo "  2. Inicia sesión con admin/admin"
echo "  3. Ve a Dashboards → Importar → Microservices Monitoring"
echo "  4. Selecciona Prometheus como datasource"
echo ""

echo -e "${YELLOW}Ver estado del monitoreo:${NC}"
echo "  $ kubectl get all -n microservices | grep -E '(prometheus|grafana)'"
echo ""

echo -e "${YELLOW}Ver logs:${NC}"
echo "  $ kubectl logs -f deployment/prometheus -n microservices"
echo "  $ kubectl logs -f deployment/grafana -n microservices"
echo ""

echo -e "${GREEN}¡Listo! El monitoreo está operacional.${NC}"
