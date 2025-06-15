import os
import json
import logging
import hashlib
from typing import List, Optional, AsyncGenerator
from pathlib import Path

# Fallback single pixel icon for failed generation (1x1 transparent PNG)
DEFAULT_FALLBACK_ICON_B64 = (
    "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAAAAAA6fptVAAAAC0lEQVR4nGMAAQAABQABDQottAAAAABJRU5ErkJggg=="
)

STYLE_CONSTANTS = {
    "cocktail": "professional cocktail photography, bar setting, moody lighting, high-resolution, clean background",
    "ingredients": "high-end food photography, subtle kitchen background, professional lighting, product-ready presentation",
    "glassware": "elegant barware photography, single empty glass, subtle reflections, light gray gradient background, centered composition, no liquids",
    "equipment": "professional bar tools photography, subtle bar background, soft shadows, clean product shot",
    "garnish": "fresh garnish macro photography, isolated on white background, natural lighting, single garnish element",
    "technique": "cocktail technique demonstration, hands visible, professional bartending, motion blur effect"
}

METHOD_PROMPT_TEMPLATES = {
    "blend": "cocktail blending action, {ingredients} in blender, motion blur on blades, professional bar photography, side angle view",
    "pour": "pouring {liquid} into {glass}, steady stream, professional cocktail photography, dramatic lighting, close-up angle",
    "garnish": "placing {garnish} on cocktail rim, bartender hands visible, final presentation, shallow depth of field",
}

METHOD_FALLBACK_ICONS = {
    key: DEFAULT_FALLBACK_ICON_B64 for key in METHOD_PROMPT_TEMPLATES.keys()
}

# The following functions require async_client, build_styled_prompt, get_cached_image, save_image_to_cache, etc.
# For now, assume these are imported from their respective modules (to be split next)

async def generate_specialized_image_stream(
    subject: str,
    category: str,
    additional_context: str = "",
    cache_prefix: str = ""
) -> AsyncGenerator[str, None]:
    """Generate specialized images with consistent styling and caching."""
    from .openai_service import async_client, build_styled_prompt, get_cached_image, save_image_to_cache
    if async_client is None:
        raise Exception("OpenAI async client not initialized. Please set OPENAI_API_KEY environment variable.")

    if category in ["ingredients", "equipment"]:
        styled_prompt = await _build_food_photography_prompt(subject, category)
    else:
        styled_prompt = build_styled_prompt(subject, category, additional_context)

    if category in ["ingredients", "equipment"]:
        cache_key_input = f"{category}_{subject.lower().strip()}"
    else:
        cache_key_input = f"{cache_prefix}_{subject}_{category}_{additional_context}"

    cache_hash = hashlib.sha256(cache_key_input.encode()).hexdigest()[:16]
    cache_key = f"{category}_{cache_hash}"

    print(f"--- Generated cache key: {cache_key} for {category} image ---")

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
                "quality": "low",
                "size": "1024x1024",
                "background": "opaque",
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

        if final_image_b64:
            await save_image_to_cache(cache_key, final_image_b64)

    except Exception as e:
        print(f"Error during OpenAI Responses API call for {category} image stream: {type(e).__name__} - {e}")
        import traceback
        traceback.print_exc()
        raise 

    print(f"--- {category.title()} image generation stream finished for {subject} ---")

async def _build_food_photography_prompt(subject: str, category: str) -> str:
    from .openai_service import async_client, build_ingredient_prompt
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
    from .openai_service import async_client
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
    from .openai_service import get_cached_step_image, save_step_image_mapping
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

async def generate_image_stream(
    prompt: str,
    drink_name: str,
    ingredients: Optional[List] = None,
    serving_glass: Optional[str] = None,
    steps: Optional[List[str]] = None,
    garnish: Optional[List[str]] = None,
    equipment_needed: Optional[List] = None,
    preparation_time_minutes: Optional[int] = None,
    alcohol_content: Optional[float] = None,
) -> AsyncGenerator[str, None]:
    from .openai_service import async_client, build_styled_prompt, get_cached_image, save_image_to_cache
    if async_client is None:
        raise Exception("OpenAI async client not initialized. Please set OPENAI_API_KEY environment variable.")

    normalized_ingredients = []
    if ingredients:
        for ingredient in ingredients:
            if isinstance(ingredient, str):
                parts = ingredient.strip().split(' ', 2)
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
                normalized_ingredients.append({"quantity": "", "name": str(ingredient)})

    normalized_equipment = []
    if equipment_needed:
        for equipment in equipment_needed:
            if isinstance(equipment, str):
                normalized_equipment.append({"item": equipment})
            elif isinstance(equipment, dict):
                normalized_equipment.append(equipment)
            else:
                normalized_equipment.append({"item": str(equipment)})

    cache_key = build_styled_prompt(prompt, drink_name, normalized_ingredients, serving_glass)
    print(f"--- Generated cache key: {cache_key} ---")

    cached_image = await get_cached_image(cache_key)
    if cached_image:
        print(f"--- Found cached image for {drink_name}, returning cached data ---")
        yield cached_image
        return

    print(f"--- No cached image found for {drink_name}, generating new image ---")

    if normalized_ingredients and len(normalized_ingredients) > 0:
        main_input_prompt = build_styled_prompt(
            drink_name=drink_name,
            ingredients=normalized_ingredients,
            steps=steps or [],
            serving_glass=serving_glass or "cocktail glass",
            garnish=garnish,
            equipment_needed=normalized_equipment
        )
    else:
        styled_prompt = build_styled_prompt(f"{drink_name} cocktail", "cocktail", f"served in {serving_glass or 'appropriate glassware'}")
        main_input_prompt = f"Generate an image of: {styled_prompt}, transparent background, isolated cocktail on transparent background"

    print(f"--- Calling Responses API for image generation (streaming) with input: {main_input_prompt[:200]}... ---")

    text_model_for_responses_api = "gpt-4.1-mini-2025-04-14" 
    final_image_b64 = ""

    try:
        stream = await async_client.responses.create(
            model=text_model_for_responses_api,
            input=main_input_prompt, 
            stream=True,
            tools=[{
                "type": "image_generation",
                "quality": "auto",
                "size": "1024x1536",
                "background": "transparent",
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
                    final_image_b64 = image_base64_partial
                    yield image_base64_partial

        if final_image_b64:
            await save_image_to_cache(cache_key, final_image_b64)

    except Exception as e:
        print(f"Error during OpenAI Responses API call for image stream: {type(e).__name__} - {e}")
        import traceback
        traceback.print_exc()
        raise 

    print(f"--- Image generation stream from OpenAI finished for {drink_name} ---") 