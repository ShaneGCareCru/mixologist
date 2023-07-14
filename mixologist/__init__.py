from flask import Flask
from .views import bartender

def create_app():
    app = Flask(__name__)
    app.register_blueprint(bartender.bp)
    return app
