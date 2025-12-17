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

# Copy requirements and install dependencies
COPY requirements.txt requirements-server.txt ./
RUN pip install --no-cache-dir --upgrade pip setuptools wheel \
    && pip install --no-cache-dir -r requirements.txt -r requirements-server.txt

# Copy the application
COPY . .

# Install the application
RUN pip install --no-cache-dir -e .

# Production image
FROM python:3.12-slim-bookworm

LABEL maintainer="OnlineFinder <contact@onlinefinder.com>"
LABEL org.opencontainers.image.title="OnlineFinder"
LABEL org.opencontainers.image.description="A privacy-respecting metasearch engine"
LABEL org.opencontainers.image.url="https://onlinefinder.com"
LABEL org.opencontainers.image.source="https://github.com/onlinefinder/onlinefinder"

ENV ONLINEFINDER_SETTINGS_PATH=/etc/onlinefinder/settings.yml
ENV ONLINEFINDER_BASE_URL=http://localhost:8080/

WORKDIR /usr/local/onlinefinder

# Install runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    libxslt1.1 \
    libxml2 \
    && rm -rf /var/lib/apt/lists/* \
    && useradd --shell /bin/bash --system --home-dir /usr/local/onlinefinder onlinefinder \
    && mkdir -p /etc/onlinefinder /var/cache/onlinefinder \
    && chown -R onlinefinder:onlinefinder /usr/local/onlinefinder /etc/onlinefinder /var/cache/onlinefinder

# Copy from builder
COPY --from=builder /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY --from=builder /app /usr/local/onlinefinder

# Copy default settings
RUN cp /usr/local/onlinefinder/olf/settings.yml /etc/onlinefinder/settings.yml

USER onlinefinder

EXPOSE 8080

CMD ["python", "-m", "olf.webapp"]

