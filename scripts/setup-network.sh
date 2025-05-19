#!/bin/bash

# Configuration
NODE_COUNT=4
BASE_PORT=3414
API_PORT=3413
STRATUM_PORT=3416
WALLET_PORT=3415
CHAIN_TYPE="Mainnet"  # Using Mainnet configuration to experience all
NODE_NAMES=("node1" "node2" "node3" "node4")

# Node IP addresses - Replace these with your actual node IPs
NODE_IPS=(
    "45.90.13.109"  # Replace with actual IP
    "45.90.13.114"  # Replace with actual IP
    "45.90.13.116"  # Replace with actual IP
    "45.90.13.118"  # Replace with actual IP
)

# Create base directory
mkdir -p grin-network
cd grin-network

# Function to create node configuration
create_node_config() {
    local node_name=$1
    local node_ip=$2
    local node_port=$3
    local api_port=$4
    local stratum_port=$5
    local wallet_port=$6
    local peers=$7

    mkdir -p $node_name
    cd $node_name

    # Create grin-server.toml
    cat > grin-server.toml << EOF
[server]
chain_type = "$CHAIN_TYPE"
db_root = "grin_chain"
api_http_addr = "$node_ip:$api_port"
api_secret_path = ".api_secret"
foreign_api_secret_path = ".foreign_api_secret"
skip_sync_wait = true
run_tui = false
run_test_miner = true

[server.p2p_config]
host = "0.0.0.0"
port = $node_port
seeding_type = "List"
seeds = $peers
peer_max_inbound_count = 128
peer_max_outbound_count = 8
peer_min_preferred_outbound_count = 4

[server.pool_config]
accept_fee_base = 500000
max_pool_size = 50000
max_stempool_size = 50000

[server.dandelion_config]
epoch_secs = 600
aggregation_secs = 30
embargo_secs = 180
stem_probability = 90
always_stem_our_txs = true

[server.stratum_mining_config]
enable_stratum_server = true
stratum_server_addr = "$node_ip:$stratum_port"
attempt_time_per_block = 15
minimum_share_difficulty = 1
wallet_listener_url = "http://$node_ip:$wallet_port"
burn_reward = false
EOF

    # Create API secret
    echo "grin_api_secret" > .api_secret
    echo "grin_foreign_api_secret" > .foreign_api_secret

    cd ..
}

# Create nodes
for i in $(seq 0 $((NODE_COUNT-1))); do
    node_name=${NODE_NAMES[$i]}
    node_ip=${NODE_IPS[$i]}
    node_port=$((BASE_PORT + i))
    api_port=$((API_PORT + i))
    stratum_port=$((STRATUM_PORT + i))
    wallet_port=$((WALLET_PORT + i))
    
    # Create peer list for this node
    peers="["
    for j in $(seq 0 $((NODE_COUNT-1))); do
        if [ $i -ne $j ]; then
            peer_ip=${NODE_IPS[$j]}
            peer_port=$((BASE_PORT + j))
            peers="$peers\"$peer_ip:$peer_port\","
        fi
    done
    peers="${peers%,}]"
    
    create_node_config $node_name $node_ip $node_port $api_port $stratum_port $wallet_port "$peers"
done

# Create start script for each node
for i in $(seq 0 $((NODE_COUNT-1))); do
    node_name=${NODE_NAMES[$i]}
    node_ip=${NODE_IPS[$i]}
    api_port=$((API_PORT + i))
    
    cat > $node_name/start.sh << EOF
#!/bin/bash

# Start the node
grin server run &

# Wait for node to start
sleep 5

# Check node status
echo "Checking node status..."
curl -s http://$node_ip:$api_port/v1/status
EOF

    chmod +x $node_name/start.sh
done

echo "Grin network configuration created successfully!"
echo "To start each node, go to its directory and run: ./start.sh"
echo "Example: cd node1 && ./start.sh"