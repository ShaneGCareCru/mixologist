#!/bin/bash

# Mixologist FastAPI Server Status Script

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
PID_FILE="$PROJECT_DIR/server.pid"
LOG_FILE="$PROJECT_DIR/server.log"

echo "=== Mixologist FastAPI Server Status ==="
echo

# Load environment variables
if [ -f .env ]; then
    set -a
    source .env
    set +a
fi

# Print the active DATABASE_URL
if [ -z "$DATABASE_URL" ]; then
    echo "Warning: DATABASE_URL is not set!"
else
    echo "Using DATABASE_URL: $DATABASE_URL"
fi

# DB health check (PostgreSQL only)
if [[ "$DATABASE_URL" == postgresql* ]]; then
    echo
    echo "=== Database Health Check ==="
    PGPORT=$(echo "$DATABASE_URL" | sed -n 's/.*:\/\/[a-zA-Z0-9_]*:[^@]*@[^:]*:\([0-9]*\)\/.*/\1/p')
    PGPORT=${PGPORT:-5432}
    if psql "$DATABASE_URL" -c '\l' > /dev/null 2>&1; then
        echo "✅ PostgreSQL is reachable on port $PGPORT"
    else
        echo "❌ PostgreSQL is NOT reachable on port $PGPORT"
    fi
fi

# Check PID file
if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    echo "PID file exists: $PID_FILE"
    echo "Recorded PID: $PID"
    
    # Check if process is actually running
    if ps -p $PID > /dev/null 2>&1; then
        echo "✅ Status: RUNNING"
        echo "URL: http://localhost:8081"
        
        # Show process details
        echo
        echo "Process details:"
        ps -p $PID -o pid,ppid,cmd,start,etime
        
        # Show recent logs
        if [ -f "$LOG_FILE" ]; then
            echo
            echo "Recent log entries (last 10 lines):"
            tail -10 "$LOG_FILE"
        fi
    else
        echo "❌ Status: NOT RUNNING (stale PID file)"
        echo "PID $PID is not active"
        rm "$PID_FILE"
    fi
else
    echo "📄 No PID file found"
    
    # Check for any running processes
    PIDS=$(pgrep -f "hypercorn.*mixologist")
    if [ -n "$PIDS" ]; then
        echo "⚠️  Found orphaned mixologist processes: $PIDS"
        echo "Use 'scripts/stop_server.sh' to clean them up"
    else
        echo "❌ Status: NOT RUNNING"
    fi
fi

echo
echo "=== Available Commands ==="
echo "  scripts/start_server.sh    - Start the server"
echo "  scripts/stop_server.sh     - Stop the server"
echo "  scripts/restart_server.sh  - Restart the server"
echo "  scripts/status_server.sh   - Show this status"
echo

if [ -f "$LOG_FILE" ]; then
    echo "=== Log Information ==="
    echo "Log file: $LOG_FILE"
    echo "Log size: $(du -h "$LOG_FILE" | cut -f1)"
    echo "Watch logs: tail -f $LOG_FILE"
fi