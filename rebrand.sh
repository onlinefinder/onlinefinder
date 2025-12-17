#!/bin/bash

# ============================================
# OnlineFinder Complete Rebranding Script
# ============================================

echo ""
echo "🎨 =================================="
echo "   OnlineFinder - Complete Rebrand"
echo "================================== 🎨"
echo ""

cd "$(dirname "$0")"

# Get container ID
CONTAINER_ID=$(sudo docker ps -qf "name=onlinefinder" | head -1)

if [ -z "$CONTAINER_ID" ]; then
    echo "❌ OnlineFinder container is not running!"
    echo "   Run ./start.sh first"
    exit 1
fi

echo "📦 Container ID: $CONTAINER_ID"
echo ""

# Copy logo files into the container's theme directory
echo "📁 Copying logo files into container..."

# Copy the logo as searxng.svg (this is what the theme looks for)
sudo docker cp logos/onlinefinder-logo.svg "$CONTAINER_ID":/usr/local/searxng/searx/static/themes/simple/img/searxng.svg
sudo docker cp logos/onlinefinder-logo.png "$CONTAINER_ID":/usr/local/searxng/searx/static/themes/simple/img/searxng.png

# Also copy as logo files
sudo docker cp logos/onlinefinder-logo.svg "$CONTAINER_ID":/usr/local/searxng/searx/static/themes/simple/img/logo.svg
sudo docker cp logos/onlinefinder-logo.png "$CONTAINER_ID":/usr/local/searxng/searx/static/themes/simple/img/logo.png

echo "✅ Logo files copied!"
echo ""

# Restart container to clear any caches
echo "🔄 Restarting container..."
sudo docker restart "$CONTAINER_ID"

# Wait for container to start
echo "⏳ Waiting for container to start..."
sleep 5

echo ""
echo "✅ =================================="
echo "   Rebranding Complete!"
echo "================================== ✅"
echo ""
echo "🌐 View at: http://localhost:8888"
echo ""
echo "Note: You may need to clear your browser cache (Ctrl+Shift+R)"
echo ""

