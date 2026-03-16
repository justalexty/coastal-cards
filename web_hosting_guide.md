# Web Hosting Guide for Coastal Witch Tarot

## Quick Options

### 1. **itch.io** (Easiest)
1. Create account at itch.io
2. Create new project
3. Upload the exported web folder as a ZIP
4. Set "This file will be played in the browser"
5. Instant play link: `yourusername.itch.io/coastal-witch-tarot`

### 2. **GitHub Pages** (Free)
1. Export game to `docs/` folder
2. Push to GitHub
3. Settings → Pages → Source: Deploy from branch
4. Select `/docs` folder
5. Live at: `justalexty.github.io/coastal-tarot`

### 3. **Netlify Drop** (Instant)
1. Export game
2. Go to app.netlify.com/drop
3. Drag exported folder
4. Instant URL

## Godot Web Export Settings

### Important Settings:
```
- Canvas Resize Policy: Project Settings
- CORS: Enabled
- Compression: Gzip
- Threads: Disabled (for iOS compatibility)
```

### File Size Optimization:
- Compress textures
- Remove unused assets
- Use .webp for images
- Minimize audio quality

## Current Status

The game needs these fixes for web:
1. Add loading screen
2. Handle touch controls for mobile
3. Optimize asset sizes
4. Add PWA manifest for installability