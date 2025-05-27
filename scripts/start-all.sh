#!/bin/bash
# Complete startup script for Docker Cloud Architecture

echo "=== Starting Docker Cloud Architecture ==="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check if service is running
check_service() {
    local service_name=$1
    if docker ps | grep -q $service_name; then
        echo -e "${GREEN}✓${NC} $service_name is running"
        return 0
    else
        echo -e "${RED}✗${NC} $service_name is not running"
        return 1
    fi
}

# Step 1: Clean up
echo "Step 1: Cleaning up existing containers..."
docker-compose -f docker-compose-complete.yml down 2>/dev/null || true
echo ""

# Step 2: Network setup
echo "Step 2: Setting up Docker network..."
docker network rm cloud-network 2>/dev/null || true
docker network create cloud-network
echo -e "${GREEN}✓${NC} Network created"
echo ""

# Step 3: Build images
echo "Step 3: Building Docker images..."
docker-compose -f docker-compose-complete.yml build
echo ""

# Step 4: Start services
echo "Step 4: Starting services..."
docker-compose -f docker-compose-complete.yml up -d

# Wait for services to start
echo ""
echo "Waiting for services to initialize..."
sleep 10

# Step 5: Verify services
echo ""
echo "Step 5: Verifying services..."
all_good=true

check_service "web-server-1" || all_good=false
check_service "web-server-2" || all_good=false
check_service "web-server-3" || all_good=false
check_service "haproxy-lb" || all_good=false
check_service "prometheus" || all_good=false
check_service "grafana" || all_good=false
check_service "node-exporter" || all_good=false
check_service "mysql-db" || all_good=false

echo ""

# Step 6: Test endpoints
echo "Step 6: Testing endpoints..."

# Test HAProxy
echo -n "HAProxy (http://localhost:8080): "
if curl -s -f -o /dev/null http://localhost:8080; then
    echo -e "${GREEN}✓${NC} Accessible"
else
    echo -e "${RED}✗${NC} Not accessible"
    all_good=false
fi

# Test Prometheus
echo -n "Prometheus (http://localhost:9090): "
if curl -s -f -o /dev/null http://localhost:9090; then
    echo -e "${GREEN}✓${NC} Accessible"
else
    echo -e "${RED}✗${NC} Not accessible"
fi

# Test Grafana
echo -n "Grafana (http://localhost:3000): "
if curl -s -f -o /dev/null http://localhost:3000; then
    echo -e "${GREEN}✓${NC} Accessible"
else
    echo -e "${RED}✗${NC} Not accessible"
fi

echo ""

# Final status
if [ "$all_good" = true ]; then
    echo -e "${GREEN}=== All services started successfully! ===${NC}"
    echo ""
    echo "Access points:"
    echo "- Web Application: http://localhost:8080/"
    echo "- HAProxy Stats: http://localhost:8404/haproxy-stats"
    echo "- Prometheus: http://localhost:9090"
    echo "- Grafana: http://localhost:3000 (admin/admin)"
else
    echo -e "${RED}=== Some services failed to start ===${NC}"
    echo ""
    echo "Check logs with:"
    echo "docker-compose -f docker-compose-complete.yml logs"
    echo ""
    echo "Or check individual service:"
    echo "docker logs <container-name>"
fi