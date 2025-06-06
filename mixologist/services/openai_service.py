import openai
import os
import json
import logging
from collections import namedtuple
from typing import List, Optional, Dict, AsyncGenerator # Added AsyncGenerator
import re
# import requests # No longer needed here as we yield b64 data
import base64 
import hashlib
import aiofiles
from pathlib import Path
from dotenv import load_dotenv

from ..models import GetRecipeParams

load_dotenv()

# Initialize cache directories with absolute paths
BASE_DIR = Path(__file__).parent.parent  # Go up to mixologist/ directory
IMAGE_CACHE_DIR = BASE_DIR / "static" / "img" / "cache"
RECIPE_CACHE_DIR = BASE_DIR / "static" / "cache" / "recipes"
IMAGE_CACHE_DIR.mkdir(parents=True, exist_ok=True)
RECIPE_CACHE_DIR.mkdir(parents=True, exist_ok=True)

print(f"Recipe cache directory: {RECIPE_CACHE_DIR}")
print(f"Image cache directory: {IMAGE_CACHE_DIR}")

# Style constants for consistent image generation
STYLE_CONSTANTS = {
    "cocktail": "professional cocktail photography, bar setting, moody lighting, high-resolution, clean background",
    "ingredients": "clean ingredient photography, isolated on pure white background, professional lighting, product-ready presentation",
    "glassware": "elegant barware photography, single empty glass, subtle reflections, light gray gradient background, centered composition, no liquids",
    "equipment": "professional bar tools photography, single tool isolated on pure white background, minimalist style, clean product shot",
    "garnish": "fresh garnish macro photography, isolated on white background, natural lighting, single garnish element",
    "technique": "cocktail technique demonstration, hands visible, professional bartending, motion blur effect"
}

# Prompt templates for technique/method steps
METHOD_PROMPT_TEMPLATES = {
    "blend": "cocktail blending action, {ingredients} in blender, motion blur on blades, professional bar photography, side angle view",
    "pour": "pouring {liquid} into {glass}, steady stream, professional cocktail photography, dramatic lighting, close-up angle",
    "garnish": "placing {garnish} on cocktail rim, bartender hands visible, final presentation, shallow depth of field",
}

# Fallback single pixel icon for failed generation (1x1 transparent PNG)
DEFAULT_FALLBACK_ICON_B64 = (
    "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAAAAAA6fptVAAAAC0lEQVR4nGMAAQAABQABDQottAAAAABJRU5ErkJggg=="
)

METHOD_FALLBACK_ICONS = {
    key: DEFAULT_FALLBACK_ICON_B64 for key in METHOD_PROMPT_TEMPLATES.keys()
}

def detect_primary_action(step_text: str) -> str:
    """Detect the main cocktail technique action from a step."""
    keywords = ["blend", "pour", "garnish", "shake", "stir", "muddle", "strain"]
    lower = step_text.lower()
    for word in keywords:
        if re.search(fr"\b{word}\w*\b", lower):
            return word
    return "other"

def extract_context(step_text: str) -> Dict[str, str]:
    """Extract simple context details like glass or liquid."""
    context: Dict[str, str] = {}
    lower = step_text.lower()
    glass_match = re.search(r"into (?:a |an )?(?P<glass>[^.,]*?)(?: glass)?[., ]", lower)
    if glass_match:
        context["glass"] = glass_match.group("glass").strip()
    liquid_match = re.search(r"pour ([^,\.]+)", lower)
    if liquid_match:
        context["liquid"] = liquid_match.group(1).strip()
    return context

def extract_important_details(step_text: str) -> str:
    """Return the raw step as additional details for prompting."""
    return step_text.strip()

def extract_visual_moments(step_text: str) -> Dict[str, object]:
    """Extract action and context info from a recipe step."""
    return {
        "action": detect_primary_action(step_text),
        "context": extract_context(step_text),
        "details": extract_important_details(step_text),
    }

# Ingredient categorization for appropriate image generation
INGREDIENT_CATEGORIES = {
    # Spirits and alcoholic beverages - show the liquid in a glass or small container
    "spirits": ["whiskey", "bourbon", "rye", "scotch", "vodka", "gin", "rum", "tequila", "brandy", "cognac", "liqueur"],
    "wines": ["wine", "champagne", "prosecco", "sherry", "port", "vermouth"],
    "beers": ["beer", "ale", "lager", "stout"],
    
    # Syrups and liquid ingredients - show in small glass containers or puddles
    "syrups": ["simple syrup", "syrup", "grenadine", "orgeat", "falernum"],
    
    # Bitters and tinctures - show as droplets or small glass vials
    "bitters": ["bitters", "angostura", "peychaud", "orange bitters"],
    
    # Fresh produce - show the actual fruit/vegetable
    "fresh": ["lime", "lemon", "orange", "grapefruit", "apple", "pear", "cherry", "berry", "mint", "basil", "thyme"],
    
    # Processed/prepared items - show the final form
    "processed": ["sugar cube", "salt", "pepper", "honey", "agave", "maple syrup", "cream", "milk", "egg white", "juice"],
    
    # Spices and aromatics - show the spice/herb
    "spices": ["cinnamon", "nutmeg", "clove", "cardamom", "vanilla", "ginger", "star anise"],
    
    # Water and neutral liquids - show as clear liquid
    "neutral": ["water", "soda water", "tonic water", "club soda", "sparkling water"]
}

def categorize_ingredient(ingredient_name: str) -> str:
    """Categorize an ingredient to determine appropriate visualization style."""
    ingredient_lower = ingredient_name.lower()
    
    for category, keywords in INGREDIENT_CATEGORIES.items():
        for keyword in keywords:
            if keyword in ingredient_lower:
                return category
    
    # Default to processed if no category matches
    return "processed"

def build_ingredient_prompt(ingredient_name: str) -> str:
    """Build an appropriate prompt for ingredient visualization."""
    category = categorize_ingredient(ingredient_name)
    
    if category == "spirits":
        return f"{ingredient_name} bottle, premium spirit bottle with label, isolated on white background, professional product photography, brand-style presentation"
    elif category in ["wines", "beers"]:
        return f"{ingredient_name} in appropriate glassware, isolated on white background, professional beverage photography"
    elif category == "syrups":
        return f"{ingredient_name} in a small glass pitcher or as a golden puddle, isolated on white background, professional food photography"
    elif category == "bitters":
        return f"{ingredient_name} as dark liquid droplets or in small glass dropper bottle, isolated on white background, professional product photography"
    elif category == "fresh":
        return f"fresh {ingredient_name}, whole and pristine, isolated on white background, professional food photography"
    elif category == "processed":
        return f"{ingredient_name} in its final usable form, isolated on white background, professional food photography"
    elif category == "spices":
        return f"{ingredient_name} spice, whole or ground as appropriate, isolated on white background, professional spice photography"
    elif category == "neutral":
        return f"clear {ingredient_name} in a small glass, crystalline and pure, isolated on white background, professional beverage photography"
    else:
        return f"{ingredient_name} in its most recognizable cocktail ingredient form, isolated on white background, professional product photography"

def build_cocktail_infographic_prompt(
    drink_name: str,
    ingredients: List[Dict[str, str]],
    steps: List[str],
    serving_glass: str,
    garnish: List[str] = None,
    equipment_needed: List[Dict[str, str]] = None,
    preparation_time_minutes: int = None,
    alcohol_content: float = None
) -> str:
    """Build a dynamic infographic prompt for cocktail recipes."""
    
    # Format ingredients with quantities
    ingredient_list = []
    for ingredient in ingredients[:6]:  # Limit to 6 ingredients for space
        name = ingredient.get('name', '')
        quantity = ingredient.get('quantity', '')
        ingredient_list.append(f"'{quantity} {name}'")
    
    ingredient_text = ', '.join(ingredient_list)
    
    # Format equipment/technique icons
    equipment_icons = []
    if equipment_needed:
        for equipment in equipment_needed[:4]:  # Limit to 4 items
            item = equipment.get('item', equipment) if isinstance(equipment, dict) else equipment
            if 'shaker' in item.lower():
                equipment_icons.append('cocktail shaker icon')
            elif 'jigger' in item.lower():
                equipment_icons.append('measuring jigger icon')
            elif 'strainer' in item.lower():
                equipment_icons.append('bar strainer icon')
            elif 'muddler' in item.lower():
                equipment_icons.append('muddler icon')
            elif 'spoon' in item.lower():
                equipment_icons.append('bar spoon icon')
            else:
                equipment_icons.append('bar tool icon')
    
    # If no equipment, use technique-based icons
    if not equipment_icons:
        step_text = ' '.join(steps).lower()
        if 'shake' in step_text:
            equipment_icons.append('cocktail shaker icon')
        if 'stir' in step_text:
            equipment_icons.append('bar spoon icon')
        if 'strain' in step_text:
            equipment_icons.append('strainer icon')
        if 'muddle' in step_text:
            equipment_icons.append('muddler icon')
    
    equipment_text = ', '.join(equipment_icons[:3]) if equipment_icons else 'mixing glass icon, bar spoon icon'
    
    # Format garnish
    garnish_text = garnish[0] if garnish and len(garnish) > 0 else 'cocktail garnish'
    
    # Build the comprehensive infographic prompt
    prompt = f"""Create a step-by-step cocktail recipe infographic for {drink_name}, top-down view. 
    
Minimal style on white background. Ingredient photos labeled: {ingredient_text}. 

Use dotted lines to show process steps with icons: {equipment_text} for preparation techniques, {serving_glass} for serving. 

Final plated {drink_name} cocktail shot at the bottom with {garnish_text}. 

Clean layout with soft shadows, neat typography, modern minimalist feel, professional cocktail recipe design, infographic style layout."""

    return prompt

def build_styled_prompt(subject: str, category: str, additional_context: str = "") -> str:
    """Build a prompt with consistent styling for a given category."""
    base_style = STYLE_CONSTANTS.get(category, STYLE_CONSTANTS["cocktail"])
    context_part = f" {additional_context}" if additional_context else ""
    return f"{subject}, {base_style}{context_part}"

def parse_ingredient_name(ingredient_dict: dict) -> str:
    """Extract clean ingredient name from ingredient dictionary."""
    name = ingredient_dict.get("name", "")
    # Remove common qualifiers to get base ingredient
    clean_name = name.replace("Fresh ", "").replace("Dry ", "").replace("Simple ", "")
    return clean_name.strip()

def normalize_glass_name(glass_text: str) -> str:
    """Normalize glass names for consistent image generation."""
    if not glass_text:
        return "cocktail glass"
    
    # Remove parentheses and normalize
    normalized = glass_text.lower().replace("(", "").replace(")", "").strip()
    
    # Add "glass" if not present
    if "glass" not in normalized and "cup" not in normalized:
        normalized += " glass"
    
    return normalized

# Initialize OpenAI clients with error handling
try:
    api_key = os.getenv("OPENAI_API_KEY")
    if not api_key:
        print("Warning: OPENAI_API_KEY not set. OpenAI functionality will be limited.")
        client = None
        async_client = None
    else:
        client = openai.OpenAI(api_key=api_key)
        async_client = openai.AsyncOpenAI(api_key=api_key)
except Exception as e:
    print(f"Warning: Could not initialize OpenAI client: {e}")
    client = None
    async_client = None

def generate_cache_key(prompt: str, drink_name: str, ingredients: Optional[List[Dict[str, str]]] = None, serving_glass: Optional[str] = None) -> str:
    """Generate a unique cache key based on image generation parameters."""
    # Normalize inputs for consistent hashing
    cache_input = {
        "prompt": prompt.strip().lower(),
        "drink_name": drink_name.strip().lower(),
        "ingredients": sorted([f"{i.get('quantity', '')} {i.get('name', '')}" for i in (ingredients or [])]),
        "serving_glass": (serving_glass or "").strip().lower()
    }
    
    # Create hash from normalized inputs
    cache_string = json.dumps(cache_input, sort_keys=True)
    cache_hash = hashlib.sha256(cache_string.encode()).hexdigest()[:16]
    
    return f"cocktail_{cache_hash}"

def generate_recipe_cache_key(drink_query: str) -> str:
    """Generate a unique cache key for recipe based on drink query."""
    # Normalize the drink query for consistent caching
    normalized_query = drink_query.strip().lower()
    cache_hash = hashlib.sha256(normalized_query.encode()).hexdigest()[:16]
    return f"recipe_{cache_hash}"

async def get_cached_recipe(cache_key: str) -> Optional[dict]:
    """Check if cached recipe exists and return recipe data."""
    cache_file = RECIPE_CACHE_DIR / f"{cache_key}.json"
    if cache_file.exists():
        try:
            async with aiofiles.open(cache_file, 'r') as f:
                cached_json = await f.read()
                return json.loads(cached_json)
        except Exception as e:
            print(f"Error reading cached recipe {cache_key}: {e}")
            return None
    return None

async def save_recipe_to_cache(cache_key: str, recipe_data: dict) -> None:
    """Save recipe data to cache."""
    cache_file = RECIPE_CACHE_DIR / f"{cache_key}.json"
    try:
        async with aiofiles.open(cache_file, 'w') as f:
            await f.write(json.dumps(recipe_data, indent=2))
        print(f"Saved recipe to cache: {cache_key}")
    except Exception as e:
        print(f"Error saving recipe to cache {cache_key}: {e}")

async def get_cached_image(cache_key: str) -> Optional[str]:
    """Check if cached image exists and return base64 data."""
    cache_file = IMAGE_CACHE_DIR / f"{cache_key}.txt"
    if cache_file.exists():
        try:
            async with aiofiles.open(cache_file, 'r') as f:
                cached_b64 = await f.read()
                return cached_b64.strip()
        except Exception as e:
            print(f"Error reading cached image {cache_key}: {e}")
            return None
    return None

async def save_image_to_cache(cache_key: str, b64_data: str) -> None:
    """Save base64 image data to cache."""
    cache_file = IMAGE_CACHE_DIR / f"{cache_key}.txt"
    try:
        async with aiofiles.open(cache_file, 'w') as f:
            await f.write(b64_data)
        print(f"Saved image to cache: {cache_key}")
    except Exception as e:
        print(f"Error saving image to cache {cache_key}: {e}")
Recipe = namedtuple("Recipe", [
    # Original fields
    "ingredients", "alcohol_content", "steps", "rim", "garnish", "serving_glass", 
    "drink_image_description", "drink_history", "drink_name",
    # Enhanced fields
    "brand_recommendations", "ingredient_substitutions", "related_cocktails",
    "difficulty_rating", "preparation_time_minutes", "equipment_needed",
    "flavor_profile", "serving_size_base", "phonetic_pronunciations",
    "enhanced_steps", "suggested_variations", "food_pairings",
    "optimal_serving_temperature", "skill_level_recommendation"
])

logging.basicConfig(filename='app.log', level=logging.INFO)

async def generate_specialized_image_stream(
    subject: str,
    category: str,
    additional_context: str = "",
    cache_prefix: str = ""
) -> AsyncGenerator[str, None]:
    """Generate specialized images with consistent styling and caching."""
    
    if async_client is None:
        raise Exception("OpenAI async client not initialized. Please set OPENAI_API_KEY environment variable.")

    # Build styled prompt - use special ingredient prompts for better results
    if category == "ingredients":
        styled_prompt = build_ingredient_prompt(subject)
    else:
        styled_prompt = build_styled_prompt(subject, category, additional_context)
    
    # Generate cache key based on category
    if category in ["ingredients", "equipment"]:
        # For reusable assets, cache by clean subject name only
        cache_key_input = f"{category}_{subject.lower().strip()}"
    else:
        # For other categories, include context
        cache_key_input = f"{cache_prefix}_{subject}_{category}_{additional_context}"
    
    cache_hash = hashlib.sha256(cache_key_input.encode()).hexdigest()[:16]
    cache_key = f"{category}_{cache_hash}"
    
    print(f"--- Generated cache key: {cache_key} for {category} image ---")
    
    # Check for cached image first
    cached_image = await get_cached_image(cache_key)
    if cached_image:
        print(f"--- Found cached {category} image for {subject}, returning cached data ---")
        yield cached_image
        return

    print(f"--- No cached {category} image found for {subject}, generating new image ---")
    
    main_input_prompt = f"Generate an image of: {styled_prompt}"
    print(f"--- Calling Responses API for {category} image generation with input: {main_input_prompt[:200]}... ---")

    text_model_for_responses_api = "gpt-4.1-mini-2025-04-14" 
    final_image_b64 = ""
    
    try:
        stream = await async_client.responses.create(
            model=text_model_for_responses_api,
            input=main_input_prompt, 
            stream=True,
            tools=[{
                "type": "image_generation",
                "quality": "low",  # Low quality for development speed
                "size": "1024x1024",  # Square size for ingredients/equipment
                "background": "opaque",  # White background for ingredients/equipment
                "partial_images": 2, 
            }],
        )

        async for event in stream:
            print(f"--- {category.title()} Image Gen Stream Event: {event.type} ---")
            if event.type == "response.image_generation_call.partial_image":
                image_base64_partial = event.partial_image_b64
                idx = event.partial_image_index
                if image_base64_partial:
                    print(f"--- Yielding partial {category} image {idx} (b64_json): {image_base64_partial[:10]}... (truncated) ---")
                    final_image_b64 = image_base64_partial
                    yield image_base64_partial

        # Save the final image to cache
        if final_image_b64:
            await save_image_to_cache(cache_key, final_image_b64)

    except Exception as e:
        print(f"Error during OpenAI Responses API call for {category} image stream: {type(e).__name__} - {e}")
        import traceback
        traceback.print_exc()
        raise 

    print(f"--- {category.title()} image generation stream finished for {subject} ---")

async def generate_method_image_stream(step_text: str, step_index: int = 0) -> AsyncGenerator[str, None]:
    """Generate an illustrative technique image for a recipe method step."""
    moment = extract_visual_moments(step_text)
    template = METHOD_PROMPT_TEMPLATES.get(moment["action"], f"{moment['action']} cocktail technique, professional bar scene")
    try:
        prompt_subject = template.format(**moment["context"])
    except Exception:
        prompt_subject = template

    try:
        async for chunk in generate_specialized_image_stream(
            subject=prompt_subject,
            category="technique",
            additional_context="",
            cache_prefix=f"method_{step_index}"
        ):
            yield chunk
    except Exception as e:
        logging.error(f"Method image generation failed: {e}")
        fallback = METHOD_FALLBACK_ICONS.get(moment["action"], DEFAULT_FALLBACK_ICON_B64)
        yield fallback

async def generate_image_stream( # Renamed to indicate streaming and generator
    prompt: str,
    drink_name: str,
    ingredients: Optional[List[Dict[str, str]]] = None,
    serving_glass: Optional[str] = None,
    steps: Optional[List[str]] = None,
    garnish: Optional[List[str]] = None,
    equipment_needed: Optional[List[Dict[str, str]]] = None,
    preparation_time_minutes: Optional[int] = None,
    alcohol_content: Optional[float] = None,
) -> AsyncGenerator[str, None]: # Changed return type to AsyncGenerator yielding strings (b64_json)
    """Generate a cocktail infographic using the Responses API and stream partial image base64 data with caching."""

    if async_client is None:
        raise Exception("OpenAI async client not initialized. Please set OPENAI_API_KEY environment variable.")

    # Generate cache key for this image request
    cache_key = generate_cache_key(prompt, drink_name, ingredients, serving_glass)
    print(f"--- Generated cache key: {cache_key} ---")
    
    # Check for cached image first
    cached_image = await get_cached_image(cache_key)
    if cached_image:
        print(f"--- Found cached image for {drink_name}, returning cached data ---")
        yield cached_image
        return

    print(f"--- No cached image found for {drink_name}, generating new image ---")

    # Build infographic-style prompt instead of simple cocktail image
    if ingredients and len(ingredients) > 0:
        main_input_prompt = build_cocktail_infographic_prompt(
            drink_name=drink_name,
            ingredients=ingredients,
            steps=steps or [],
            serving_glass=serving_glass or "cocktail glass",
            garnish=garnish,
            equipment_needed=equipment_needed
        )
    else:
        # Fallback to simple cocktail image if no ingredients data
        styled_prompt = build_styled_prompt(f"{drink_name} cocktail", "cocktail", f"served in {serving_glass or 'appropriate glassware'}")
        main_input_prompt = f"Generate an image of: {styled_prompt}, transparent background, isolated cocktail on transparent background"

    print(f"--- Calling Responses API for image generation (streaming) with input: {main_input_prompt[:200]}... ---")

    text_model_for_responses_api = "gpt-4.1-mini-2025-04-14" 
    
    # Store the final image for caching
    final_image_b64 = ""
    
    try:
        stream = await async_client.responses.create(
            model=text_model_for_responses_api,
            input=main_input_prompt, 
            stream=True,
            tools=[{
                "type": "image_generation",
                "quality": "auto",  # Auto quality for better infographic details
                "size": "1536x1024",  # Largest supported landscape size for infographic
                "background": "transparent",  # Transparent background
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
                    # Store the latest partial as potential final image
                    final_image_b64 = image_base64_partial
                    yield image_base64_partial
            # We are no longer looking for a single "final" image within this function.
            # We yield all partials. The client (Flask route) will decide what to do.
            # A 'response.tool_calls' event with a final result might still occur,
            # but for streaming partials, the partial_image events are key.

        # Save the final image to cache
        if final_image_b64:
            await save_image_to_cache(cache_key, final_image_b64)

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
    
    # Original fields
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
    
    # Enhanced fields - extract from AI response
    brand_recommendations = arguments.get("brand_recommendations", [])
    ingredient_substitutions = arguments.get("ingredient_substitutions", [])
    related_cocktails = arguments.get("related_cocktails", [])
    difficulty_rating = arguments.get("difficulty_rating", 3)
    preparation_time_minutes = arguments.get("preparation_time_minutes", 5)
    equipment_needed = arguments.get("equipment_needed", [])
    flavor_profile = arguments.get("flavor_profile")
    serving_size_base = arguments.get("serving_size_base")
    phonetic_pronunciations = arguments.get("phonetic_pronunciations", {})
    enhanced_steps = arguments.get("enhanced_steps", [])
    suggested_variations = arguments.get("suggested_variations", [])
    food_pairings = arguments.get("food_pairings", [])
    optimal_serving_temperature = arguments.get("optimal_serving_temperature", "")
    skill_level_recommendation = arguments.get("skill_level_recommendation", "")
    
    return Recipe(
        # Original fields
        ingredients, alcohol_content, steps, rim, garnish, serving_glass, 
        drink_image_description, drink_history, drink_name,
        # Enhanced fields
        brand_recommendations, ingredient_substitutions, related_cocktails,
        difficulty_rating, preparation_time_minutes, equipment_needed,
        flavor_profile, serving_size_base, phonetic_pronunciations,
        enhanced_steps, suggested_variations, food_pairings,
        optimal_serving_temperature, skill_level_recommendation
    )

def get_completion_from_messages(messages,
                                 model="gpt-4.1-mini-2025-04-14",
                                 temperature=0.7):
    if client is None:
        raise Exception("OpenAI client not initialized. Please set OPENAI_API_KEY environment variable.")
    
    response = client.chat.completions.create(
        model=model,
        messages=messages,
        temperature=temperature,
        max_tokens=2000,  # Increased for complex responses
        functions=[{
          "name": "get_recipe",
          "description": "Get drink recipe.",
          "parameters": GetRecipeParams.model_json_schema()
        }],
        function_call="auto",
    )
    
    # Better error handling for function calls
    message = response.choices[0].message
    if not message.function_call:
        raise Exception("OpenAI did not return a function call")
    
    function_call = message.function_call
    if not function_call.arguments:
        raise Exception("OpenAI function call has no arguments")
    
    # Log the raw arguments for debugging
    logging.info(f"Raw OpenAI arguments: {function_call.arguments[:500]}...")
    
    try:
        arguments = function_call.arguments
        return parse_recipe_arguments(arguments)
    except json.JSONDecodeError as e:
        logging.error(f"JSON decode error: {e}")
        logging.error(f"Raw arguments: {function_call.arguments}")
        raise Exception(f"Invalid JSON response from OpenAI: {e}")
