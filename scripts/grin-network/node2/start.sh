#!/bin/bash

# Start the node
grin server run &

# Wait for node to start
sleep 5

# Check node status
echo "Checking node status..."
curl -s http://45.90.13.114:3413/v1/status
