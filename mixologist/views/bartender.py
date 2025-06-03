from flask import Blueprint, request, render_template_string, render_template
import os
import json
import openai
from flask import jsonify
from pydantic import BaseModel, Field
from typing import List, Dict
from collections import namedtuple
from dotenv import load_dotenv
from ..models.get_recipe_params import Ingredient, GetRecipeParams
from ..services.openai_service import Recipe, parse_recipe_arguments, get_completion_from_messages, generate_image

bp = Blueprint('bartender', __name__)

@bp.route('/')
def home():
    return render_template('home.html')

@bp.route('/create', methods=['POST'])
def create_drink():
    drink_query = request.form.get('drink_query')

    ingredients = ""
    ingredients_part = f"The ingredients I have are: {ingredients}\n" if ingredients else ""

    user_query = f"""
    I want you to act like the world's most important bartender. 
    You're the bartender that will carry on the culture of bartending for the entire world. 
    I'm going to tell you the name of a drink, and you need to create the best representation of that drink based on its name alone. 
    It's possible that this drink is unknown; you will still respond. 
    {ingredients_part}
    The drink I want you to tell me about is: {drink_query}
    """

    recipe = get_completion_from_messages([{"role": "user", "content": user_query}])

    return render_template('create_drinks.html', serving_glass=recipe.serving_glass, alcohol_content=recipe.alcohol_content, rim='Salted' if recipe.rim else 'No salt', ingredients=recipe.ingredients, steps=recipe.steps, garnish=recipe.garnish, drink_image_description=recipe.drink_image_description, drink_history=recipe.drink_history, drink_name=recipe.drink_name)

@bp.route('/images')
def images():
    """List available images in the application's static folder."""
    img_dir = os.path.join('mixologist', 'static', 'img')
    return jsonify(os.listdir(img_dir))

@bp.route('/generate_image', methods=['POST'])
def generate_image_route():
    # Extract the image description and drink query from the request
    image_description = request.form.get('image_description')
    drink_query = request.form.get('drink_query')

    # Generate the image and get the filename
    filename = generate_image(image_description, drink_query)

    # Return the filename in the response
    return jsonify({"filename": filename})


@bp.errorhandler(openai.error.InvalidRequestError)
def handle_invalid_request_error(e):
    return render_template('error.html', message="Something Went Wrong, it was either you or me, I'm thinking you used a naughty word"), 500

@bp.errorhandler(KeyError)
def handle_key_error(e):
    return render_template('error.html', message="We couldn't make any sense of that, have you been drinking?"), 500
