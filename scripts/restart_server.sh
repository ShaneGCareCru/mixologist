#!/bin/bash

# Mixologist FastAPI Server Restart Script

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Restarting Mixologist FastAPI server..."

# Stop the server
echo "🛑 Stopping server..."
"$SCRIPT_DIR/stop_server.sh"

# Wait a moment
sleep 2

# Start the server
echo "🚀 Starting server..."
"$SCRIPT_DIR/start_server.sh"