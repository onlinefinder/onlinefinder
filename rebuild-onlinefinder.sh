#!/bin/bash

# ============================================
# OnlineFinder Rebuild Script
# Forces a clean rebuild without cache
# ============================================

echo ""
echo "🔨 =================================="
echo "   Rebuilding OnlineFinder"
echo "================================== 🔨"
echo ""

cd "$(dirname "$0")"

# Stop containers
echo "🛑 Stopping containers..."
sudo docker-compose down

# Remove the old onlinefinder image
echo "🗑️  Removing old OnlineFinder image..."
sudo docker rmi onlinefindercom-onlinefinder 2>/dev/null || true
sudo docker rmi onlinefinder.com-onlinefinder 2>/dev/null || true

# Build without cache
echo "🔨 Building OnlineFinder from source (no cache)..."
sudo docker-compose build --no-cache onlinefinder

# Start containers
echo "🚀 Starting containers..."
sudo docker-compose up -d

echo ""
echo "✅ =================================="
echo "   Rebuild Complete!"
echo "================================== ✅"
echo ""
echo "📋 Container status:"
sudo docker-compose ps
echo ""
echo "📋 Logs (last 30 lines):"
sudo docker-compose logs --tail=30 onlinefinder
echo ""

