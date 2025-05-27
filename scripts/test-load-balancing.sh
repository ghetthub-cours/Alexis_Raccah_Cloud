#!/bin/bash
# Test script to demonstrate load balancing

echo "Testing load balancing with 30 requests..."
echo "Each server should receive approximately 10 requests"
echo ""

# Initialize counters
declare -A server_count=(["1"]=0 ["2"]=0 ["3"]=0)

# Send 30 requests
for i in {1..30}; do
    # Make request and capture full response
    response=$(curl -s http://localhost:8080/)
    
    # Extract server number from response
    # Looking for "Server 1", "Server 2", or "Server 3" in the response
    if [[ $response =~ Server\ ([0-9]+) ]]; then
        server="${BASH_REMATCH[1]}"
        
        # Increment counter for this server
        ((server_count[$server]++))
        
        echo "Request $i: Server $server"
    else
        echo "Request $i: Could not identify server"
        echo "Response: $response"
    fi
done

echo ""
echo "Load balancing results:"
echo "----------------------"
for server in "1" "2" "3"; do
    echo "Server $server: ${server_count[$server]} requests"
done

# Calculate and display distribution
total=30
echo ""
echo "Distribution percentage:"
echo "----------------------"
for server in "1" "2" "3"; do
    percentage=$(echo "scale=1; ${server_count[$server]} * 100 / $total" | bc)
    echo "Server $server: $percentage%"
done