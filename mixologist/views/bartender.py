from flask import Blueprint, request, render_template_string, render_template, Response, stream_with_context, jsonify
import os
import json
import openai
# from flask import jsonify # jsonify is already imported above
from pydantic import BaseModel, Field
from typing import List, Dict
from collections import namedtuple
from dotenv import load_dotenv
from ..models.get_recipe_params import Ingredient, GetRecipeParams
from ..services.openai_service import Recipe, parse_recipe_arguments, get_completion_from_messages, generate_image_stream # Updated import

bp = Blueprint('bartender', __name__)

@bp.route('/')
def home():
    return render_template('home.html')

@bp.route('/create', methods=['POST'])
def create_drink():
    drink_query = request.form.get('drink_query')
    ingredients = "" # This seems unused or hardcoded empty, might need review later
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
    recipe_data = {
        "drink_name": recipe.drink_name,
        "alcohol_content": recipe.alcohol_content,
        "serving_glass": recipe.serving_glass,
        "rim": 'Salted' if recipe.rim else 'No salt',
        "ingredients": recipe.ingredients,
        "steps": recipe.steps,
        "garnish": recipe.garnish,
        "drink_image_description": recipe.drink_image_description,
        "drink_history": recipe.drink_history
    }
    return jsonify(recipe_data)

@bp.route('/images') # This route might be obsolete if images are always generated on demand
def images():
    img_dir = 'mixologist/static/img/'
    # Ensure directory exists to prevent error if it's deleted or not yet created
    if not os.path.exists(img_dir):
        os.makedirs(img_dir)
    return jsonify(os.listdir(img_dir))

@bp.route('/generate_image', methods=['POST']) # This will now be our streaming endpoint
async def generate_image_route():
    print("--- generate_image_route (streaming) called ---")
    
    image_description = request.form.get('image_description')
    drink_query = request.form.get('drink_query') # drink_name for the image
    ingredients_json = request.form.get('ingredients')
    serving_glass = request.form.get('serving_glass')
    
    try:
        ingredients = json.loads(ingredients_json) if ingredients_json else None
    except json.JSONDecodeError:
        print("!!! ERROR decoding ingredients JSON in generate_image_route !!!")
        return jsonify({"error": "Invalid ingredients JSON format"}), 400

    async def event_stream():
        try:
            print(f"--- Starting OpenAI image stream for: {drink_query} ---")
            async for b64_image_chunk in generate_image_stream(
                image_description,
                drink_query,
                ingredients=ingredients,
                serving_glass=serving_glass,
            ):
                sse_event = {"type": "partial_image", "b64_data": b64_image_chunk}
                yield f"data: {json.dumps(sse_event)}\n\n"
            
            # After the stream from OpenAI is finished, send a completion event
            # The original generate_image_stream doesn't explicitly save or return a final filename anymore.
            # If a final "saved" confirmation is needed, that logic would need to be added back,
            # perhaps after the loop or by the client confirming receipt of all parts.
            # For now, we just stream the partials.
            print(f"--- Finished streaming partial images for: {drink_query} ---")
            yield f"data: {json.dumps({'type': 'stream_complete'})}\n\n"

        except Exception as e:
            print(f"!!! EXCEPTION in event_stream for generate_image_route: {type(e).__name__} - {str(e)} !!!")
            import traceback
            traceback.print_exc()
            # Send an error event over SSE
            error_event = {"type": "error", "message": str(e)}
            yield f"data: {json.dumps(error_event)}\n\n"

    return Response(event_stream(), mimetype='text/event-stream') # Removed stream_with_context

import asyncio # Add for asyncio.sleep

@bp.route('/test_async_stream')
async def test_async_stream():
    print("--- /test_async_stream called ---")
    async def simple_generator():
        for i in range(5):
            print(f"--- /test_async_stream yielding item {i} ---")
            await asyncio.sleep(0.2)
            yield f"data: Test Event {i}\n\n"
        print("--- /test_async_stream finished ---")
    return Response(simple_generator(), mimetype='text/event-stream')

@bp.errorhandler(openai.BadRequestError)
def handle_invalid_request_error(e):
    # This error handler might not be reached if exceptions are caught within routes
    print(f"--- OpenAI BadRequestError Handler: {e} ---")
    return jsonify({"error": "OpenAI BadRequestError", "details": str(e)}), 500

@bp.errorhandler(KeyError)
def handle_key_error(e):
    print(f"--- KeyError Handler: {e} ---")
    return jsonify({"error": "KeyError in request data", "details": str(e)}), 500

@bp.app_errorhandler(Exception) # Catch-all for other unhandled exceptions
def handle_generic_exception(e):
    print(f"--- Generic Exception Handler: {type(e).__name__} - {e} ---")
    import traceback
    traceback.print_exc()
    return jsonify({"error": "An unexpected server error occurred", "details": str(e)}), 500
