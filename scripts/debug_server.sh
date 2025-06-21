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

# Load environment variables
if [ -f .env ]; then
    echo "Sourcing .env file..."
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

# Check PostgreSQL on port 15432
if ! nc -z localhost 15432; then
    echo "❌ PostgreSQL is not running on port 15432. Please start it first."
    exit 1
fi

echo "🐛 Starting Mixologist FastAPI server in DEBUG mode..."
echo "Project directory: $PROJECT_DIR"
echo "🔍 Debug output will show in real-time"
echo "📝 Print statements from image analysis will be visible"
echo "Press Ctrl+C to stop"
echo "============================================================"

# Set BYPASS_AUTH for development testing if not already set
if [ -z "$BYPASS_AUTH" ]; then
    export BYPASS_AUTH=true
    echo "Setting BYPASS_AUTH=true for development testing"
fi

# Start server in foreground with debug output (unbuffered for immediate print output)
OPENAI_API_KEY=$(cat ~/.apikeys/openai) DATABASE_URL="$DATABASE_URL" BYPASS_AUTH="$BYPASS_AUTH" PYTHONUNBUFFERED=1 python -m hypercorn mixologist.fastapi_app:app --bind 0.0.0.0:8081 --log-level debug