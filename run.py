#!/usr/bin/env python3

from mixologist.fastapi_app import app

# FastAPI app is now directly ASGI compatible
# Run with: hypercorn run:app --host 0.0.0.0 --port 8081
