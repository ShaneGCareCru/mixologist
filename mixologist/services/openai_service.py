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
# Database imports
from ..database.config import get_db_session, get_mongo_collection
from ..database.service import DatabaseService

load_dotenv()

# Initialize cache directories with absolute paths
BASE_DIR = Path(__file__).parent.parent  # Go up to mixologist/ directory
# IMAGE_CACHE_DIR = BASE_DIR / "static" / "img" / "cache"
# RECIPE_CACHE_DIR = BASE_DIR / "static" / "cache" / "recipes"
# IMAGE_CACHE_DIR.mkdir(parents=True, exist_ok=True)
# RECIPE_CACHE_DIR.mkdir(parents=True, exist_ok=True)
# print(f"Recipe cache directory: {RECIPE_CACHE_DIR}")
# print(f"Image cache directory: {IMAGE_CACHE_DIR}")

# Style constants for consistent image generation
STYLE_CONSTANTS = {
    "cocktail": "professional cocktail photography, bar setting, moody lighting, high-resolution, clean background",
    # Ingredients now use a richer food photography setting
    "ingredients": "high-end food photography, subtle kitchen background, professional lighting, product-ready presentation",
    "glassware": "elegant barware photography, single empty glass, subtle reflections, light gray gradient background, centered composition, no liquids",
    # Equipment shots blend with a bar environment for realism
    "equipment": "professional bar tools photography, subtle bar background, soft shadows, clean product shot",
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

# --- Canonical step handling for method image caching ---

CANONICAL_STEP_PATTERNS = {
    r"salt(ed)? the rim": "salt rim glass",
    r"strain .* into": "strain into glass",
    r"shake": "shake with ice",
    r"stir": "stir ingredients",
    r"muddle": "muddle ingredients",
    r"garnish": "garnish drink",
    r"pour": "pour into glass",
}

def canonicalize_step_text(step_text: str) -> str:
    """Normalize a recipe step into a canonical phrase."""
    normalized = step_text.lower()
    for pattern, replacement in CANONICAL_STEP_PATTERNS.items():
        if re.search(pattern, normalized):
            return replacement
    return re.sub(r"[^a-z0-9 ]+", "", normalized).strip()

def canonicalize_step(step_text: str) -> str:
    """Alias for canonicalize_step_text to maintain test compatibility."""
    return canonicalize_step_text(step_text)

async def get_cached_step_image(step_text: str) -> Optional[str]:
    step_hash = hashlib.sha256(canonicalize_step_text(step_text).encode()).hexdigest()[:16]
    cache_key = await get_step_image_mapping(step_hash)
    if cache_key:
        return await get_cached_image(cache_key)
    return None

async def save_step_image_mapping(step_text: str, cache_key: str) -> None:
    step_hash = hashlib.sha256(canonicalize_step_text(step_text).encode()).hexdigest()[:16]
    await set_step_image_mapping(step_hash, cache_key)

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
    """Check if cached recipe exists and return recipe data from database only."""
    try:
        async with get_db_session() as session:
            db_service = DatabaseService(session)
            recipe_data = await db_service.get_recipe_by_cache_key(cache_key)
            if recipe_data:
                print(f"Retrieved recipe from database: {cache_key}")
                return recipe_data
            return None
    except Exception as e:
        print(f"Error getting cached recipe {cache_key}: {e}")
        return None

async def save_recipe_to_cache(cache_key: str, recipe_data: dict) -> None:
    """Save recipe data to database only."""
    try:
        async with get_db_session() as session:
            db_service = DatabaseService(session)
            success = await db_service.save_recipe(cache_key, recipe_data)
            if success:
                print(f"Saved recipe to database: {cache_key}")
            else:
                print(f"Failed to save recipe to database: {cache_key}")
    except Exception as e:
        print(f"Error saving recipe to cache {cache_key}: {e}")

async def get_cached_image(cache_key: str) -> Optional[str]:
    """Check if cached image exists and return base64 data from MongoDB only."""
    image_data = await MongoDBImageService.get_image(cache_key)
    if image_data:
        print(f"Retrieved image from MongoDB: {cache_key}")
        return image_data
    return None

async def save_image_to_cache(cache_key: str, b64_data: str) -> None:
    """Save base64 image data to MongoDB only."""
    try:
        category = cache_key.split("_")[0] if "_" in cache_key else "unknown"
        success = await MongoDBImageService.save_image(cache_key, category, b64_data)
        if success:
            print(f"Saved image to MongoDB: {cache_key}")
        else:
            print(f"Failed to save image to MongoDB: {cache_key}")
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
    "optimal_serving_temperature", "skill_level_recommendation", "drink_trivia"
])

logging.basicConfig(filename='app.log', level=logging.DEBUG)
logger = logging.getLogger(__name__)

async def generate_specialized_image_stream(
    subject: str,
    category: str,
    additional_context: str = "",
    cache_prefix: str = ""
) -> AsyncGenerator[str, None]:
    """Generate specialized images with consistent styling and caching."""
    
    if async_client is None:
        raise Exception("OpenAI async client not initialized. Please set OPENAI_API_KEY environment variable.")

    # Build prompt - ingredients and equipment get an extra LLM refinement
    if category in ["ingredients", "equipment"]:
        styled_prompt = await _build_food_photography_prompt(subject, category)
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

async def _build_food_photography_prompt(subject: str, category: str) -> str:
    """Use GPT-4.1 to craft an ideal food photography prompt for an item."""
    if async_client is None:
        raise Exception("OpenAI async client not initialized. Please set OPENAI_API_KEY environment variable.")

    base_description = build_ingredient_prompt(subject) if category == "ingredients" else subject

    background_style = "kitchen background" if category == "ingredients" else "bar background"

    messages = [
        {
            "role": "system",
            "content": (
                "You are a culinary photography prompt expert. "
                "Rewrite the provided description into a concise prompt for a professional food photo. "
                f"Include a subtle {background_style} and keep focus on the item."
            ),
        },
        {
            "role": "user",
            "content": f"Description: {base_description}\nReturn the improved prompt.",
        },
    ]

    response = await async_client.chat.completions.create(
        model="gpt-4.1-mini-2025-04-14",
        messages=messages,
        temperature=0.5,
        max_tokens=60,
    )

    return response.choices[0].message.content.strip()

async def _build_method_prompt(
    step_text: str,
    drink_name: str = "",
    ingredients: Optional[List[str]] = None,
    equipment: Optional[List[str]] = None,
) -> str:
    """Use GPT-4.1 to craft a short image subject for a method step."""
    if async_client is None:
        raise Exception("OpenAI async client not initialized. Please set OPENAI_API_KEY environment variable.")

    ingredient_text = ", ".join(ingredients or [])
    equipment_text = ", ".join(equipment or [])

    messages = [
        {
            "role": "system",
            "content": (
                "You create concise photographic scene descriptions of a bartender demonstrating a cocktail step. "
                "Reply with a short phrase, no more than one sentence."
            ),
        },
        {
            "role": "user",
            "content": (
                f"Drink: {drink_name}\n"
                f"Step: {step_text}\n"
                f"Visible ingredients: {ingredient_text}\n"
                f"Equipment in view: {equipment_text}\n"
                "Describe the image subject."
            ),
        },
    ]

    response = await async_client.chat.completions.create(
        model="gpt-4.1-mini-2025-04-14",
        messages=messages,
        temperature=0.5,
        max_tokens=60,
    )

    return response.choices[0].message.content.strip()


async def generate_method_image_stream(
    step_text: str,
    step_index: int = 0,
    drink_name: str = "",
    ingredients: Optional[List[str]] = None,
    equipment: Optional[List[str]] = None,
) -> AsyncGenerator[str, None]:
    """Generate an illustrative technique image for a recipe method step."""

    # Check for an existing image mapped to this step
    cached_step_image = await get_cached_step_image(step_text)
    if cached_step_image:
        yield cached_step_image
        return

    try:
        prompt_subject = await _build_method_prompt(
            step_text,
            drink_name=drink_name,
            ingredients=ingredients,
            equipment=equipment,
        )
    except Exception as e:
        logging.error(f"Method prompt generation failed: {e}")
        prompt_subject = step_text

    cache_prefix = f"method_{step_index}"
    cache_key_input = f"{cache_prefix}_{prompt_subject}_technique_"
    cache_hash = hashlib.sha256(cache_key_input.encode()).hexdigest()[:16]
    cache_key = f"technique_{cache_hash}"

    last_chunk = None

    try:
        async for chunk in generate_specialized_image_stream(
            subject=prompt_subject,
            category="technique",
            additional_context="",
            cache_prefix=cache_prefix,
        ):
            last_chunk = chunk
            yield chunk
    except Exception as e:
        logging.error(f"Method image generation failed: {e}")
        yield DEFAULT_FALLBACK_ICON_B64
    else:
        if last_chunk:
            await save_step_image_mapping(step_text, cache_key)

async def generate_image_stream( # Renamed to indicate streaming and generator
    prompt: str,
    drink_name: str,
    ingredients: Optional[List] = None,  # Accept both List[str] and List[Dict[str, str]]
    serving_glass: Optional[str] = None,
    steps: Optional[List[str]] = None,
    garnish: Optional[List[str]] = None,
    equipment_needed: Optional[List] = None,  # Accept both formats
    preparation_time_minutes: Optional[int] = None,
    alcohol_content: Optional[float] = None,
) -> AsyncGenerator[str, None]: # Changed return type to AsyncGenerator yielding strings (b64_json)
    """Generate a cocktail infographic using the Responses API and stream partial image base64 data with caching."""

    if async_client is None:
        raise Exception("OpenAI async client not initialized. Please set OPENAI_API_KEY environment variable.")

    # Convert ingredients from list of strings to list of dicts if needed
    normalized_ingredients = []
    if ingredients:
        for ingredient in ingredients:
            if isinstance(ingredient, str):
                # Parse string format like "2 oz Cognac" into {"quantity": "2 oz", "name": "Cognac"}
                parts = ingredient.strip().split(' ', 2)  # Split into max 3 parts
                if len(parts) >= 3:
                    quantity = f"{parts[0]} {parts[1]}"
                    name = ' '.join(parts[2:])
                elif len(parts) == 2:
                    quantity = parts[0]
                    name = parts[1]
                else:
                    quantity = ""
                    name = ingredient
                normalized_ingredients.append({"quantity": quantity, "name": name})
            elif isinstance(ingredient, dict):
                normalized_ingredients.append(ingredient)
            else:
                # Fallback for unexpected types
                normalized_ingredients.append({"quantity": "", "name": str(ingredient)})
    
    # Convert equipment_needed from list of strings to list of dicts if needed
    normalized_equipment = []
    if equipment_needed:
        for equipment in equipment_needed:
            if isinstance(equipment, str):
                normalized_equipment.append({"item": equipment})
            elif isinstance(equipment, dict):
                normalized_equipment.append(equipment)
            else:
                normalized_equipment.append({"item": str(equipment)})

    # Generate cache key for this image request
    cache_key = generate_cache_key(prompt, drink_name, normalized_ingredients, serving_glass)
    print(f"--- Generated cache key: {cache_key} ---")
    
    # Check for cached image first
    cached_image = await get_cached_image(cache_key)
    if cached_image:
        print(f"--- Found cached image for {drink_name}, returning cached data ---")
        yield cached_image
        return

    print(f"--- No cached image found for {drink_name}, generating new image ---")

    # Build infographic-style prompt instead of simple cocktail image
    if normalized_ingredients and len(normalized_ingredients) > 0:
        main_input_prompt = build_cocktail_infographic_prompt(
            drink_name=drink_name,
            ingredients=normalized_ingredients,
            steps=steps or [],
            serving_glass=serving_glass or "cocktail glass",
            garnish=garnish,
            equipment_needed=normalized_equipment
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
                "size": "1024x1536",  # Phone portrait size only
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
    drink_trivia = arguments.get("drink_trivia", [])
    
    # Always ensure we have at least one trivia fact
    if not drink_trivia and drink_name:
        drink_trivia = [
            {
                "fact": f"The {drink_name} is a beloved cocktail enjoyed worldwide with many regional variations and personal interpretations.",
                "category": "culture",
                "source_period": "modern"
            }
        ]
    
    # Debug fallback trivia
    print(f"=== PARSE_RECIPE_ARGUMENTS DEBUG ===")
    print(f"drink_name: {drink_name}")
    print(f"drink_trivia from OpenAI: {arguments.get('drink_trivia', 'NOT PROVIDED')}")
    print(f"final drink_trivia: {drink_trivia}")
    print(f"final trivia length: {len(drink_trivia) if drink_trivia else 0}")
    print("=======================================")
    
    return Recipe(
        # Original fields
        ingredients, alcohol_content, steps, rim, garnish, serving_glass, 
        drink_image_description, drink_history, drink_name,
        # Enhanced fields
        brand_recommendations, ingredient_substitutions, related_cocktails,
        difficulty_rating, preparation_time_minutes, equipment_needed,
        flavor_profile, serving_size_base, phonetic_pronunciations,
        enhanced_steps, suggested_variations, food_pairings,
        optimal_serving_temperature, skill_level_recommendation, drink_trivia
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

class MongoDBImageService:
    """Service for storing and retrieving images in MongoDB."""
    @staticmethod
    async def save_image(cache_key: str, category: str, b64_data: str, **metadata) -> bool:
        try:
            async with get_mongo_collection() as collection:
                doc = {
                    "cache_key": cache_key,
                    "category": category,
                    "b64_data": b64_data,
                    **metadata
                }
                logger.debug(f"Saving image to MongoDB: {cache_key}, category: {category}")
                result = await collection.update_one(
                    {"cache_key": cache_key},
                    {"$set": doc},
                    upsert=True
                )
                if result.acknowledged:
                    logger.info(f"Image saved to MongoDB: {cache_key}")
                else:
                    logger.error(f"Image save to MongoDB not acknowledged: {cache_key}")
                return result.acknowledged
        except Exception as e:
            logger.error(f"Error saving image to MongoDB: {cache_key}: {e}")
            return False

    @staticmethod
    async def get_image(cache_key: str) -> str | None:
        try:
            async with get_mongo_collection() as collection:
                logger.debug(f"Fetching image from MongoDB: {cache_key}")
                doc = await collection.find_one({"cache_key": cache_key})
                if doc:
                    logger.debug(f"Image found in MongoDB: {cache_key}")
                    return doc.get("b64_data")
                logger.debug(f"Image not found in MongoDB: {cache_key}")
                return None
        except Exception as e:
            logger.error(f"Error fetching image from MongoDB: {cache_key}: {e}")
            return None

    @staticmethod
    async def get_images_by_category(category: str) -> list[dict]:
        try:
            async with get_mongo_collection() as collection:
                logger.debug(f"Fetching images by category from MongoDB: {category}")
                if category == "all":
                    cursor = collection.find({})
                else:
                    cursor = collection.find({"category": category})
                images = []
                async for doc in cursor:
                    images.append({
                        "cache_key": doc.get("cache_key"),
                        "category": doc.get("category"),
                        "b64_data": doc.get("b64_data"),
                    })
                logger.debug(f"Fetched {len(images)} images from MongoDB for category: {category}")
                return images
        except Exception as e:
            logger.error(f"Error fetching images by category from MongoDB: {category}: {e}")
            return []

STEP_IMAGE_INDEX_COLLECTION = "step_image_index"

async def get_step_image_mapping(step_hash: str) -> str | None:
    try:
        async with get_mongo_collection(STEP_IMAGE_INDEX_COLLECTION) as collection:
            logger.debug(f"Fetching step image mapping from MongoDB: {step_hash}")
            doc = await collection.find_one({"step_hash": step_hash})
            if doc:
                logger.debug(f"Step image mapping found in MongoDB: {step_hash}")
                return doc.get("cache_key")
            logger.debug(f"Step image mapping not found in MongoDB: {step_hash}")
            return None
    except Exception as e:
        logger.error(f"Error fetching step image mapping from MongoDB: {step_hash}: {e}")
        return None

async def set_step_image_mapping(step_hash: str, cache_key: str) -> None:
    try:
        async with get_mongo_collection(STEP_IMAGE_INDEX_COLLECTION) as collection:
            logger.debug(f"Saving step image mapping to MongoDB: {step_hash} -> {cache_key}")
            await collection.update_one(
                {"step_hash": step_hash},
                {"$set": {"step_hash": step_hash, "cache_key": cache_key}},
                upsert=True
            )
            logger.info(f"Step image mapping saved to MongoDB: {step_hash} -> {cache_key}")
    except Exception as e:
        logger.error(f"Error saving step image mapping to MongoDB: {step_hash} -> {cache_key}: {e}")
