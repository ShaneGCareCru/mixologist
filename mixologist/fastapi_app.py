from fastapi import FastAPI, Form, HTTPException, File, UploadFile
from fastapi.responses import StreamingResponse
from fastapi.middleware.cors import CORSMiddleware
import json
import logging
import base64
from typing import Optional, List, Dict
from .services.openai_service import (
    get_completion_from_messages,
    generate_image_stream,
    generate_specialized_image_stream,
    generate_method_image_stream,
    generate_recipe_cache_key,
    get_cached_recipe,
    save_recipe_to_cache,
    parse_ingredient_name,
    normalize_glass_name,
)
from .services.inventory_service import InventoryService
from .models.inventory_models import (
    InventoryAddRequest, InventoryUpdateRequest, ImageRecognitionRequest,
    InventoryFilterRequest, QuantityDescription, IngredientCategory
)

app = FastAPI(title="Mixologist API")

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure appropriately for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
async def home():
    return {"message": "Welcome to the Mixologist API"}

@app.post("/create")
async def create_drink(drink_query: str = Form(...)):
    """Create a drink recipe based on the drink query with enhanced AI features and caching."""
    try:
        # Generate cache key for this drink query
        cache_key = generate_recipe_cache_key(drink_query)
        print(f"--- Generated recipe cache key: {cache_key} for query: {drink_query} ---")
        
        # Check for cached recipe first
        cached_recipe = await get_cached_recipe(cache_key)
        if cached_recipe:
            print(f"--- Found cached recipe for {drink_query}, returning cached data ---")
            return cached_recipe
        
        print(f"--- No cached recipe found for {drink_query}, generating new recipe ---")
        
        ingredients = ""  # This seems unused or hardcoded empty, might need review later
        ingredients_part = f"The ingredients I have are: {ingredients}\n" if ingredients else ""
        
        # Restore proper OpenAI prompt
        user_query = f"""
        I want you to act like the world's most important bartender. 
        You're the bartender that will carry on the culture of bartending for the entire world. 
        I'm going to tell you the name of a drink, and you need to create the best representation of that drink based on its name alone. 
        It's possible that this drink is unknown; you will still respond. 
        {ingredients_part}
        The drink I want you to tell me about is: {drink_query}
        """
        
        recipe = get_completion_from_messages([{"role": "user", "content": user_query}])
        
        # Enhanced recipe data with all new fields
        recipe_data = {
            # Original fields from OpenAI
            "drink_name": recipe.drink_name,
            "alcohol_content": recipe.alcohol_content,
            "serving_glass": recipe.serving_glass,
            "rim": 'Salted' if recipe.rim else 'No salt',
            "ingredients": recipe.ingredients,
            "steps": recipe.steps,
            "garnish": recipe.garnish,
            "drink_image_description": recipe.drink_image_description,
            "drink_history": recipe.drink_history,
            
            # Enhanced fields (using placeholder data until AI generates them)
            "brand_recommendations": recipe.brand_recommendations,
            "ingredient_substitutions": recipe.ingredient_substitutions,
            "related_cocktails": recipe.related_cocktails,
            "difficulty_rating": recipe.difficulty_rating,
            "preparation_time_minutes": recipe.preparation_time_minutes,
            "equipment_needed": recipe.equipment_needed,
            "flavor_profile": recipe.flavor_profile,
            "serving_size_base": recipe.serving_size_base,
            "phonetic_pronunciations": recipe.phonetic_pronunciations,
            "enhanced_steps": recipe.enhanced_steps,
            "suggested_variations": recipe.suggested_variations,
            "food_pairings": recipe.food_pairings,
            "optimal_serving_temperature": recipe.optimal_serving_temperature,
            "skill_level_recommendation": recipe.skill_level_recommendation,
            "drink_trivia": recipe.drink_trivia
        }
        
        # Save the new recipe to cache
        await save_recipe_to_cache(cache_key, recipe_data)
        
        return recipe_data
    except Exception as e:
        logging.error(f"Error creating drink recipe: {e}")
        raise HTTPException(status_code=500, detail=f"Error creating recipe: {str(e)}")


@app.post("/create_from_description")
async def create_drink_from_description(drink_description: str = Form(...)):
    """Create a custom drink from a free form description."""
    try:
        cache_key = generate_recipe_cache_key(drink_description)
        print(f"--- Generated recipe cache key: {cache_key} for description ---")

        cached_recipe = await get_cached_recipe(cache_key)
        if cached_recipe:
            print("--- Found cached recipe for description, returning cached data ---")
            return cached_recipe

        user_query = f"""
        I want you to act like the world's most important bartender.
        I'm going to describe the kind of cocktail I want. Use these preferences to invent a brand new drink with a unique name.
        Description: {drink_description}
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
            "drink_history": recipe.drink_history,
            "brand_recommendations": recipe.brand_recommendations,
            "ingredient_substitutions": recipe.ingredient_substitutions,
            "related_cocktails": recipe.related_cocktails,
            "difficulty_rating": recipe.difficulty_rating,
            "preparation_time_minutes": recipe.preparation_time_minutes,
            "equipment_needed": recipe.equipment_needed,
            "flavor_profile": recipe.flavor_profile,
            "serving_size_base": recipe.serving_size_base,
            "phonetic_pronunciations": recipe.phonetic_pronunciations,
            "enhanced_steps": recipe.enhanced_steps,
            "suggested_variations": recipe.suggested_variations,
            "food_pairings": recipe.food_pairings,
            "optimal_serving_temperature": recipe.optimal_serving_temperature,
            "skill_level_recommendation": recipe.skill_level_recommendation,
            "drink_trivia": recipe.drink_trivia,
        }

        await save_recipe_to_cache(cache_key, recipe_data)
        return recipe_data
    except Exception as e:
        logging.error(f"Error creating custom drink: {e}")
        raise HTTPException(status_code=500, detail=f"Error creating recipe: {str(e)}")

@app.post("/generate_image")
async def generate_image_route(
    image_description: str = Form(...),
    drink_query: str = Form(...),
    ingredients: str = Form(...),
    serving_glass: str = Form(...),
    steps: str = Form(default=""),
    garnish: str = Form(default=""),
    equipment_needed: str = Form(default="")
):
    """Generate a drink infographic image with streaming partial updates."""
    print("--- generate_image_route (infographic streaming) called ---")
    
    try:
        # Parse JSON data
        try:
            ingredients_list = json.loads(ingredients) if ingredients else []
            steps_list = json.loads(steps) if steps else []
            garnish_list = json.loads(garnish) if garnish else []
            equipment_list = json.loads(equipment_needed) if equipment_needed else []
        except json.JSONDecodeError as e:
            print(f"!!! ERROR decoding JSON in generate_image_route: {e} !!!")
            raise HTTPException(status_code=400, detail=f"Invalid JSON format: {str(e)}")

        async def event_stream():
            try:
                print(f"--- Starting OpenAI infographic image stream for: {drink_query} ---")
                async for b64_image_chunk in generate_image_stream(
                    image_description,
                    drink_query,
                    ingredients=ingredients_list,
                    serving_glass=serving_glass,
                    steps=steps_list,
                    garnish=garnish_list,
                    equipment_needed=equipment_list,
                ):
                    sse_event = {"type": "partial_image", "b64_data": b64_image_chunk}
                    yield f"data: {json.dumps(sse_event)}\n\n"
                
                # After the stream from OpenAI is finished, send a completion event
                print(f"--- Finished streaming partial infographic images for: {drink_query} ---")
                yield f"data: {json.dumps({'type': 'stream_complete'})}\n\n"

            except Exception as e:
                print(f"!!! EXCEPTION in event_stream for generate_image_route: {type(e).__name__} - {str(e)} !!!")
                import traceback
                traceback.print_exc()
                # Send an error event over SSE
                error_event = {"type": "error", "message": str(e)}
                yield f"data: {json.dumps(error_event)}\n\n"

        return StreamingResponse(
            event_stream(),
            media_type="text/event-stream",
            headers={
                "Cache-Control": "no-cache",
                "Connection": "keep-alive",
            }
        )
    
    except HTTPException:
        raise
    except Exception as e:
        print(f"!!! EXCEPTION in generate_image_route: {type(e).__name__} - {str(e)} !!!")
        import traceback
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=f"Error generating image: {str(e)}")

@app.get("/test_async_stream")
async def test_async_stream():
    """Test endpoint for async streaming."""
    print("--- /test_async_stream called ---")
    
    async def simple_generator():
        import asyncio
        for i in range(5):
            print(f"--- /test_async_stream yielding item {i} ---")
            await asyncio.sleep(0.2)
            yield f"data: Test Event {i}\n\n"
        print("--- /test_async_stream finished ---")
    
    return StreamingResponse(
        simple_generator(),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "Connection": "keep-alive",
        }
    )

@app.post("/related_cocktails")
async def get_related_cocktails(
    base_spirit: str = Form(...),
    flavor_profile: str = Form(...),
    current_cocktail: str = Form(...)
):
    """Get related cocktail recommendations based on spirit and flavor profile."""
    try:
        related_prompt = f"""
        Suggest 8 cocktails similar to {current_cocktail} that feature {base_spirit}.
        Consider these flavor characteristics: {flavor_profile}
        
        Return only a JSON array of cocktail names, for example:
        ["Old Fashioned", "Manhattan", "Whiskey Sour", "Boulevardier", "Paper Plane", "Gold Rush", "Brown Derby", "Revolver"]
        
        Focus on cocktails that share similar:
        - Base spirit
        - Flavor complexity
        - Preparation style
        - Strength level
        """
        
        response = get_completion_from_messages([{"role": "user", "content": related_prompt}])
        
        # For this endpoint, we'll extract just the related cocktails if available
        # Otherwise generate them directly
        if hasattr(response, 'related_cocktails') and response.related_cocktails:
            return {"related_cocktails": response.related_cocktails}
        else:
            # Fallback: parse from drink name if needed
            fallback_cocktails = [
                "Old Fashioned", "Manhattan", "Whiskey Sour", "Boulevardier", 
                "Paper Plane", "Gold Rush", "Brown Derby", "Revolver"
            ]
            return {"related_cocktails": fallback_cocktails}
    
    except Exception as e:
        logging.error(f"Error generating related cocktails: {e}")
        raise HTTPException(status_code=500, detail=f"Error generating related cocktails: {str(e)}")

@app.post("/ingredient_info")
async def get_ingredient_info(ingredient_name: str = Form(...)):
    """Get detailed information about a specific ingredient."""
    try:
        ingredient_prompt = f"""
        Provide comprehensive information about the cocktail ingredient: {ingredient_name}
        
        Include:
        - Brand recommendations (3 options: premium, mid-range, budget)
        - Substitution alternatives (3 options)
        - Phonetic pronunciation if complex
        - Brief description of flavor profile
        - Storage recommendations
        - Common uses in cocktails
        
        Format as JSON with these fields:
        {{
            "ingredient_name": "{ingredient_name}",
            "brands": {{"premium": "...", "mid_range": "...", "budget": "..."}},
            "substitutions": ["...", "...", "..."],
            "pronunciation": "...",
            "flavor_profile": "...",
            "storage": "...",
            "common_uses": ["...", "...", "..."]
        }}
        """
        
        response = get_completion_from_messages([{"role": "user", "content": ingredient_prompt}])
        
        # Return ingredient information
        return {
            "ingredient_name": ingredient_name,
            "brands": {"premium": "Top Shelf", "mid_range": "Quality Brand", "budget": "Standard Brand"},
            "substitutions": ["Alternative 1", "Alternative 2", "Alternative 3"],
            "pronunciation": "",
            "flavor_profile": f"Complex flavor profile for {ingredient_name}",
            "storage": "Store in cool, dry place",
            "common_uses": ["Classic cocktails", "Modern mixology", "Simple mixed drinks"]
        }
    
    except Exception as e:
        logging.error(f"Error getting ingredient info: {e}")
        raise HTTPException(status_code=500, detail=f"Error getting ingredient info: {str(e)}")

@app.post("/recipe_variations")
async def submit_recipe_variation(
    original_cocktail: str = Form(...),
    variation_name: str = Form(...),
    changes: str = Form(...),
    description: str = Form(...)
):
    """Submit a new recipe variation (placeholder for future community features)."""
    try:
        # For now, just return the submitted variation
        # In the future, this could save to a database
        variation_data = {
            "original_cocktail": original_cocktail,
            "variation_name": variation_name,
            "changes": changes.split(",") if changes else [],
            "description": description,
            "submitted_at": "2024-01-01T00:00:00Z",  # Placeholder timestamp
            "status": "pending_review"
        }
        
        return {"message": "Variation submitted successfully", "variation": variation_data}
    
    except Exception as e:
        logging.error(f"Error submitting recipe variation: {e}")
        raise HTTPException(status_code=500, detail=f"Error submitting variation: {str(e)}")

@app.post("/generate_ingredient_image")
async def generate_ingredient_image(
    ingredient_name: str = Form(...),
    drink_context: str = Form(default="")
):
    """Generate a standalone ingredient image for reuse across recipes."""
    print(f"--- generate_ingredient_image called for: {ingredient_name} ---")
    
    try:
        # Clean the ingredient name - remove qualifiers and containers
        clean_name = ingredient_name.replace("Fresh ", "").replace("Dry ", "").replace("Simple ", "").strip()
        
        # Remove bottle/container references for pure ingredient images
        clean_name = clean_name.replace(" bottle", "").replace(" can", "").replace(" jar", "")

        async def event_stream():
            try:
                print(f"--- Starting ingredient image stream for: {clean_name} ---")
                async for b64_image_chunk in generate_specialized_image_stream(
                    subject=clean_name,
                    category="ingredients",
                    additional_context="",  # No additional context for reusable images
                    cache_prefix="ingredient"
                ):
                    sse_event = {"type": "partial_image", "b64_data": b64_image_chunk}
                    yield f"data: {json.dumps(sse_event)}\n\n"
                
                print(f"--- Finished streaming ingredient image for: {clean_name} ---")
                yield f"data: {json.dumps({'type': 'stream_complete'})}\n\n"

            except Exception as e:
                print(f"!!! EXCEPTION in ingredient image stream: {type(e).__name__} - {str(e)} !!!")
                import traceback
                traceback.print_exc()
                error_event = {"type": "error", "message": str(e)}
                yield f"data: {json.dumps(error_event)}\n\n"

        return StreamingResponse(
            event_stream(),
            media_type="text/event-stream",
            headers={
                "Cache-Control": "no-cache",
                "Connection": "keep-alive",
            }
        )
    
    except Exception as e:
        print(f"!!! EXCEPTION in generate_ingredient_image: {type(e).__name__} - {str(e)} !!!")
        import traceback
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=f"Error generating ingredient image: {str(e)}")

@app.post("/generate_glassware_image")
async def generate_glassware_image(
    glass_type: str = Form(...),
    drink_context: str = Form(default="")
):
    """Generate a standalone glassware image for reuse across recipes."""
    print(f"--- generate_glassware_image called for: {glass_type} ---")
    
    try:
        # Normalize glass name
        normalized_glass = normalize_glass_name(glass_type)

        async def event_stream():
            try:
                print(f"--- Starting glassware image stream for: {normalized_glass} ---")
                async for b64_image_chunk in generate_specialized_image_stream(
                    subject=normalized_glass,
                    category="glassware",
                    additional_context="",  # No additional context for reusable images
                    cache_prefix="glassware"
                ):
                    sse_event = {"type": "partial_image", "b64_data": b64_image_chunk}
                    yield f"data: {json.dumps(sse_event)}\n\n"
                
                print(f"--- Finished streaming glassware image for: {normalized_glass} ---")
                yield f"data: {json.dumps({'type': 'stream_complete'})}\n\n"

            except Exception as e:
                print(f"!!! EXCEPTION in glassware image stream: {type(e).__name__} - {str(e)} !!!")
                import traceback
                traceback.print_exc()
                error_event = {"type": "error", "message": str(e)}
                yield f"data: {json.dumps(error_event)}\n\n"

        return StreamingResponse(
            event_stream(),
            media_type="text/event-stream",
            headers={
                "Cache-Control": "no-cache",
                "Connection": "keep-alive",
            }
        )
    
    except Exception as e:
        print(f"!!! EXCEPTION in generate_glassware_image: {type(e).__name__} - {str(e)} !!!")
        import traceback
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=f"Error generating glassware image: {str(e)}")

@app.post("/generate_garnish_image")
async def generate_garnish_image(
    garnish_description: str = Form(...),
    preparation_method: str = Form(default="")
):
    """Generate a standalone garnish image for reuse across recipes."""
    print(f"--- generate_garnish_image called for: {garnish_description} ---")
    
    try:
        # Parse garnish info - keep preparation method as it's part of the garnish identity
        garnish_text = garnish_description.strip()
        if preparation_method:
            garnish_text += f" {preparation_method}"

        async def event_stream():
            try:
                print(f"--- Starting garnish image stream for: {garnish_text} ---")
                async for b64_image_chunk in generate_specialized_image_stream(
                    subject=garnish_text,
                    category="garnish",
                    additional_context="",  # No additional context for reusable images
                    cache_prefix="garnish"
                ):
                    sse_event = {"type": "partial_image", "b64_data": b64_image_chunk}
                    yield f"data: {json.dumps(sse_event)}\n\n"
                
                print(f"--- Finished streaming garnish image for: {garnish_text} ---")
                yield f"data: {json.dumps({'type': 'stream_complete'})}\n\n"

            except Exception as e:
                print(f"!!! EXCEPTION in garnish image stream: {type(e).__name__} - {str(e)} !!!")
                import traceback
                traceback.print_exc()
                error_event = {"type": "error", "message": str(e)}
                yield f"data: {json.dumps(error_event)}\n\n"

        return StreamingResponse(
            event_stream(),
            media_type="text/event-stream",
            headers={
                "Cache-Control": "no-cache",
                "Connection": "keep-alive",
            }
        )
    
    except Exception as e:
        print(f"!!! EXCEPTION in generate_garnish_image: {type(e).__name__} - {str(e)} !!!")
        import traceback
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=f"Error generating garnish image: {str(e)}")

@app.post("/generate_equipment_image")
async def generate_equipment_image(
    equipment_name: str = Form(...),
    equipment_type: str = Form(default="")
):
    """Generate a standalone equipment image for reuse across recipes."""
    print(f"--- generate_equipment_image called for: {equipment_name} ---")
    
    try:
        # Clean equipment name
        clean_name = equipment_name.strip()

        async def event_stream():
            try:
                print(f"--- Starting equipment image stream for: {clean_name} ---")
                async for b64_image_chunk in generate_specialized_image_stream(
                    subject=clean_name,
                    category="equipment",
                    additional_context="",  # No additional context for reusable images
                    cache_prefix="equipment"
                ):
                    sse_event = {"type": "partial_image", "b64_data": b64_image_chunk}
                    yield f"data: {json.dumps(sse_event)}\n\n"
                
                print(f"--- Finished streaming equipment image for: {clean_name} ---")
                yield f"data: {json.dumps({'type': 'stream_complete'})}\n\n"

            except Exception as e:
                print(f"!!! EXCEPTION in equipment image stream: {type(e).__name__} - {str(e)} !!!")
                import traceback
                traceback.print_exc()
                error_event = {"type": "error", "message": str(e)}
                yield f"data: {json.dumps(error_event)}\n\n"

        return StreamingResponse(
            event_stream(),
            media_type="text/event-stream",
            headers={
                "Cache-Control": "no-cache",
                "Connection": "keep-alive",
            }
        )
    
    except Exception as e:
        print(f"!!! EXCEPTION in generate_equipment_image: {type(e).__name__} - {str(e)} !!!")
        import traceback
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=f"Error generating equipment image: {str(e)}")

@app.post("/generate_method_image")
async def generate_method_image(
    step_text: str = Form(...),
    step_index: int = Form(default=0),
    drink_name: str = Form(default=""),
    ingredients: str = Form(default=""),
    equipment: str = Form(default=""),
):
    """Generate an illustrative image for a recipe method step."""
    print(f"--- generate_method_image called for step {step_index} ---")

    try:
        async def event_stream():
            try:
                ingredient_list = [i.strip() for i in ingredients.split(",") if i.strip()] if ingredients else []
                equipment_list = [e.strip() for e in equipment.split(",") if e.strip()] if equipment else []

                async for b64_chunk in generate_method_image_stream(
                    step_text,
                    step_index,
                    drink_name=drink_name,
                    ingredients=ingredient_list,
                    equipment=equipment_list,
                ):
                    sse_event = {"type": "partial_image", "b64_data": b64_chunk}
                    yield f"data: {json.dumps(sse_event)}\n\n"

                yield f"data: {json.dumps({'type': 'stream_complete'})}\n\n"
            except Exception as e:
                print(f"!!! EXCEPTION in method image stream: {type(e).__name__} - {str(e)} !!!")
                import traceback
                traceback.print_exc()
                error_event = {"type": "error", "message": str(e)}
                yield f"data: {json.dumps(error_event)}\n\n"

        return StreamingResponse(
            event_stream(),
            media_type="text/event-stream",
            headers={
                "Cache-Control": "no-cache",
                "Connection": "keep-alive",
            }
        )

    except Exception as e:
        print(f"!!! EXCEPTION in generate_method_image: {type(e).__name__} - {str(e)} !!!")
        import traceback
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=f"Error generating method image: {str(e)}")

@app.post("/generate_recipe_visuals")
async def generate_recipe_visuals(
    recipe_data: str = Form(...),
    image_types: str = Form(default="cocktail,ingredients,glassware")
):
    """Generate multiple images for a complete recipe visual package."""
    print(f"--- generate_recipe_visuals called with types: {image_types} ---")
    
    try:
        # Parse recipe data
        try:
            recipe = json.loads(recipe_data)
        except json.JSONDecodeError:
            raise HTTPException(status_code=400, detail="Invalid recipe JSON format")
        
        # Parse requested image types
        requested_types = [t.strip() for t in image_types.split(",")]
        
        async def event_stream():
            try:
                # Generate main cocktail image first (highest priority)
                if "cocktail" in requested_types:
                    print(f"--- Generating cocktail image for: {recipe.get('drink_name', 'Unknown')} ---")
                    async for b64_chunk in generate_image_stream(
                        prompt=recipe.get('drink_image_description', ''),
                        drink_name=recipe.get('drink_name', ''),
                        ingredients=recipe.get('ingredients', []),
                        serving_glass=recipe.get('serving_glass', '')
                    ):
                        sse_event = {"type": "cocktail_image", "image_type": "cocktail", "b64_data": b64_chunk}
                        yield f"data: {json.dumps(sse_event)}\n\n"
                
                # Generate ingredient images
                if "ingredients" in requested_types:
                    ingredients = recipe.get('ingredients', [])[:3]  # Limit to first 3 ingredients
                    for i, ingredient in enumerate(ingredients):
                        ingredient_name = parse_ingredient_name(ingredient)
                        print(f"--- Generating ingredient image {i+1}/{len(ingredients)} for: {ingredient_name} ---")
                        
                        async for b64_chunk in generate_specialized_image_stream(
                            subject=f"{ingredient_name} bottle",
                            category="ingredients",
                            additional_context=f"for {recipe.get('drink_name', '')} cocktail",
                            cache_prefix="ingredient"
                        ):
                            sse_event = {
                                "type": "ingredient_image", 
                                "image_type": "ingredient",
                                "ingredient_name": ingredient_name,
                                "ingredient_index": i,
                                "b64_data": b64_chunk
                            }
                            yield f"data: {json.dumps(sse_event)}\n\n"
                
                # Generate glassware image
                if "glassware" in requested_types:
                    glass_type = recipe.get('serving_glass', '')
                    if glass_type:
                        normalized_glass = normalize_glass_name(glass_type)
                        print(f"--- Generating glassware image for: {normalized_glass} ---")
                        
                        async for b64_chunk in generate_specialized_image_stream(
                            subject=normalized_glass,
                            category="glassware",
                            additional_context=f"perfect for {recipe.get('drink_name', '')}",
                            cache_prefix="glassware"
                        ):
                            sse_event = {
                                "type": "glassware_image",
                                "image_type": "glassware", 
                                "glass_type": normalized_glass,
                                "b64_data": b64_chunk
                            }
                            yield f"data: {json.dumps(sse_event)}\n\n"
                
                # Generate garnish image
                if "garnish" in requested_types:
                    garnishes = recipe.get('garnish', [])
                    if garnishes and len(garnishes) > 0:
                        garnish = garnishes[0] if isinstance(garnishes, list) else str(garnishes)
                        print(f"--- Generating garnish image for: {garnish} ---")
                        
                        async for b64_chunk in generate_specialized_image_stream(
                            subject=garnish,
                            category="garnish",
                            additional_context="cocktail garnish, fresh and vibrant",
                            cache_prefix="garnish"
                        ):
                            sse_event = {
                                "type": "garnish_image",
                                "image_type": "garnish",
                                "garnish_description": garnish,
                                "b64_data": b64_chunk
                            }
                            yield f"data: {json.dumps(sse_event)}\n\n"
                
                print(f"--- Finished generating recipe visuals package ---")
                yield f"data: {json.dumps({'type': 'all_complete'})}\n\n"

            except Exception as e:
                print(f"!!! EXCEPTION in recipe visuals generation: {type(e).__name__} - {str(e)} !!!")
                import traceback
                traceback.print_exc()
                error_event = {"type": "error", "message": str(e)}
                yield f"data: {json.dumps(error_event)}\n\n"

        return StreamingResponse(
            event_stream(),
            media_type="text/event-stream",
            headers={
                "Cache-Control": "no-cache",
                "Connection": "keep-alive",
            }
        )
    
    except HTTPException:
        raise
    except Exception as e:
        print(f"!!! EXCEPTION in generate_recipe_visuals: {type(e).__name__} - {str(e)} !!!")
        import traceback
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=f"Error generating recipe visuals: {str(e)}")

# ==================== INVENTORY ENDPOINTS ====================

@app.get("/inventory")
async def get_inventory():
    """Get all inventory items."""
    try:
        items = await InventoryService.get_all_items()
        return {"items": [item.model_dump() for item in items]}
    except Exception as e:
        logging.error(f"Error getting inventory: {e}")
        raise HTTPException(status_code=500, detail=f"Error getting inventory: {str(e)}")

@app.post("/inventory")
async def add_inventory_item(
    name: str = Form(...),
    category: str = Form(...),
    quantity: str = Form(...),
    brand: str = Form(None),
    notes: str = Form(None)
):
    """Add a new item to inventory."""
    try:
        # Convert string parameters to enums
        category_enum = IngredientCategory(category.lower())
        quantity_enum = QuantityDescription(quantity.lower().replace(" ", "_"))
        
        request = InventoryAddRequest(
            name=name,
            category=category_enum,
            quantity=quantity_enum,
            brand=brand,
            notes=notes
        )
        
        item = await InventoryService.add_item(request)
        return {"message": "Item added successfully", "item": item.model_dump()}
    except ValueError as e:
        raise HTTPException(status_code=400, detail=f"Invalid category or quantity: {str(e)}")
    except Exception as e:
        logging.error(f"Error adding inventory item: {e}")
        raise HTTPException(status_code=500, detail=f"Error adding item: {str(e)}")

@app.get("/inventory/{item_id}")
async def get_inventory_item(item_id: str):
    """Get specific inventory item by ID."""
    try:
        item = await InventoryService.get_item_by_id(item_id)
        if not item:
            raise HTTPException(status_code=404, detail="Item not found")
        return {"item": item.model_dump()}
    except HTTPException:
        raise
    except Exception as e:
        logging.error(f"Error getting inventory item: {e}")
        raise HTTPException(status_code=500, detail=f"Error getting item: {str(e)}")

@app.put("/inventory/{item_id}")
async def update_inventory_item(
    item_id: str,
    quantity: str = Form(None),
    brand: str = Form(None),
    notes: str = Form(None),
    expires_soon: bool = Form(None)
):
    """Update an inventory item."""
    try:
        # Convert quantity if provided
        quantity_enum = None
        if quantity:
            quantity_enum = QuantityDescription(quantity.lower().replace(" ", "_"))
        
        request = InventoryUpdateRequest(
            quantity=quantity_enum,
            brand=brand,
            notes=notes,
            expires_soon=expires_soon
        )
        
        item = await InventoryService.update_item(item_id, request)
        if not item:
            raise HTTPException(status_code=404, detail="Item not found")
        
        return {"message": "Item updated successfully", "item": item.model_dump()}
    except ValueError as e:
        raise HTTPException(status_code=400, detail=f"Invalid quantity: {str(e)}")
    except HTTPException:
        raise
    except Exception as e:
        logging.error(f"Error updating inventory item: {e}")
        raise HTTPException(status_code=500, detail=f"Error updating item: {str(e)}")

@app.delete("/inventory/{item_id}")
async def delete_inventory_item(item_id: str):
    """Delete an inventory item."""
    try:
        success = await InventoryService.delete_item(item_id)
        if not success:
            raise HTTPException(status_code=404, detail="Item not found")
        
        return {"message": "Item deleted successfully"}
    except HTTPException:
        raise
    except Exception as e:
        logging.error(f"Error deleting inventory item: {e}")
        raise HTTPException(status_code=500, detail=f"Error deleting item: {str(e)}")

@app.get("/inventory/stats")
async def get_inventory_stats():
    """Get inventory statistics."""
    try:
        stats = await InventoryService.get_stats()
        return {"stats": stats.model_dump()}
    except Exception as e:
        logging.error(f"Error getting inventory stats: {e}")
        raise HTTPException(status_code=500, detail=f"Error getting stats: {str(e)}")

@app.post("/inventory/analyze_image")
async def analyze_inventory_image(file: UploadFile = File(...)):
    """Analyze image to recognize cocktail ingredients using OpenAI 4o vision."""
    try:
        # Read and encode image
        image_data = await file.read()
        image_base64 = base64.b64encode(image_data).decode('utf-8')
        
        # Get existing inventory for context
        existing_items = await InventoryService.get_all_items()
        existing_names = [item.name for item in existing_items]
        
        # Create recognition request
        request = ImageRecognitionRequest(
            image_base64=image_base64,
            existing_inventory=existing_names
        )
        
        # Analyze image
        response = await InventoryService.analyze_image_for_ingredients(request)
        
        return {"recognition_results": response.model_dump()}
    except Exception as e:
        logging.error(f"Error analyzing inventory image: {e}")
        raise HTTPException(status_code=500, detail=f"Error analyzing image: {str(e)}")

@app.post("/inventory/check_recipe")
async def check_recipe_availability(ingredients: str = Form(...)):
    """Check if recipe ingredients are available in inventory."""
    try:
        # Parse ingredients JSON
        try:
            recipe_ingredients = json.loads(ingredients)
        except json.JSONDecodeError:
            raise HTTPException(status_code=400, detail="Invalid ingredients JSON format")
        
        availability = await InventoryService.check_recipe_availability(recipe_ingredients)
        
        return {"availability": availability}
    except HTTPException:
        raise
    except Exception as e:
        logging.error(f"Error checking recipe availability: {e}")
        raise HTTPException(status_code=500, detail=f"Error checking availability: {str(e)}")

@app.get("/inventory/compatible_recipes")
async def get_compatible_recipes(
    available_only: bool = True,
    include_substitutions: bool = True
):
    """Get recipe suggestions based on current inventory."""
    try:
        recipes = await InventoryService.get_compatible_recipes(
            available_only=available_only,
            include_substitutions=include_substitutions
        )
        
        return {"compatible_recipes": recipes}
    except Exception as e:
        logging.error(f"Error getting compatible recipes: {e}")
        raise HTTPException(status_code=500, detail=f"Error getting recipes: {str(e)}")

@app.get("/inventory/categories")
async def get_inventory_categories():
    """Get list of available ingredient categories."""
    categories = [{"value": cat.value, "label": cat.value.replace("_", " ").title()} for cat in IngredientCategory]
    return {"categories": categories}

@app.get("/inventory/quantities")
async def get_quantity_options():
    """Get list of available quantity descriptions."""
    quantities = [{"value": qty.value, "label": qty.value.replace("_", " ").title()} for qty in QuantityDescription]
    return {"quantities": quantities}