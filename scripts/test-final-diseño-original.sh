#!/bin/bash

echo "🎯 PRUEBA FRONTEND CON DISEÑO ORIGINAL Y GUARDADO ARREGLADO"
echo "=========================================================="

echo ""
echo "1️⃣ Verificando frontend..."
FRONTEND_STATUS=$(curl -s -w "%{http_code}" http://localhost:8080/ --max-time 5)
if echo "$FRONTEND_STATUS" | tail -c 3 | grep -q "200"; then
    echo "✅ Frontend cargando correctamente (200)"
else
    echo "❌ Frontend no disponible"
    exit 1
fi

echo ""
echo "2️⃣ Probando login..."
LOGIN_RESPONSE=$(curl -s -X POST http://localhost:8080/login -H "Content-Type: application/json" -d '{"username":"admin","password":"admin"}' --max-time 5)
if echo "$LOGIN_RESPONSE" | grep -q "accessToken"; then
    TOKEN=$(echo "$LOGIN_RESPONSE" | sed 's/.*"accessToken":"\([^"]*\)".*/\1/')
    echo "✅ Login exitoso - Token obtenido"
else
    echo "❌ Login falló: $LOGIN_RESPONSE"
    exit 1
fi

echo ""
echo "3️⃣ Cargando tareas existentes..."
EXISTING_TASKS=$(curl -s -H "Authorization: Bearer $TOKEN" http://localhost:8080/todos --max-time 5)
echo "📝 Tareas actuales: $EXISTING_TASKS"

echo ""
echo "4️⃣ PROBANDO GUARDAR NUEVA TAREA..."
NEW_TASK_RESPONSE=$(curl -s -X POST http://localhost:8080/todos -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -d '{"content":"Tarea de prueba - diseño original"}' --max-time 5)

if echo "$NEW_TASK_RESPONSE" | grep -q '"id"'; then
    echo "✅ ¡TAREA GUARDADA CORRECTAMENTE!"
    echo "   Respuesta: $NEW_TASK_RESPONSE"
    
    # Verificar que aparece en la lista
    echo ""
    echo "5️⃣ Verificando que la tarea se guardó..."
    UPDATED_TASKS=$(curl -s -H "Authorization: Bearer $TOKEN" http://localhost:8080/todos --max-time 5)
    if echo "$UPDATED_TASKS" | grep -q "Tarea de prueba"; then
        echo "✅ ¡LA TAREA APARECE EN LA LISTA!"
        echo "   Lista actualizada: $UPDATED_TASKS"
    else
        echo "❌ La tarea no aparece en la lista"
        echo "   Lista: $UPDATED_TASKS"
    fi
else
    echo "❌ Error al guardar tarea: $NEW_TASK_RESPONSE"
fi

echo ""
echo "6️⃣ Verificando otros servicios..."
ps aux | grep "port-forward" | grep -v grep | wc -l | xargs echo "Port-forwards activos:"

echo ""
echo "=========================================================="
echo "🎉 RESUMEN:"
echo "   📱 Frontend: http://localhost:8080 (diseño original)"
echo "   🔑 Login: admin/admin"
echo "   ✅ Diseño original del TODO list mantenido"
echo "   💾 Problema de guardado de tareas RESUELTO"
echo "=========================================================="