import openai
import os
import json
import logging
from collections import namedtuple
from typing import List, Optional, Dict, AsyncGenerator # Added AsyncGenerator
import re
# import requests # No longer needed here as we yield b64 data
import base64 
from dotenv import load_dotenv

from ..models import GetRecipeParams

load_dotenv()

client = openai.OpenAI(api_key=os.getenv("OPENAI_API_KEY"))
async_client = openai.AsyncOpenAI(api_key=os.getenv("OPENAI_API_KEY"))
Recipe = namedtuple("Recipe", ["ingredients", "alcohol_content", "steps", "rim", "garnish", "serving_glass", "drink_image_description", "drink_history", "drink_name"])

logging.basicConfig(filename='app.log', level=logging.INFO)

async def generate_image_stream( # Renamed to indicate streaming and generator
    prompt: str,
    drink_name: str, # drink_name might still be useful for context or if we decide to save one image later
    ingredients: Optional[List[Dict[str, str]]] = None,
    serving_glass: Optional[str] = None,
) -> AsyncGenerator[str, None]: # Changed return type to AsyncGenerator yielding strings (b64_json)
    """Generate a drink image using the Responses API and stream partial image base64 data."""

    ingredient_list = ""
    if ingredients:
        readable = [f"{i['quantity']} {i['name']}" for i in ingredients]
        ingredient_list = " Ingredients: " + ", ".join(readable) + "."
    glass_part = f" Served in a {serving_glass}." if serving_glass else ""
    
    image_tool_prompt_details = (
        f"{prompt}.{ingredient_list}{glass_part}"
        f" Show the {drink_name} cocktail in a professional, high-resolution "
        "food photograph with natural lighting and a clean background."
    )
    main_input_prompt = f"Generate an image of: {image_tool_prompt_details}"

    print(f"--- Calling Responses API for image generation (streaming) with input: {main_input_prompt[:200]}... ---")

    text_model_for_responses_api = "gpt-4.1-mini-2025-04-14" 
    
    try:
        stream = await async_client.responses.create(
            model=text_model_for_responses_api,
            input=main_input_prompt, 
            stream=True,
            tools=[{
                "type": "image_generation",
                "quality": "high", 
                "size": "1024x1024", # Consider smaller size for faster partials if needed
                "partial_images": 2, 
            }],
        )

        async for event in stream:
            print(f"--- Image Gen Stream Event: {event.type} ---")
            if event.type == "response.image_generation_call.partial_image":
                image_base64_partial = event.partial_image_b64
                idx = event.partial_image_index
                if image_base64_partial:
                    print(f"--- Yielding partial image {idx} (b64_json): {image_base64_partial[:10]}... (truncated) ---")
                    yield image_base64_partial
            # We are no longer looking for a single "final" image within this function.
            # We yield all partials. The client (Flask route) will decide what to do.
            # A 'response.tool_calls' event with a final result might still occur,
            # but for streaming partials, the partial_image events are key.

    except Exception as e:
        print(f"Error during OpenAI Responses API call for image stream: {type(e).__name__} - {e}")
        import traceback
        traceback.print_exc()
        # How to signal error to an async generator's consumer?
        # One way is to yield a special error marker or just let the exception propagate
        # and have the Flask route handle it. For now, let it propagate.
        raise 

    # This function no longer saves the file or returns a filename. It yields b64 strings.
    print(f"--- Image generation stream from OpenAI finished for {drink_name} ---")


def parse_recipe_arguments(arguments):
    if isinstance(arguments, str):
        arguments = json.loads(arguments)
    ingredients = arguments.get("ingredients", [])
    alcohol_content = arguments.get("alcohol_content", 0)
    steps = arguments.get("steps", [])
    rim = arguments.get("rim", False)
    garnish = arguments.get("garnish", [])
    serving_glass = arguments.get("serving_glass", "")
    drink_image_description = arguments.get("drink_image_description", "")
    logging.info(f'Drink image description: {drink_image_description}')
    drink_history = arguments.get("drink_history", "")
    drink_name = arguments.get("drink_name", "")
    return Recipe(ingredients, alcohol_content, steps, rim, garnish, serving_glass, drink_image_description, drink_history, drink_name)

def get_completion_from_messages(messages,
                                 model="gpt-4.1-mini-2025-04-14",
                                 temperature=0.7):
    response = client.chat.completions.create(
        model=model,
        messages=messages,
        temperature=temperature,
        max_tokens=1000,
        functions=[{
          "name": "get_recipe",
          "description": "Get drink recipe.",
          "parameters": GetRecipeParams.schema()
        }],
        function_call="auto",
    )
    function_call = response.choices[0].message.function_call
    arguments = function_call.arguments 
    return parse_recipe_arguments(arguments)
