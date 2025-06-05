#!/usr/bin/env python3

from mixologist.app import app as flask_app # Import the original Flask app instance
from a2wsgi import ASGIMiddleware

# Create an ASGI-compatible app that Uvicorn can serve
asgi_app = ASGIMiddleware(flask_app)

# Note: The old `if __name__ == "__main__": app.run(...)` block is removed.
# You will now run this application using an ASGI server like Uvicorn,
# pointing it to `run:asgi_app`.
# For example: uvicorn run:asgi_app --host 0.0.0.0 --port 8080
