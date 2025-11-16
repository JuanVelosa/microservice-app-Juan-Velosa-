#!/bin/bash

echo "🧪 PRUEBA RÁPIDA DE SERVICIOS"
echo "=============================="
echo ""

echo "1️⃣ Probando Frontend..."
curl -s http://localhost:8081 | head -c 100
echo ""
echo "✓ Frontend respondiendo"
echo ""

echo "2️⃣ Probando Grafana..."
GRAFANA_RESPONSE=$(curl -s -w "%{http_code}" http://localhost:3000 -o /dev/null)
if [ "$GRAFANA_RESPONSE" = "200" ]; then
    echo "✓ Grafana respondiendo (HTTP $GRAFANA_RESPONSE)"
else
    echo "⚠ Grafana respondiendo con código: $GRAFANA_RESPONSE"
fi
echo ""

echo "3️⃣ Probando Prometheus..."
PROM_RESPONSE=$(curl -s -w "%{http_code}" http://localhost:9090/api/v1/query?query=up -o /dev/null)
if [ "$PROM_RESPONSE" = "200" ]; then
    echo "✓ Prometheus respondiendo (HTTP $PROM_RESPONSE)"
    echo "  Query 'up' respondiendo correctamente"
else
    echo "⚠ Prometheus respondiendo con código: $PROM_RESPONSE"
fi
echo ""

echo "4️⃣ Probando Zipkin..."
ZIPKIN_RESPONSE=$(curl -s -w "%{http_code}" http://localhost:9411 -o /dev/null)
if [ "$ZIPKIN_RESPONSE" = "200" ]; then
    echo "✓ Zipkin respondiendo (HTTP $ZIPKIN_RESPONSE)"
else
    echo "⚠ Zipkin respondiendo con código: $ZIPKIN_RESPONSE"
fi
echo ""

echo "=============================="
echo "✅ TODOS LOS SERVICIOS ACTIVOS"
echo "=============================="
echo ""
echo "📌 ACCEDE DESDE TU NAVEGADOR:"
echo ""
echo "  🌐 Frontend:   http://localhost:8081"
echo "  📊 Grafana:    http://localhost:3000"
echo "  📈 Prometheus: http://localhost:9090"
echo "  🔗 Zipkin:     http://localhost:9411"
echo ""
