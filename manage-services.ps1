#!/usr/bin/env pwsh
# Docker Services Management Script
# This script automatically discovers and manages all Docker services in subdirectories

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("up", "down", "restart", "status", "logs", "list")]
    [string]$Action = "list",
    
    [Parameter(Mandatory=$false)]
    [string]$Service = "all"
)

# Auto-discover services by looking for compose.yaml files in subdirectories
function Get-DiscoveredServices {
    $discoveredServices = @()
    $directories = Get-ChildItem -Path $PSScriptRoot -Directory
    
    foreach ($dir in $directories) {
        $composePath = Join-Path $dir.FullName "compose.yaml"
        if (Test-Path $composePath) {
            $discoveredServices += $dir.Name
        }
    }
    
    return $discoveredServices
}

# List all available services
function Show-ServicesList {
    Write-Host "=== Available Docker Services ===" -ForegroundColor Cyan
    $discoveredServices = Get-DiscoveredServices
    
    if ($discoveredServices.Count -eq 0) {
        Write-Host "No services found. Looking for directories with compose.yaml files." -ForegroundColor Yellow
        return
    }
    
    foreach ($svc in $discoveredServices) {
        $servicePath = Join-Path $PSScriptRoot $svc
        $composePath = Join-Path $servicePath "compose.yaml"
        Write-Host "📁 $svc" -ForegroundColor Green
        Write-Host "   📄 $composePath" -ForegroundColor Gray
        
        # Try to get service name from compose file
        try {
            $composeContent = Get-Content $composePath -Raw
            if ($composeContent -match 'services:\s*\n\s*(\w+):') {
                $serviceName = $matches[1]
                Write-Host "   🐳 Service: $serviceName" -ForegroundColor Blue
            }
        } catch {
            Write-Host "   ⚠️  Could not read compose file" -ForegroundColor Yellow
        }
        Write-Host ""
    }
    
    Write-Host "Usage Examples:" -ForegroundColor Cyan
    Write-Host "  .\manage-services.ps1 -Action up              # Start all services" -ForegroundColor White
    Write-Host "  .\manage-services.ps1 -Action down            # Stop all services" -ForegroundColor White
    Write-Host "  .\manage-services.ps1 -Action status          # Check all services status" -ForegroundColor White
    Write-Host "  .\manage-services.ps1 -Action up -Service postgres  # Start specific service" -ForegroundColor White
}

# Exit early if listing services
if ($Action -eq "list") {
    Show-ServicesList
    exit 0
}

# Get available services
$availableServices = Get-DiscoveredServices

if ($availableServices.Count -eq 0) {
    Write-Host "No services found. Looking for directories with compose.yaml files." -ForegroundColor Red
    exit 1
}

# Validate service parameter
if ($Service -ne "all" -and $Service -notin $availableServices) {
    Write-Host "Error: Service '$Service' not found." -ForegroundColor Red
    Write-Host "Available services: $($availableServices -join ', ')" -ForegroundColor Yellow
    exit 1
}

# Determine which services to operate on
$services = @()
if ($Service -eq "all") {
    $services = $availableServices
} else {
    $services = @($Service)
}

function Invoke-ServiceAction {
    param(
        [string]$ServiceName,
        [string]$Action
    )
    
    Write-Host "=== $ServiceName Service ===" -ForegroundColor Green
    
    $servicePath = Join-Path $PSScriptRoot $ServiceName
    if (-not (Test-Path $servicePath)) {
        Write-Host "Error: Service folder '$servicePath' not found" -ForegroundColor Red
        return
    }
    
    Push-Location $servicePath
    try {
        switch ($Action) {
            "up" {
                Write-Host "Starting $ServiceName..." -ForegroundColor Yellow
                docker-compose up -d
            }
            "down" {
                Write-Host "Stopping $ServiceName..." -ForegroundColor Yellow
                docker-compose down
            }
            "restart" {
                Write-Host "Restarting $ServiceName..." -ForegroundColor Yellow
                docker-compose restart
            }
            "status" {
                Write-Host "Status of ${ServiceName}:" -ForegroundColor Yellow
                docker-compose ps
            }
            "logs" {
                Write-Host "Logs for ${ServiceName}:" -ForegroundColor Yellow
                docker-compose logs --tail=50 -f
            }
        }
    }
    finally {
        Pop-Location
    }
    Write-Host ""
}

# Execute action for each service
foreach ($svc in $services) {
    Invoke-ServiceAction -ServiceName $svc -Action $Action
}

# Show overall status after up/down/restart actions
if ($Action -in @("up", "down", "restart")) {
    Write-Host "=== Overall Status ===" -ForegroundColor Cyan
    foreach ($svc in $services) {
        $servicePath = Join-Path $PSScriptRoot $svc
        if (Test-Path $servicePath) {
            Push-Location $servicePath
            Write-Host "${svc} status:" -ForegroundColor Yellow
            docker-compose ps
            Pop-Location
        }
    }
}
