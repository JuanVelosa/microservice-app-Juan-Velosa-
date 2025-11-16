

# Microservices Application - Enterprise Architecture

## 🏛️ Arquitectura de Microservicios

![Arquitectura de Microservicios](docs/pictures/Microservices.png)

*Diagrama que muestra la arquitectura completa de microservicios con todos sus componentes e interacciones.*

## 🏗️ Project Structure (Following Best Practices)

```
microservice-app-Juan-Velosa/
├── services/                    # All microservices
│   ├── frontend/               # Vue.js Frontend (Nginx)
│   ├── auth-api/              # Go Authentication Service
│   ├── todos-api/             # Node.js TODOs Service
│   ├── users-api/             # Java Users Service
│   └── log-processor/         # Python Log Processing Service
├── deployment/                 # All deployment configurations
│   ├── kubernetes/            # Kubernetes manifests (9 concepts)
│   └── docker-compose/        # Docker Compose for local dev
├── scripts/                   # Automation scripts
│   ├── deploy.sh             # Full deployment automation
│   ├── port-forward.sh       # Port forwarding setup
│   ├── cleanup.sh           # Complete cleanup
│   └── build-images.sh      # Docker image building
├── docs/                     # Documentation
│   ├── architecture/         # Architecture diagrams  
│   └── pictures/             # Project images and diagrams
└── README.md                # This verification guide
```

---


# Como inicializar todo los servicios
```bash
Minikube start
cd /Users/juanmanuelvelosavalencia/Documents/microservice-app-Juan-Velosa-
eval $(minikube docker-env)
docker build -t frontend services/frontend/
docker build -t auth-api services/auth-api/
docker build -t todos-api services/todos-api/
docker build -t users-api services/users-api/
docker build -t log-message-processor services/log-processor/
```

```bash

kubectl apply -f deployment/kubernetes/
kubectl patch configmap grafana-dashboards-provider -n microservices --type merge -p '{"data":{"dashboards.yaml":"apiVersion: 1\nproviders:\n- name: default\n  orgId: 1\n  folder: \"\"\n  type: file\n  disableDeletion: false\n  editable: true\n  options:\n    path: /etc/grafana/provisioning/dashboards"}}'

```

```bash
# Port forwards
kubectl port-forward -n microservices svc/frontend 8080:8081 &
kubectl port-forward -n microservices svc/grafana 3000:3000 &
kubectl port-forward -n microservices svc/prometheus 9090:9090 &

echo "Esperando que todos los pods estén listos..."
kubectl wait --for=condition=ready pod --all -n microservices --timeout=300s
kubectl rollout restart deployment todos-api -n microservices
kubectl rollout status deployment todos-api -n microservices
```

# Como apagar todo los servicios

```bash
pkill -f "kubectl port-forward"
kubectl delete namespace microservices
minikube stop
```

---

# Guía de Verificación Detallada - Taller Plataformas 2

Esta guía demuestra paso a paso el cumplimiento de todos los conceptos de Kubernetes solicitados en el taller.

## 1. Arquitectura Master-Worker Node

### Verificar infraestructura de Minikube
```bash
minikube status
```
**¿Qué demuestra?** Confirma que el cluster Kubernetes está ejecutándose con la arquitectura Master-Worker Node.

```bash
kubectl get nodes -o wide
```
**¿Qué demuestra?** Muestra los nodos del cluster y su información detallada, confirmando la infraestructura.

## 2. Despliegue con Minikube

### Verificar que todos los servicios están desplegados en Minikube
```bash
kubectl get all -n microservices
```
**¿Qué demuestra?** Lista todos los recursos desplegados en el namespace de microservicios.

```bash
kubectl get pods -n microservices -o wide
```
**¿Qué demuestra?** Confirma que todos los pods están ejecutándose correctamente en el entorno Minikube.

## 3. kubeconfig, Services y Deployments

### Verificar configuración de kubectl
```bash
kubectl config current-context
```
**¿Qué demuestra?** Confirma que kubectl está configurado para comunicarse con el cluster.

### Verificar Services
```bash
kubectl get services -n microservices
```
**¿Qué demuestra?** Lista todos los servicios implementados con sus puertos y tipos.

### Verificar Deployments
```bash
kubectl get deployments -n microservices
```
**¿Qué demuestra?** Muestra todos los deployments con su estado de réplicas.

## 4. ReplicaSets

### Verificar ReplicaSets automáticos
```bash
kubectl get replicasets -n microservices
```
**¿Qué demuestra?** Confirma que cada deployment tiene su ReplicaSet correspondiente para gestión de réplicas.

### Verificar alta disponibilidad
```bash
kubectl describe deployment frontend -n microservices
```
**¿Qué demuestra?** Muestra la configuración de réplicas y estrategia de despliegue.

## 5. Networking

### Verificar comunicación entre servicios
```bash
kubectl get endpoints -n microservices
```
**¿Qué demuestra?** Lista todos los endpoints de red para comunicación interna.

### Probar conectividad entre servicios
```bash
kubectl exec -n microservices deployment/frontend -- nslookup todos-api
```
**¿Qué demuestra?** Confirma que el DNS interno de Kubernetes funciona para resolución de nombres.

## 6. ConfigMaps y Secrets

### Verificar ConfigMaps
```bash
kubectl get configmaps -n microservices
```
**¿Qué demuestra?** Lista las configuraciones externalizadas de la aplicación.

```bash
kubectl describe configmap app-config -n microservices
```
**¿Qué demuestra?** Muestra la configuración detallada almacenada como variables de entorno.

### Verificar Secrets
```bash
kubectl get secrets -n microservices
```
**¿Qué demuestra?** Lista todos los secrets para manejo seguro de credenciales.

```bash
kubectl describe secret app-secrets -n microservices
```
**¿Qué demuestra?** Confirma que los datos sensibles están almacenados de forma encriptada.

## 7. Autoscaling (HPA)

### Verificar Horizontal Pod Autoscalers
```bash
kubectl get hpa -n microservices
```
**¿Qué demuestra?** Lista todos los HPA configurados con sus métricas de escalado.

```bash
kubectl describe hpa frontend-hpa -n microservices
```
**¿Qué demuestra?** Muestra la configuración detallada de escalado automático basado en CPU y memoria.

### Verificar métricas disponibles
```bash
kubectl top pods -n microservices
```
**¿Qué demuestra?** Muestra el consumo actual de recursos que utiliza el HPA para escalado.

## 8. Network Policies

### Verificar políticas de red implementadas
```bash
kubectl get networkpolicies -n microservices
```
**¿Qué demuestra?** Lista todas las políticas de red para micro-segmentación.

```bash
kubectl describe networkpolicy frontend-netpol -n microservices
```
**¿Qué demuestra?** Muestra las reglas de tráfico entrante y saliente para el frontend.

### Verificar aislamiento de red
```bash
kubectl describe networkpolicy redis-netpol -n microservices
```
**¿Qué demuestra?** Confirma que Redis solo acepta conexiones de servicios autorizados.

## 9. Monitoring - Observabilidad con Prometheus y Grafana

### Verificar despliegue de Prometheus
```bash
kubectl get pods -n microservices -l app=prometheus
```
**¿Qué demuestra?** Confirma que Prometheus está ejecutándose para recolección de métricas.

![Prometheus Targets](docs/pictures/Screenshot%202025-11-15%20at%208.28.48 PM.png)
*Prometheus mostrando todos los servicios monitoreados y su estado*

### Verificar despliegue de Grafana
```bash
kubectl get pods -n microservices -l app=grafana
```
**¿Qué demuestra?** Confirma que Grafana está ejecutándose para visualización de métricas.

![Grafana Redis Dashboard](docs/pictures/Screenshot%202025-11-15%20at%208.28.30 PM.png)
*Dashboard de Grafana mostrando métricas detalladas de Redis*

### Configurar acceso a interfaces de monitoreo
```bash
kubectl port-forward -n microservices svc/prometheus 9090:9090 &
kubectl port-forward -n microservices svc/grafana 3000:3000 &
```
**¿Qué demuestra?** Habilita acceso web a las interfaces de monitoreo.

---

# Evidencia Fotográfica

## Frontend de la Aplicación
**URL de acceso:** http://localhost:8080

![Frontend Login](docs/pictures/Screenshot%202025-11-15%20at%208.27.48 PM.png)
*Página de login de la aplicación TODO con diseño moderno*

![Frontend TODOs](docs/pictures/Screenshot%202025-11-15%20at%208.28.03 PM.png)
*Interface de gestión de TODOs mostrando persistencia de datos*

### Configurar acceso al frontend
```bash
kubectl port-forward -n microservices svc/frontend 8080:80 &
```

**✅ Funcionalidades Demostradas:**
- ✅ Página de login de la aplicación
- ✅ Dashboard principal con lista de TODOs
- ✅ Funcionalidad de creación de TODOs
- ✅ Funcionalidad de eliminación de TODOs  
- ✅ Persistencia de datos después de logout/login




## Grafana - Dashboard de Monitoreo
**URL de acceso:** http://localhost:3000
**Credenciales:** admin/admin

**✅ Métricas Visualizadas:**
- ✅ Dashboard de Redis con métricas detalladas
- ✅ Conectividad de clientes en tiempo real
- ✅ Uso de memoria y comandos por segundo
- ✅ Uptime y estado de salud de servicios
- ✅ Gráficos de rendimiento del cluster




## Prometheus - Métricas y Monitoreo  
**URL de acceso:** http://localhost:9090

**✅ Targets Monitoreados:**
- ✅ Interfaz principal de Prometheus
- ✅ Prometheus server funcionando correctamente
- ✅ Redis metrics endpoint activo  
- ✅ Todos los targets en estado "UP"
- ✅ Métricas de Kubernetes disponibles



---

# Configuración Completa

### Activar todos los port-forwards necesarios
```bash
kubectl port-forward -n microservices svc/frontend 8080:80 &
kubectl port-forward -n microservices svc/auth-api 8081:8080 &
kubectl port-forward -n microservices svc/todos-api 8082:8082 &
kubectl port-forward -n microservices svc/grafana 3000:3000 &
kubectl port-forward -n microservices svc/prometheus 9090:9090 &
```
**¿Qué demuestra?** Habilita acceso completo a todos los servicios para demostración.

### Verificar estado completo del sistema
```bash
kubectl get all,configmaps,secrets,hpa,networkpolicies -n microservices
```
**¿Qué demuestra?** Resumen completo de todos los recursos de Kubernetes implementados.