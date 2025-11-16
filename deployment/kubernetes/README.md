# Kubernetes Manifests - Microservices

Esta carpeta contiene todos los manifiestos YAML necesarios para desplegar la aplicación de microservicios en Kubernetes.

## 📁 Estructura

```
k8s/
├── 01-namespace.yaml           # Crea el namespace 'microservices'
├── 02-configmap.yaml           # Configuración centralizada
├── 03-redis.yaml               # Redis (base de datos para mensajes)
├── 04-zipkin.yaml              # Zipkin (tracing distribuido)
├── 05-users-api.yaml           # Servicio de Usuarios (Java/Spring)
├── 06-auth-api.yaml            # Servicio de Autenticación (Go)
├── 07-todos-api.yaml           # Servicio de Tareas (Node.js)
├── 08-log-processor.yaml       # Procesador de Logs (Python)
└── 09-frontend.yaml            # Interfaz de Usuario (Vue.js)
```

## 🚀 Despliegue Rápido

### Opción 1: Desplegar todo de una vez
```bash
eval $(minikube docker-env)
kubectl apply -f k8s/
```

### Opción 2: Desplegar paso a paso (recomendado)
```bash
kubectl apply -f k8s/01-namespace.yaml
kubectl apply -f k8s/02-configmap.yaml
kubectl apply -f k8s/03-redis.yaml
kubectl apply -f k8s/04-zipkin.yaml
kubectl apply -f k8s/05-users-api.yaml
kubectl apply -f k8s/06-auth-api.yaml
kubectl apply -f k8s/07-todos-api.yaml
kubectl apply -f k8s/08-log-processor.yaml
kubectl apply -f k8s/09-frontend.yaml
```

## 📄 Detalle de Manifiestos

### 01-namespace.yaml
Crea el namespace `microservices` donde se desplegarán todos los recursos.

**Recurso**: Namespace
**Nombre**: microservices

---

### 02-configmap.yaml
Almacena la configuración centralizada para todos los servicios.

**Recurso**: ConfigMap
**Nombre**: app-config
**Namespace**: microservices

**Variables de configuración**:
- `JWT_SECRET`: Secreto para tokens JWT
- `ZIPKIN_URL`: URL del servidor Zipkin para tracing
- `REDIS_HOST`: Host de Redis
- `REDIS_PORT`: Puerto de Redis
- `REDIS_CHANNEL`: Canal de pub/sub para logs
- `USERS_API_ADDRESS`: URL del Users API
- `AUTH_API_PORT`: Puerto del Auth API
- `TODO_API_PORT`: Puerto del Todos API

---

### 03-redis.yaml
Despliega Redis para actuar como broker de mensajes.

**Recursos**:
- Service (ClusterIP) - redis:6379
- Deployment (1 réplica)
  - Imagen: redis:6-alpine
  - Limites: 200m CPU, 256Mi Memory

**Puertos**:
- 6379 (TCP)

---

### 04-zipkin.yaml
Despliega Zipkin para recopilar trazas distribuidas de todos los servicios.

**Recursos**:
- Service (ClusterIP) - zipkin:9411
- Deployment (1 réplica)
  - Imagen: openzipkin/zipkin:latest
  - Limites: 500m CPU, 1Gi Memory

**Puertos**:
- 9411 (TCP)

---

### 05-users-api.yaml
Despliega el servicio de Usuarios escrito en Java/Spring Boot.

**Recursos**:
- Service (ClusterIP) - users-api:8083
- Deployment (2 réplicas)
  - Imagen: users-api:latest
  - Limites: 300m CPU, 512Mi Memory

**Variables de entorno**:
- ZIPKIN_URL (desde ConfigMap)

**Puertos**:
- 8083 (TCP)

---

### 06-auth-api.yaml
Despliega el servicio de Autenticación escrito en Go.

**Recursos**:
- Service (ClusterIP) - auth-api:8080
- Deployment (2 réplicas)
  - Imagen: auth-api:latest
  - Limites: 200m CPU, 256Mi Memory

**Variables de entorno**:
- AUTH_API_PORT (desde ConfigMap)
- USERS_API_ADDRESS (desde ConfigMap)
- JWT_SECRET (desde ConfigMap)
- ZIPKIN_URL (desde ConfigMap)

**Puertos**:
- 8080 (TCP)

**Health Checks**:
- Readiness: GET /version (5s delay)
- Liveness: GET /version (15s delay)

---

### 07-todos-api.yaml
Despliega el servicio de Tareas escrito en Node.js.

**Recursos**:
- Service (ClusterIP) - todos-api:8082
- Deployment (2 réplicas)
  - Imagen: todos-api:latest
  - Limites: 300m CPU, 512Mi Memory

**Variables de entorno**:
- TODO_API_PORT (desde ConfigMap)
- JWT_SECRET (desde ConfigMap)
- REDIS_HOST (desde ConfigMap)
- REDIS_PORT (desde ConfigMap)
- REDIS_CHANNEL (desde ConfigMap)
- ZIPKIN_URL (desde ConfigMap)

**Puertos**:
- 8082 (TCP)

---

### 08-log-processor.yaml
Despliega el procesador de logs escrito en Python.

**Recursos**:
- Deployment (1 réplica)
  - Imagen: log-message-processor:latest
  - Limites: 100m CPU, 256Mi Memory

**Variables de entorno**:
- REDIS_HOST (desde ConfigMap)
- REDIS_PORT (desde ConfigMap)
- REDIS_CHANNEL (desde ConfigMap)
- ZIPKIN_URL (desde ConfigMap)

**Descripción**: 
- Escucha mensajes en el canal Redis `log_channel`
- Procesa y imprime los logs
- Soporta tracing distribuido con Zipkin

---

### 09-frontend.yaml
Despliega la interfaz de usuario escrita en Vue.js.

**Recursos**:
- Service (NodePort) - frontend:8081:30081
- Deployment (2 réplicas)
  - Imagen: frontend:latest
  - Limites: 200m CPU, 256Mi Memory

**Puertos**:
- 8081 (TCP) -> NodePort 30081

**Health Checks**:
- Readiness: GET / (10s delay)
- Liveness: GET / (30s delay)

---

## 🔧 Modificaciones Comunes

### Cambiar número de réplicas
Edita el campo `spec.replicas` en el Deployment:

```yaml
spec:
  replicas: 3  # Cambiar de 2 a 3
```

### Cambiar límites de recursos
Edita las secciones `resources`:

```yaml
resources:
  requests:
    memory: "512Mi"  # Aumentar
    cpu: "200m"
  limits:
    memory: "1Gi"
    cpu: "500m"
```

### Añadir variables de entorno
Añade al array `env`:

```yaml
- name: NEW_VAR
  value: "new-value"
```

### Cambiar puertos
Edita los puertos en Service y Deployment:

```yaml
# En Service
ports:
- port: 9000  # Puerto del service
  targetPort: 9000  # Puerto del container

# En Deployment
ports:
- containerPort: 9000
```

## 📊 Verificación del Despliegue

### Ver todos los recursos
```bash
kubectl get all -n microservices
```

### Ver logs de un deployment
```bash
kubectl logs -f deployment/<name> -n microservices
```

### Describir un pod
```bash
kubectl describe pod <pod-name> -n microservices
```

### Ver eventos
```bash
kubectl get events -n microservices
```

## 🧹 Eliminación

### Eliminar todo
```bash
kubectl delete namespace microservices
```

### Eliminar un recurso específico
```bash
kubectl delete deployment <name> -n microservices
```

---

## ⚙️ Notas Técnicas

### ConfigMap
- Los valores en el ConfigMap se inyectan como variables de entorno
- Los cambios requieren reiniciar los pods

### ImagePullPolicy
Todos los manifiestos usan `imagePullPolicy: Never` para que funcione con imágenes locales de Minikube

### Services
- **ClusterIP**: Acceso solo dentro del cluster
- **NodePort**: Acceso desde fuera del cluster en puerto 30081

### Health Checks
- **Liveness Probe**: Reinicia el pod si falla
- **Readiness Probe**: Marca el pod como no listo si falla

---

## 🚀 Próximas Mejoras

1. **Persistent Volumes**: Para persistencia de datos en Redis
2. **Secrets**: Para información sensible (contraseñas, keys)
3. **Ingress**: Para acceso HTTP uniforme a los servicios
4. **Network Policies**: Para seguridad microsegmentada
5. **HPA**: Horizontal Pod Autoscaler para auto-scaling
6. **RBAC**: Role-based access control

---

**Documentación completa disponible en DEPLOYMENT_GUIDE.md**
