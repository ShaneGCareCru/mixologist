from flask import Flask
from flask_cors import CORS # Import CORS
from .views import bartender

def create_app():
    app = Flask(__name__)
    CORS(app) # Enable CORS for all routes and origins
    app.register_blueprint(bartender.bp)
    return app
