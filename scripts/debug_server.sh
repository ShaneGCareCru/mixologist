#!/bin/bash

# Mixologist FastAPI Server Debug Script - Shows print output in real-time

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Stop any existing server
./stop_server.sh 2>/dev/null

# Load API key and start server
cd "$PROJECT_DIR"

# Activate conda environment
eval "$(conda shell.bash hook)"
conda activate mixologist

echo "🐛 Starting Mixologist FastAPI server in DEBUG mode..."
echo "Project directory: $PROJECT_DIR"
echo "🔍 Debug output will show in real-time"
echo "📝 Print statements from image analysis will be visible"
echo "Press Ctrl+C to stop"
echo "============================================================"

# Start server in foreground with debug output (unbuffered for immediate print output)
OPENAI_API_KEY=$(cat ~/.apikeys/openai) PYTHONUNBUFFERED=1 python -m hypercorn mixologist.fastapi_app:app --bind 0.0.0.0:8081 --log-level debug