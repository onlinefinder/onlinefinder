#!/bin/bash

# ============================================
# OnlineFinder Cleanup and Restart Script
# Fixes ContainerConfig errors
# ============================================

echo ""
echo "🧹 =================================="
echo "   Cleaning Up Containers"
echo "================================== 🧹"
echo ""

cd "$(dirname "$0")"

# Stop and remove all containers
echo "🛑 Stopping containers..."
sudo docker-compose down

# Remove containers forcefully if they still exist
echo "🗑️  Removing any remaining containers..."
sudo docker rm -f onlinefinder onlinefinder-redis onlinefinder-caddy 2>/dev/null || true

# Remove volumes (optional - uncomment if you want a complete clean slate)
# echo "🗑️  Removing volumes..."
# sudo docker volume rm onlinefinder.com_onlinefinder-data onlinefinder.com_valkey-data onlinefinder.com_caddy-data onlinefinder.com_caddy-config 2>/dev/null || true

# Build OnlineFinder image from source
echo "🔨 Building OnlineFinder image from source..."
sudo docker-compose build onlinefinder

# Start containers
echo "🚀 Starting containers..."
sudo docker-compose up -d

echo ""
echo "✅ =================================="
echo "   Cleanup Complete!"
echo "================================== ✅"
echo ""
echo "📋 Container status:"
sudo docker-compose ps
echo ""
echo "📋 Logs (last 20 lines):"
sudo docker-compose logs --tail=20
echo ""

