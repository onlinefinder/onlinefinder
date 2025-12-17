# OnlineFinder Dockerfile
# A privacy-respecting metasearch engine

FROM python:3.12-slim-bookworm AS builder

WORKDIR /app

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    libffi-dev \
    libxslt-dev \
    libxml2-dev \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first
COPY requirements.txt requirements-server.txt ./

# Upgrade pip and install dependencies first (before copying code that imports them)
RUN pip install --no-cache-dir --upgrade pip setuptools wheel \
    && pip install --no-cache-dir -r requirements.txt -r requirements-server.txt

# Copy setup.py and application code
COPY setup.py ./
COPY olf/ ./olf/

# Copy the rest of the application
COPY . .

# Install the application (use --no-build-isolation so dependencies are available)
RUN pip install --no-cache-dir --no-build-isolation -e .

# Production image
FROM python:3.12-slim-bookworm

LABEL maintainer="OnlineFinder <contact@onlinefinder.com>"
LABEL org.opencontainers.image.title="OnlineFinder"
LABEL org.opencontainers.image.description="A privacy-respecting metasearch engine"
LABEL org.opencontainers.image.url="https://onlinefinder.com"
LABEL org.opencontainers.image.source="https://github.com/onlinefinder/onlinefinder"

ENV ONLINEFINDER_SETTINGS_PATH=/etc/onlinefinder/settings.yml
ENV ONLINEFINDER_BASE_URL=http://localhost:8080/
ENV CONFIG_PATH=/etc/onlinefinder
ENV DATA_PATH=/var/cache/onlinefinder
ENV ONLINEFINDER_VERSION=unknown

WORKDIR /usr/local/onlinefinder

# Install runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    libxslt1.1 \
    libxml2 \
    ca-certificates \
    git \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd --system --gid 977 onlinefinder \
    && useradd --shell /bin/bash --system --uid 977 --gid 977 --home-dir /usr/local/onlinefinder onlinefinder \
    && mkdir -p /etc/onlinefinder /var/cache/onlinefinder \
    && chown -R onlinefinder:onlinefinder /usr/local/onlinefinder /etc/onlinefinder /var/cache/onlinefinder

# Copy from builder
COPY --from=builder /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY --from=builder /app /usr/local/onlinefinder

# Copy entrypoint script
COPY --chown=onlinefinder:onlinefinder container/entrypoint.sh /usr/local/onlinefinder/entrypoint.sh
RUN chmod +x /usr/local/onlinefinder/entrypoint.sh

# Copy default settings
RUN cp /usr/local/onlinefinder/olf/settings.yml /etc/onlinefinder/settings.yml \
    && chown onlinefinder:onlinefinder /etc/onlinefinder/settings.yml

USER onlinefinder

EXPOSE 8080

ENTRYPOINT ["/usr/local/onlinefinder/entrypoint.sh"]

