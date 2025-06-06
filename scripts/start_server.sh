#!/bin/bash

# Mixologist FastAPI Server Start Script

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
PID_FILE="$PROJECT_DIR/server.pid"
LOG_FILE="$PROJECT_DIR/server.log"

# Check if server is already running
if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if ps -p $PID > /dev/null 2>&1; then
        echo "Server is already running with PID $PID"
        echo "Use 'scripts/stop_server.sh' to stop it first"
        exit 1
    else
        echo "Removing stale PID file"
        rm "$PID_FILE"
    fi
fi

# Load API key and start server
cd "$PROJECT_DIR"

# Activate conda environment and start server
eval "$(conda shell.bash hook)"
conda activate mixologist

echo "Starting Mixologist FastAPI server..."
echo "Project directory: $PROJECT_DIR"
echo "Log file: $LOG_FILE"

# Start server in background with logging
OPENAI_API_KEY=$(cat ~/.apikeys/openai) nohup python -m hypercorn mixologist.fastapi_app:app --bind 0.0.0.0:8081 > "$LOG_FILE" 2>&1 &
SERVER_PID=$!

# Save PID
echo $SERVER_PID > "$PID_FILE"

# Wait a moment to check if server started successfully
sleep 2

if ps -p $SERVER_PID > /dev/null 2>&1; then
    echo "✅ Server started successfully!"
    echo "PID: $SERVER_PID"
    echo "URL: http://localhost:8081"
    echo "Logs: tail -f $LOG_FILE"
    echo ""
    echo "Available endpoints:"
    echo "  GET  /                         - API status"
    echo "  POST /create                   - Enhanced recipe generation with caching"
    echo "  POST /generate_image           - Main cocktail image generation"
    echo "  POST /generate_ingredient_image - Individual ingredient images"
    echo "  POST /generate_glassware_image  - Glassware visualization"
    echo "  POST /generate_garnish_image    - Garnish macro photography"
    echo "  POST /generate_equipment_image  - Bar equipment visualization"
    echo "  POST /generate_recipe_visuals   - Complete visual package generation"
    echo "  POST /related_cocktails        - Get related cocktail suggestions"
    echo "  POST /ingredient_info          - Get ingredient details"
    echo "  POST /recipe_variations        - Submit recipe variations"
    echo ""
    echo "Use 'scripts/stop_server.sh' to stop the server"
else
    echo "❌ Server failed to start. Check logs:"
    cat "$LOG_FILE"
    rm "$PID_FILE"
    exit 1
fi