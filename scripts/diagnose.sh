#!/bin/bash
# Diagnostic script to check the setup

echo "=== Docker Cloud Architecture Diagnostic ==="
echo ""

echo "1. Checking Docker services..."
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo ""

echo "2. Testing direct access to web servers..."
for i in 1 2 3; do
    echo -n "Web Server $i: "
    response=$(docker exec web-server-$i curl -s localhost:5000 2>/dev/null)
    if [[ $response =~ Server ]]; then
        echo "OK - Response: ${response:0:50}"
    else
        echo "FAILED"
    fi
done
echo ""

echo "3. Testing HAProxy..."
echo -n "HAProxy response: "
haproxy_response=$(curl -s http://localhost:8080/ 2>/dev/null)
if [ -n "$haproxy_response" ]; then
    echo "OK"
    echo "Response content: ${haproxy_response:0:100}..."
else
    echo "FAILED - No response"
fi
echo ""

echo "4. Checking HAProxy configuration..."
docker exec haproxy-lb cat /usr/local/etc/haproxy/haproxy.cfg | grep -E "server|backend"
echo ""

echo "5. HAProxy stats..."
echo "Stats available at: http://localhost:8404/haproxy-stats"
stats_response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8404/haproxy-stats)
echo "Stats page HTTP status: $stats_response"