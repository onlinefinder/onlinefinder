# 🔍 OnlineFinder

**A privacy-respecting metasearch engine** - Forked from SearXNG

OnlineFinder aggregates results from multiple search engines while protecting your privacy. No tracking, no profiling, just search results.

---

## 🚀 Quick Start

### Prerequisites
- Docker and Docker Compose installed
- Port 8888 available

### Launch

```bash
# Make the start script executable
chmod +x start.sh

# Start OnlineFinder
./start.sh
```

Or manually:

```bash
sudo docker-compose up -d
```

### Access
Open your browser and navigate to: **http://localhost:8888**

---

## 📁 Project Structure

```
onlinefinder.com/
├── docker-compose.yaml      # Docker services configuration
├── start.sh                 # Launch script
├── README.md                # This file
├── onlinefinder/            # Configuration files
│   ├── settings.yml         # Main configuration
│   └── limiter.toml         # Rate limiting configuration
├── onlinefinder-source/     # Rebranded source code
│   └── olf/                 # OnlineFinder module (renamed from searx)
│       ├── templates/       # HTML templates with OnlineFinder branding
│       ├── static/          # Static files (CSS, JS, images)
│       ├── infopage/        # About page content
│       └── settings.yml     # Default settings
└── logos/                   # OnlineFinder logo files
    ├── onlinefinder-logo.svg
    ├── onlinefinder-logo.png
    └── onlinefinder-wordmark.svg
```

---

## ⚙️ Configuration

### Main Settings (`onlinefinder/settings.yml`)

| Setting | Description |
|---------|-------------|
| `general.instance_name` | Display name (OnlineFinder) |
| `search.autocomplete` | Autocomplete backend |
| `search.safe_search` | Safe search level (0=off, 1=moderate, 2=strict) |
| `server.image_proxy` | Proxy images through OnlineFinder |
| `ui.default_theme` | Theme (simple) |

### Branding Settings

| Setting | Value |
|---------|-------|
| `brand.docs_url` | https://docs.onlinefinder.com/ |
| `brand.issue_url` | https://github.com/onlinefinder/onlinefinder/issues |
| `brand.wiki_url` | https://github.com/onlinefinder/onlinefinder/wiki |

---

## 🎨 Branding Changes

This fork includes the following rebranding from SearXNG:

- **Name**: SearXNG → OnlineFinder
- **Module**: `searx` → `olf`
- **URLs**: searxng.org → onlinefinder.com
- **GitHub**: github.com/searxng → github.com/onlinefinder
- **Matrix**: #searxng:matrix.org → #onlinefinder:matrix.org
- **Logo**: Custom OnlineFinder magnifying glass logo
- **About Page**: Fully rebranded content

---

## 🔧 Useful Commands

```bash
# View logs
sudo docker-compose logs -f

# Stop OnlineFinder
sudo docker-compose down

# Restart OnlineFinder
sudo docker-compose restart

# Check container status
sudo docker-compose ps
```

---

## 📝 License

This project is licensed under the AGPL-3.0 License - see the [LICENSE](onlinefinder-source/LICENSE) file for details.

Based on [SearXNG](https://github.com/searxng/searxng) - a privacy-respecting metasearch engine.

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

- **GitHub**: https://github.com/onlinefinder/onlinefinder
- **Matrix**: [#onlinefinder:matrix.org](https://matrix.to/#/#onlinefinder:matrix.org)
- **Documentation**: https://docs.onlinefinder.com/
