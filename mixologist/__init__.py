def create_app():
    from flask import Flask
    from flask_cors import CORS
    from .views.bartender import get_blueprint
    
    app = Flask(__name__)
    CORS(app) # Enable CORS for all routes and origins
    app.register_blueprint(get_blueprint())
    return app
