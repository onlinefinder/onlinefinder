#!/bin/bash

# ============================================
# OnlineFinder Complete Source Code Rebranding Script
# ============================================

set -e

echo ""
echo "🔄 =========================================="
echo "   OnlineFinder - Source Code Rebranding"
echo "========================================== 🔄"
echo ""

cd /home/operator00/Documents/www/onlinefinder.com/onlinefinder-source

# Step 1: Replace text in all files
echo "📝 Step 1: Replacing text references..."

# Replace SearXNG with OnlineFinder (case-sensitive for brand name)
find . -type f \( -name "*.py" -o -name "*.html" -o -name "*.js" -o -name "*.css" -o -name "*.yml" -o -name "*.yaml" -o -name "*.md" -o -name "*.rst" -o -name "*.txt" -o -name "*.json" -o -name "*.toml" -o -name "*.xml" -o -name "*.svg" -o -name "*.sh" \) \
  -not -path "./.git/*" \
  -exec sed -i 's/SearXNG/OnlineFinder/g' {} \;

echo "  ✅ Replaced SearXNG → OnlineFinder"

# Replace searxng with onlinefinder (lowercase)
find . -type f \( -name "*.py" -o -name "*.html" -o -name "*.js" -o -name "*.css" -o -name "*.yml" -o -name "*.yaml" -o -name "*.md" -o -name "*.rst" -o -name "*.txt" -o -name "*.json" -o -name "*.toml" -o -name "*.xml" -o -name "*.svg" -o -name "*.sh" \) \
  -not -path "./.git/*" \
  -exec sed -i 's/searxng/onlinefinder/g' {} \;

echo "  ✅ Replaced searxng → onlinefinder"

# Replace SEARXNG with ONLINEFINDER (uppercase for env vars)
find . -type f \( -name "*.py" -o -name "*.html" -o -name "*.js" -o -name "*.css" -o -name "*.yml" -o -name "*.yaml" -o -name "*.md" -o -name "*.rst" -o -name "*.txt" -o -name "*.json" -o -name "*.toml" -o -name "*.xml" -o -name "*.svg" -o -name "*.sh" \) \
  -not -path "./.git/*" \
  -exec sed -i 's/SEARXNG/ONLINEFINDER/g' {} \;

echo "  ✅ Replaced SEARXNG → ONLINEFINDER"

# Step 2: Replace URLs
echo ""
echo "📝 Step 2: Replacing URLs..."

# Replace searxng.org URLs with onlinefinder.com
find . -type f \( -name "*.py" -o -name "*.html" -o -name "*.js" -o -name "*.css" -o -name "*.yml" -o -name "*.yaml" -o -name "*.md" -o -name "*.rst" -o -name "*.txt" -o -name "*.json" -o -name "*.toml" -o -name "*.xml" \) \
  -not -path "./.git/*" \
  -exec sed -i 's|docs\.searxng\.org|docs.onlinefinder.com|g' {} \;

find . -type f \( -name "*.py" -o -name "*.html" -o -name "*.js" -o -name "*.css" -o -name "*.yml" -o -name "*.yaml" -o -name "*.md" -o -name "*.rst" -o -name "*.txt" -o -name "*.json" -o -name "*.toml" -o -name "*.xml" \) \
  -not -path "./.git/*" \
  -exec sed -i 's|searxng\.org|onlinefinder.com|g' {} \;

echo "  ✅ Replaced searxng.org → onlinefinder.com"

# Replace GitHub URLs
find . -type f \( -name "*.py" -o -name "*.html" -o -name "*.js" -o -name "*.css" -o -name "*.yml" -o -name "*.yaml" -o -name "*.md" -o -name "*.rst" -o -name "*.txt" -o -name "*.json" -o -name "*.toml" -o -name "*.xml" \) \
  -not -path "./.git/*" \
  -exec sed -i 's|github\.com/searxng/searxng|github.com/onlinefinder/onlinefinder|g' {} \;

find . -type f \( -name "*.py" -o -name "*.html" -o -name "*.js" -o -name "*.css" -o -name "*.yml" -o -name "*.yaml" -o -name "*.md" -o -name "*.rst" -o -name "*.txt" -o -name "*.json" -o -name "*.toml" -o -name "*.xml" \) \
  -not -path "./.git/*" \
  -exec sed -i 's|github\.com/searxng|github.com/onlinefinder|g' {} \;

echo "  ✅ Replaced GitHub URLs"

# Replace Matrix room
find . -type f \( -name "*.py" -o -name "*.html" -o -name "*.js" -o -name "*.css" -o -name "*.yml" -o -name "*.yaml" -o -name "*.md" -o -name "*.rst" -o -name "*.txt" -o -name "*.json" -o -name "*.toml" -o -name "*.xml" \) \
  -not -path "./.git/*" \
  -exec sed -i 's|#searxng:matrix\.org|#onlinefinder:matrix.org|g' {} \;

echo "  ✅ Replaced Matrix room"

# Step 3: Replace searx with olf in module/package references
echo ""
echo "📝 Step 3: Replacing module references (searx → olf)..."

# Replace 'searx.' imports with 'olf.'
find . -type f -name "*.py" \
  -not -path "./.git/*" \
  -exec sed -i 's/from searx\./from olf./g' {} \;

find . -type f -name "*.py" \
  -not -path "./.git/*" \
  -exec sed -i 's/import searx\./import olf./g' {} \;

find . -type f -name "*.py" \
  -not -path "./.git/*" \
  -exec sed -i "s/'searx\./'olf./g" {} \;

find . -type f -name "*.py" \
  -not -path "./.git/*" \
  -exec sed -i 's/"searx\./"olf./g' {} \;

# Replace searx module references in config files
find . -type f \( -name "*.yml" -o -name "*.yaml" -o -name "*.toml" \) \
  -not -path "./.git/*" \
  -exec sed -i 's/searx\./olf./g' {} \;

echo "  ✅ Replaced module imports"

# Step 4: Rename the searx directory to olf
echo ""
echo "📁 Step 4: Renaming searx directory to olf..."

if [ -d "searx" ]; then
  mv searx olf
  echo "  ✅ Renamed searx → olf"
else
  echo "  ⚠️  searx directory not found or already renamed"
fi

# Also rename searxng_extra to onlinefinder_extra
if [ -d "searxng_extra" ]; then
  mv searxng_extra onlinefinder_extra
  echo "  ✅ Renamed searxng_extra → onlinefinder_extra"
fi

# Step 5: Update remaining file references to the new directory
echo ""
echo "📝 Step 5: Updating file path references..."

find . -type f \( -name "*.py" -o -name "*.html" -o -name "*.js" -o -name "*.css" -o -name "*.yml" -o -name "*.yaml" -o -name "*.md" -o -name "*.rst" -o -name "*.txt" -o -name "*.json" -o -name "*.toml" -o -name "*.xml" -o -name "*.sh" -o -name "Makefile" -o -name "setup.py" \) \
  -not -path "./.git/*" \
  -exec sed -i 's|/searx/|/olf/|g' {} \;

find . -type f \( -name "*.py" -o -name "*.html" -o -name "*.js" -o -name "*.css" -o -name "*.yml" -o -name "*.yaml" -o -name "*.md" -o -name "*.rst" -o -name "*.txt" -o -name "*.json" -o -name "*.toml" -o -name "*.xml" -o -name "*.sh" -o -name "Makefile" -o -name "setup.py" \) \
  -not -path "./.git/*" \
  -exec sed -i "s|'searx'|'olf'|g" {} \;

find . -type f \( -name "*.py" -o -name "*.html" -o -name "*.js" -o -name "*.css" -o -name "*.yml" -o -name "*.yaml" -o -name "*.md" -o -name "*.rst" -o -name "*.txt" -o -name "*.json" -o -name "*.toml" -o -name "*.xml" -o -name "*.sh" -o -name "Makefile" -o -name "setup.py" \) \
  -not -path "./.git/*" \
  -exec sed -i 's|"searx"|"olf"|g' {} \;

echo "  ✅ Updated file path references"

# Step 6: Update setup.py package name
echo ""
echo "📝 Step 6: Updating setup.py..."

if [ -f "setup.py" ]; then
  sed -i "s/name='searx'/name='onlinefinder'/g" setup.py
  sed -i 's/name="searx"/name="onlinefinder"/g' setup.py
  echo "  ✅ Updated setup.py"
fi

# Step 7: Update remaining searx references that should stay as olf
echo ""
echo "📝 Step 7: Final cleanup of remaining references..."

# Replace any remaining 'searx' that are standalone words (not part of other words)
find . -type f \( -name "*.py" -o -name "*.html" -o -name "*.yml" -o -name "*.yaml" -o -name "*.md" \) \
  -not -path "./.git/*" \
  -exec sed -i 's/\bsearx\b/olf/g' {} \;

echo "  ✅ Final cleanup complete"

echo ""
echo "✅ =========================================="
echo "   Rebranding Complete!"
echo "========================================== ✅"
echo ""
echo "📋 Summary of changes:"
echo "   - SearXNG → OnlineFinder"
echo "   - searxng → onlinefinder"
echo "   - SEARXNG → ONLINEFINDER"
echo "   - searx directory → olf"
echo "   - searxng.org → onlinefinder.com"
echo "   - GitHub URLs updated"
echo "   - Matrix room updated"
echo ""

