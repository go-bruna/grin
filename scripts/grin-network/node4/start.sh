#!/bin/bash

# Start the node
grin server run &

# Wait for node to start
sleep 5

# Check node status
echo "Checking node status..."
curl -s http://45.90.13.118:3416/v1/status
