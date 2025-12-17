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
sudo cp logos/onlinefinder-logo.svg searxng/logo.svg
sudo cp logos/onlinefinder-logo.png searxng/logo.png
sudo cp logos/onlinefinder-wordmark.svg searxng/wordmark.svg

# Set permissions
echo "🔐 Setting permissions..."
sudo chmod 644 searxng/logo.svg
sudo chmod 644 searxng/logo.png
sudo chmod 644 searxng/wordmark.svg
sudo chown 977:977 searxng/logo.svg searxng/logo.png searxng/wordmark.svg 2>/dev/null || true

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

