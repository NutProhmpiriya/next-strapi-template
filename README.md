# VPS Deployment Project

This project contains a complete setup for deploying a Next.js application with Strapi CMS on Digital Ocean VPS, including monitoring and CI/CD pipeline.

## Stack Components

### Application
- Frontend: Next.js + React
- CMS: Strapi
- Databases: PostgreSQL, Redis

### Infrastructure
- Server: Digital Ocean VPS
- Container: Docker
- Load Balancer: Nginx
- CI/CD: GitHub Actions

### Monitoring Stack
- Grafana: Visualization and dashboards
- Prometheus: Metrics collection
- Loki: Log aggregation

## Project Structure
```
.
├── .github/
│   └── workflows/          # GitHub Actions workflows
├── apps/
│   ├── frontend/          # Next.js application
│   └── cms/              # Strapi CMS
├── config/
│   ├── nginx/            # Nginx configuration
│   └── monitoring/       # Grafana, Prometheus, Loki configs
├── docker/               # Docker configurations
│   ├── frontend/
│   ├── cms/
│   └── monitoring/
└── scripts/              # Deployment and utility scripts
```

## Setup Instructions

1. Clone the repository
2. Copy `.env.example` to `.env` and fill in the required variables
3. Run `docker-compose up` for local development
4. For production deployment, follow the deployment guide in `docs/deployment.md`

## Development

### Local Development
```bash
# Start all services
docker-compose up -d

# Start only specific service
docker-compose up frontend -d
```

### Monitoring
Access monitoring dashboards:
- Grafana: http://localhost:3000
- Prometheus: http://localhost:9090

## Deployment
Deployment is automated via GitHub Actions. Push to main branch will trigger:
1. Build and test
2. Docker image creation
3. Deployment to Digital Ocean VPS
4. Health checks

## License
MIT
