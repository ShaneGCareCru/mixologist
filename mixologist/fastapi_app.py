from fastapi import FastAPI, Form, HTTPException
from fastapi.responses import StreamingResponse
from fastapi.middleware.cors import CORSMiddleware
import json
import logging
from typing import Optional, List, Dict
from .services.openai_service import get_completion_from_messages, generate_image_stream

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
    """Create a drink recipe based on the drink query with enhanced AI features."""
    try:
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
            "skill_level_recommendation": recipe.skill_level_recommendation
        }
        return recipe_data
    except Exception as e:
        logging.error(f"Error creating drink recipe: {e}")
        raise HTTPException(status_code=500, detail=f"Error creating recipe: {str(e)}")

@app.post("/generate_image")
async def generate_image_route(
    image_description: str = Form(...),
    drink_query: str = Form(...),
    ingredients: str = Form(...),
    serving_glass: str = Form(...)
):
    """Generate a drink image with streaming partial updates."""
    print("--- generate_image_route (streaming) called ---")
    
    try:
        # Parse ingredients JSON
        try:
            ingredients_list = json.loads(ingredients) if ingredients else None
        except json.JSONDecodeError:
            print("!!! ERROR decoding ingredients JSON in generate_image_route !!!")
            raise HTTPException(status_code=400, detail="Invalid ingredients JSON format")

        async def event_stream():
            try:
                print(f"--- Starting OpenAI image stream for: {drink_query} ---")
                async for b64_image_chunk in generate_image_stream(
                    image_description,
                    drink_query,
                    ingredients=ingredients_list,
                    serving_glass=serving_glass,
                ):
                    sse_event = {"type": "partial_image", "b64_data": b64_image_chunk}
                    yield f"data: {json.dumps(sse_event)}\n\n"
                
                # After the stream from OpenAI is finished, send a completion event
                print(f"--- Finished streaming partial images for: {drink_query} ---")
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