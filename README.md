# Dockerito

A simple PowerShell utility for managing Docker Compose services across multiple directories. Instead of running `docker-compose` commands in each service folder, this script automatically discovers all services and lets you manage them from one place.

## Introduction

This utility helps manage development environments that consist of multiple Docker services, each with their own `compose.yaml` file in separate directories. It automatically discovers services by scanning for `compose.yaml` files and provides a unified interface for starting, stopping, and monitoring them.

### Project Structure
```
dockerito/
├── postgres/
│   ├── compose.yaml
│   └── init-scripts/
│       └── 01-dev-setup.sql
├── rabbitmq/
│   ├── compose.yaml
│   └── enabled_plugins
└── dockerito      # The utility script
```

## Manual

### Basic Usage
```powershell
# List all discovered services
.\dockerito

# Start all services
.\dockerito -Action up

# Stop all services
.\dockerito -Action down

# Check service status
.\dockerito -Action status

# View logs
.\dockerito -Action logs
```

### Single Service Operations
```powershell
# Work with specific services
.\dockerito -Action up -Service postgres
.\dockerito -Action down -Service rabbitmq
.\dockerito -Action restart -Service postgres
.\dockerito -Action logs -Service rabbitmq
```

### Available Actions
- `list` - Show all discovered services (default)
- `up` - Start services
- `down` - Stop services  
- `restart` - Restart services
- `status` - Show service status
- `logs` - Show service logs

### Adding New Services
1. Create a directory in the project root
2. Add a `compose.yaml` file
3. The script will automatically discover it

## Use Cases

### Development Workflow
```powershell
# Start your development environment
.\dockerito -Action up

# Check what's running
.\dockerito -Action status

# Stop everything when done
.\dockerito -Action down
```

### Working with Individual Services
```powershell
# Start only database for backend work
.\dockerito -Action up -Service postgres

# Start only message queue for async work
.\dockerito -Action up -Service rabbitmq

# Restart a service after config changes
.\dockerito -Action restart -Service postgres
```

### Debugging and Monitoring
```powershell
# Check service health
.\dockerito -Action status

# View logs for troubleshooting
.\dockerito -Action logs -Service postgres

# Restart everything if needed
.\dockerito -Action restart
```

## Current Services

### PostgreSQL Database
- **Port**: 5432
- **Access**: localhost:5432
- **Database**: myapp
- **User**: myuser
- **Password**: mypwd
- **Container**: postgres

### RabbitMQ Message Broker
- **AMQP Port**: 5672
- **Access**: localhost:5672
- **Management UI**: http://localhost:15672
- **User**: guest
- **Password**: guest
- **Container**: rabbitmq