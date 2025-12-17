# Production Setup Guide

This guide explains how to switch between **local development** and **production** configurations.

## Current Configuration: LOCAL DEVELOPMENT

The current setup is configured for local development:
- ✅ Only `localhost:80` is active (HTTP, no certificate warnings)
- ✅ Domain block is commented out
- ✅ `ONLINEFINDER_BASE_URL` points to `http://localhost/`

## Switching to PRODUCTION

When deploying to production, follow these steps:

### 1. Update Caddyfile

Uncomment the production domain block at the top of `Caddyfile`:
- Remove the `#` comments from the `{$ONLINEFINDER_HOSTNAME}` block

### 2. Update docker-compose.yaml

In the `caddy` service environment section:
- Uncomment:
  ```yaml
  - ONLINEFINDER_HOSTNAME=onlinefinder.com
  - ONLINEFINDER_TLS=onlinefinder.com
  ```

In the `onlinefinder` service environment section:
- Comment out: `ONLINEFINDER_BASE_URL=http://localhost/`
- Uncomment: `ONLINEFINDER_BASE_URL=https://onlinefinder.com/`

### 3. Restart Containers

```bash
sudo docker-compose down
sudo docker-compose up -d
```

## Switching Back to LOCAL DEVELOPMENT

Reverse the steps above:
1. Comment out the domain block in `Caddyfile`
2. Comment out domain environment variables in `docker-compose.yaml`
3. Set `ONLINEFINDER_BASE_URL=http://localhost/`
4. Restart containers

