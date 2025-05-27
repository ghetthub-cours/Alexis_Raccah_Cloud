#!/bin/bash
# Robust test script for load balancing

echo "Testing load balancing with 30 requests..."
echo "Testing endpoint: http://localhost:8080/"
echo ""

# First, test if the endpoint is accessible
echo "Testing connectivity..."
test_response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/)
if [ "$test_response" != "200" ]; then
    echo "Error: Cannot connect to HAProxy on port 8080"
    echo "HTTP Status: $test_response"
    echo "Please check if HAProxy is running: docker ps | grep haproxy"
    exit 1
fi

echo "Connection successful!"
echo ""

# Initialize counters without associative array (for compatibility)
count_1=0
count_2=0
count_3=0
count_unknown=0

# Send 30 requests
for i in {1..30}; do
    # Make request and save to temporary file
    response=$(curl -s http://localhost:8080/ 2>/dev/null)
    
    # Debug: Show first response
    if [ $i -eq 1 ]; then
        echo "Sample response:"
        echo "$response" | head -n 5
        echo "---"
        echo ""
    fi
    
    # Try different patterns to extract server ID
    server_id=""
    
    # Pattern 1: Look for "Server X" where X is a number
    if [[ $response =~ Server[[:space:]]+([0-9]+) ]]; then
        server_id="${BASH_REMATCH[1]}"
    # Pattern 2: Look for "Web Server X"
    elif [[ $response =~ Web[[:space:]]+Server[[:space:]]+([0-9]+) ]]; then
        server_id="${BASH_REMATCH[1]}"
    # Pattern 3: Look for SERVER_ID value
    elif [[ $response =~ SERVER_ID[^0-9]+([0-9]+) ]]; then
        server_id="${BASH_REMATCH[1]}"
    fi
    
    # Count based on server ID
    case "$server_id" in
        "1") ((count_1++)); echo "Request $i: Server 1" ;;
        "2") ((count_2++)); echo "Request $i: Server 2" ;;
        "3") ((count_3++)); echo "Request $i: Server 3" ;;
        *)   ((count_unknown++)); echo "Request $i: Unknown server (response: ${response:0:50}...)" ;;
    esac
done

echo ""
echo "Load balancing results:"
echo "----------------------"
echo "Server 1: $count_1 requests"
echo "Server 2: $count_2 requests"
echo "Server 3: $count_3 requests"

if [ $count_unknown -gt 0 ]; then
    echo "Unknown: $count_unknown requests"
    echo ""
    echo "Warning: Some requests could not be identified."
    echo "This might indicate an issue with the server response format."
fi

# Check if load balancing is working
if [ $count_1 -eq 0 ] || [ $count_2 -eq 0 ] || [ $count_3 -eq 0 ]; then
    echo ""
    echo "Warning: Load balancing might not be working correctly!"
    echo "One or more servers received 0 requests."
fi