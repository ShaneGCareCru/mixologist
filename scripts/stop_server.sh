#!/bin/bash

# Mixologist FastAPI Server Stop Script

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
PID_FILE="$PROJECT_DIR/server.pid"

# Check if PID file exists
if [ ! -f "$PID_FILE" ]; then
    echo "No PID file found. Server may not be running."
    
    # Try to find and kill any running hypercorn processes
    PIDS=$(pgrep -f "hypercorn.*mixologist")
    if [ -n "$PIDS" ]; then
        echo "Found running mixologist processes: $PIDS"
        echo "Killing these processes..."
        echo $PIDS | xargs kill
        echo "✅ Stopped running processes"
    else
        echo "No running mixologist processes found"
    fi
    exit 0
fi

# Read PID and check if process is running
PID=$(cat "$PID_FILE")

if ps -p $PID > /dev/null 2>&1; then
    echo "Stopping Mixologist FastAPI server (PID: $PID)..."
    kill $PID
    
    # Wait for process to stop
    for i in {1..10}; do
        if ! ps -p $PID > /dev/null 2>&1; then
            break
        fi
        echo "Waiting for server to stop... ($i/10)"
        sleep 1
    done
    
    # Force kill if still running
    if ps -p $PID > /dev/null 2>&1; then
        echo "Process still running, force killing..."
        kill -9 $PID
    fi
    
    echo "✅ Server stopped successfully"
else
    echo "Process with PID $PID is not running"
fi

# Clean up PID file
rm "$PID_FILE"
echo "Cleaned up PID file"