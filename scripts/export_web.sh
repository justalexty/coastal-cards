#!/bin/bash

# Export script for web build
echo "Exporting Coastal Witch Tarot for web..."

# Create export directory
mkdir -p export/web

# Export using Godot (requires Godot in PATH)
godot --headless --export-release "Web" export/web/index.html

# Copy to docs for GitHub Pages
cp -r export/web/* docs/

echo "Export complete! Files in export/web/ and docs/"
echo "To test locally: cd export/web && python -m http.server 8000"