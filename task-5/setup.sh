#!/bin/bash

set -e

#echo "🔧 Checking Docker installation..."
#if ! command -v docker &> /dev/null
#then
#    echo "Docker not found. Please install Docker first."
#    exit 1
#fi

#echo "🔧 Checking Docker Compose installation..."
#if ! command -v docker compose &> /dev/null
#then
#    echo "Docker Compose not found. Please install Docker Compose."
#    exit 1
#fi

echo "🐳 Pulling required base images..."
docker pull redis:7
docker pull nginx:latest
docker pull jenkins/jenkins:lts
docker pull python:3.11-slim

echo "🚀 Starting all services..."
docker compose up -d --build

echo "⏳ Waiting for containers to initialize..."
sleep 15

echo "✅ Checking container health status..."
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo "📋 Logs preview (last 10 lines per container):"
for c in jenkins redis nginx sample_app; do
  echo -e "\n--- Logs for $c ---"
  docker logs --tail 10 $c || true
done

echo "🎉 Setup complete!"
echo "Access App: http://0.0.0.0"
echo "Access Jenkins: http://0.0.0.0/jenkins"
