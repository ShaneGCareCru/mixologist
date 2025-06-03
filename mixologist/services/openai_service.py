import openai
import json
import logging
import os
from collections import namedtuple
from ..models import GetRecipeParams
import re
import requests

client = openai.OpenAI(api_key=os.getenv("OPENAI_API_KEY"))
Recipe = namedtuple("Recipe", ["ingredients", "alcohol_content", "steps", "rim", "garnish", "serving_glass", "drink_image_description", "drink_history", "drink_name"])

# Set up logging
logging.basicConfig(filename='app.log', level=logging.INFO)

def generate_image(prompt, user_message):
    """Generate a drink image using DALL-E."""
    response = client.images.generate(
        prompt=prompt,
        n=1,
        size="1024x1024",
    )

    # Get the image URL from the response
    image_url = response.data[0].url

    # Download the image
    img_data = requests.get(image_url).content

    # Sanitize the user message to create a valid filename
    # Remove any characters that are not alphanumeric, spaces, hyphens, or underscores
    # Then limit the length to 64 characters
    filename = re.sub(r'[^\w\s-]', '', user_message)[:64] + '.jpg'

    # Save it to the 'static' folder in your Flask app
    with open(f'mixologist/static/img/{filename}', 'wb') as handler:
        handler.write(img_data)

    return filename

def parse_recipe_arguments(arguments):
    # If arguments is a string, parse it as JSON
    if isinstance(arguments, str):
        arguments = json.loads(arguments)

    # Extract individual arguments to variables with default values
    ingredients = arguments.get("ingredients", [])
    alcohol_content = arguments.get("alcohol_content", 0)
    steps = arguments.get("steps", [])
    rim = arguments.get("rim", False)
    garnish = arguments.get("garnish", [])
    serving_glass = arguments.get("serving_glass", "")
    drink_image_description = arguments.get("drink_image_description", "")
    logging.info(f'Drink image description: {drink_image_description}')  # Log the drink image description
    drink_history = arguments.get("drink_history", "")
    drink_name = arguments.get("drink_name", "")

    return Recipe(ingredients, alcohol_content, steps, rim, garnish, serving_glass, drink_image_description, drink_history, drink_name)

def get_completion_from_messages(messages,
                                 model="gpt-3.5-turbo-0613",
                                 temperature=0.7):
    response = client.chat.completions.create(
        model=model,
        messages=messages,
        temperature=temperature,
        max_tokens=1000,
        functions=[
        {
          "name": "get_recipe",
          "description": "Get drink recipe.",
          "parameters": GetRecipeParams.schema()
        }
    ],
        function_call="auto",
    )
    function_call = response.choices[0].message.function_call
    arguments = function_call.arguments  # No JSON decoding

    # Pass the arguments dictionary to the new function
    return parse_recipe_arguments(arguments)
