#!/bin/bash

# Exit on error
set -e

# Load environment variables
source .env

# Update system packages
echo "Updating system packages..."
apt-get update && apt-get upgrade -y

# Install Docker if not installed
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
fi

# Install Docker Compose if not installed
if ! command -v docker-compose &> /dev/null; then
    echo "Installing Docker Compose..."
    curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
fi

# Pull latest images
echo "Pulling latest images..."
docker-compose pull

# Start services
echo "Starting services..."
docker-compose up -d

# Clean up old images
echo "Cleaning up..."
docker system prune -f

echo "Deployment completed successfully!"

# Health check
echo "Performing health checks..."
curl -f http://localhost || echo "Frontend health check failed"
curl -f http://localhost:1337/admin || echo "CMS health check failed"

# Check monitoring stack
echo "Checking monitoring stack..."
curl -f http://localhost:9090/-/healthy || echo "Prometheus health check failed"
curl -f http://localhost:3000/api/health || echo "Grafana health check failed"
