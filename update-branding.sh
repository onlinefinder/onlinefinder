#!/bin/bash

# ============================================
# OnlineFinder Branding Update Script
# ============================================

echo ""
echo "🎨 =================================="
echo "   Updating OnlineFinder Branding"
echo "================================== 🎨"
echo ""

cd "$(dirname "$0")"

# Copy logo files
echo "📁 Copying logo files..."
sudo cp logos/onlinefinder-logo.svg onlinefinder/logo.svg
sudo cp logos/onlinefinder-logo.png onlinefinder/logo.png
sudo cp logos/onlinefinder-wordmark.svg onlinefinder/wordmark.svg

# Set permissions
echo "🔐 Setting permissions..."
sudo chmod 644 onlinefinder/logo.svg
sudo chmod 644 onlinefinder/logo.png
sudo chmod 644 onlinefinder/wordmark.svg
sudo chown 977:977 onlinefinder/logo.svg onlinefinder/logo.png onlinefinder/wordmark.svg 2>/dev/null || true

# Restart container to pick up changes
echo "🔄 Restarting OnlineFinder..."
sudo docker-compose restart onlinefinder

echo ""
echo "✅ =================================="
echo "   Branding Updated!"
echo "================================== ✅"
echo ""
echo "🌐 View at: http://localhost:8888"
echo ""

