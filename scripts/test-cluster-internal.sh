#!/bin/bash

echo "Testing internal cluster connectivity..."

# Test from frontend pod
kubectl exec -n microservices $(kubectl get pod -n microservices -l app=frontend -o jsonpath='{.items[0].metadata.name}') -- curl -s http://auth-api:8080/version

echo ""
echo "Testing login from frontend pod..."
kubectl exec -n microservices $(kubectl get pod -n microservices -l app=frontend -o jsonpath='{.items[0].metadata.name}') -- curl -s -X POST http://auth-api:8080/login -H "Content-Type: application/json" -d '{"username":"admin","password":"admin"}' | head -c 100

echo ""
echo "Testing if frontend can reach todos-api..."
kubectl exec -n microservices $(kubectl get pod -n microservices -l app=frontend -o jsonpath='{.items[0].metadata.name}') -- curl -s http://todos-api:8082/ | head -c 100