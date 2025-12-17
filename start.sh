#!/bin/bash

# ============================================
# OnlineFinder Launch Script
# A privacy-respecting metasearch engine
# ============================================

echo ""
echo "🔍 =================================="
echo "   OnlineFinder - Starting Up"
echo "================================== 🔍"
echo ""

cd "$(dirname "$0")"

# Ensure proper permissions
echo "📁 Setting file permissions..."
chmod 644 onlinefinder/settings.yml 2>/dev/null
chmod 644 onlinefinder/limiter.toml 2>/dev/null
chmod 644 onlinefinder/*.svg 2>/dev/null

# Start containers (use docker-compose for compatibility)
echo "🐳 Starting Docker containers..."
sudo docker-compose up -d

echo ""
echo "✅ =================================="
echo "   OnlineFinder is now running!"
echo "================================== ✅"
echo ""
echo "🌐 Access it at: http://localhost (or https://localhost if TLS is configured)"
echo ""
echo "📋 Useful commands:"
echo "   View logs:    sudo docker-compose logs -f"
echo "   Stop:         sudo docker-compose down"
echo "   Restart:      sudo docker-compose restart"
echo ""
