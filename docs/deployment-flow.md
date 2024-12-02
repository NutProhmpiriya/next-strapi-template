# Deployment Flow Documentation

This document outlines the deployment workflow for both development and production environments.

## Overview

The application uses a CI/CD pipeline implemented with GitHub Actions to automate the deployment process. We have two separate workflows:
- Development deployment (`deploy-dev.yml`)
- Production deployment (`deploy-prod.yml`)

## Infrastructure Setup

### Prerequisites
1. Digital Ocean VPS or similar cloud provider
2. Docker and Docker Compose installed on the server
3. GitHub repository with necessary secrets configured
4. Domain names configured for frontend and CMS
5. SSL certificates (handled by Nginx)

## Development Deployment Flow

### Trigger
- Push to `develop` branch
- Manual trigger via GitHub Actions UI

### Steps
1. **Build Docker Images**
   - Build CMS image
   - Build Frontend image
   - Tag images with `:dev`
   - Push to GitHub Container Registry (GHCR)

2. **Deploy**
   - SSH into development server
   - Pull latest images
   - Update containers using `docker-compose.yml`
   - Clean up old images

## Production Deployment Flow

### Trigger
- Push to `main` branch
- Manual trigger via GitHub Actions UI

### Steps
1. **Build and Test**
   - Checkout code
   - Install Node.js dependencies
   - Run test suites
   - Fail fast if tests fail

2. **Build Docker Images**
   - Build CMS image
   - Build Frontend image
   - Tag images with `:latest` and `:${git-sha}`
   - Push to GitHub Container Registry (GHCR)

3. **Deploy**
   - SSH into production server
   - Pull latest images
   - Update containers using `docker-compose.prod.yml`
   - Clean up old images

4. **Health Checks**
   - Verify frontend is accessible
   - Verify CMS admin panel is accessible
   - Retry up to 3 times with 5s delay

## Required GitHub Secrets

### Development Environment
- `VPS_HOST`
- `VPS_USERNAME`
- `VPS_SSH_KEY`
- `GITHUB_TOKEN`

### Production Environment
- `PROD_VPS_HOST`
- `PROD_VPS_USERNAME`
- `PROD_VPS_SSH_KEY`
- `PROD_FRONTEND_DOMAIN`
- `PROD_CMS_DOMAIN`
- `GITHUB_TOKEN`

## Monitoring

The deployment includes monitoring tools:
1. **Prometheus**: Metrics collection
2. **Grafana**: Visualization and dashboards
3. **Loki**: Log aggregation

Access monitoring dashboards:
- Development: 
  - Grafana: `http://dev-domain:3000`
  - Prometheus: `http://dev-domain:9090`
- Production:
  - Grafana: `http://prod-domain:3000`
  - Prometheus: `http://prod-domain:9090`

## Rollback Procedure

If deployment fails or issues are discovered:

1. **Automatic Rollback**
   - Health checks will fail
   - Previous version remains active

2. **Manual Rollback**
   ```bash
   # SSH into server
   ssh user@server

   # Switch to previous version
   cd /opt/shopping-online
   docker-compose pull frontend:previous-tag cms:previous-tag
   docker-compose up -d

   # Verify services
   docker-compose ps
   ```

## Troubleshooting

Common issues and solutions:

1. **Failed Health Checks**
   - Check application logs: `docker-compose logs frontend cms`
   - Verify Nginx configuration
   - Check SSL certificates

2. **Container Issues**
   - Check container status: `docker ps -a`
   - View container logs: `docker logs container_name`
   - Verify disk space: `df -h`

3. **Database Issues**
   - Check PostgreSQL logs
   - Verify database connections
   - Check Redis status

## Security Considerations

1. **Secrets Management**
   - All sensitive data stored in GitHub Secrets
   - No hardcoded credentials
   - Regular rotation of SSH keys

2. **Access Control**
   - Limited SSH access
   - Container isolation
   - Regular security updates

3. **Network Security**
   - SSL/TLS encryption
   - Firewall configuration
   - Rate limiting in Nginx
