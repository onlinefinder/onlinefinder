#!/bin/bash

# ============================================
# Fix ContainerConfig Error
# Removes corrupted containers and restarts
# ============================================

echo ""
echo "🔧 =================================="
echo "   Fixing ContainerConfig Error"
echo "================================== 🔧"
echo ""

cd "$(dirname "$0")"

# Stop containers (ignore errors)
echo "🛑 Stopping containers..."
sudo docker-compose down 2>/dev/null || true

# Force remove containers by name (handles corrupted metadata)
echo "🗑️  Force removing containers..."
sudo docker rm -f onlinefinder onlinefinder-redis onlinefinder-caddy 2>/dev/null || true

# Remove containers by ID if they exist (from the error output)
sudo docker rm -f 8633402d5ad4 7a7f6f4fbfff 2>/dev/null || true

# Remove any containers with matching names
sudo docker ps -a | grep -E "(onlinefinder|caddy)" | awk '{print $1}' | xargs -r sudo docker rm -f 2>/dev/null || true

# Clean up any orphaned containers
echo "🧹 Cleaning up orphaned containers..."
sudo docker container prune -f 2>/dev/null || true

# Now start fresh
echo "🚀 Starting containers fresh..."
sudo docker-compose up -d

echo ""
echo "✅ =================================="
echo "   Fix Applied!"
echo "================================== ✅"
echo ""
echo "📋 Container status:"
sudo docker-compose ps
echo ""

