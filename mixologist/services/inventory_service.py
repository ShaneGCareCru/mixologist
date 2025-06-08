import json
import uuid
import aiofiles
from pathlib import Path
from typing import Optional, List, Dict
from datetime import datetime
import openai
import os
import logging
from dotenv import load_dotenv

from ..models.inventory_models import (
    Inventory, InventoryItem, InventoryAddRequest, InventoryUpdateRequest,
    ImageRecognitionRequest, ImageRecognitionResponse, RecognizedIngredient,
    InventoryFilterRequest, InventoryStats, QuantityDescription, IngredientCategory
)

load_dotenv()

# Initialize inventory storage directory
BASE_DIR = Path(__file__).parent.parent
INVENTORY_DIR = BASE_DIR / "static" / "inventory"
INVENTORY_DIR.mkdir(parents=True, exist_ok=True)

INVENTORY_FILE = INVENTORY_DIR / "user_inventory.json"

print(f"Inventory directory: {INVENTORY_DIR}")
print(f"Inventory file: {INVENTORY_FILE}")

# Initialize OpenAI client for vision analysis
try:
    api_key = os.getenv("OPENAI_API_KEY")
    if not api_key:
        print("Warning: OPENAI_API_KEY not set. Vision functionality will be limited.")
        client = None
        async_client = None
    else:
        client = openai.OpenAI(api_key=api_key)
        async_client = openai.AsyncOpenAI(api_key=api_key)
except Exception as e:
    print(f"Warning: Could not initialize OpenAI client: {e}")
    client = None
    async_client = None


class InventoryService:
    """Service for managing user inventory with flat file storage."""
    
    @staticmethod
    async def load_inventory() -> Inventory:
        """Load inventory from flat file."""
        if INVENTORY_FILE.exists():
            try:
                async with aiofiles.open(INVENTORY_FILE, 'r') as f:
                    data = await f.read()
                    inventory_dict = json.loads(data)
                    return Inventory(**inventory_dict)
            except Exception as e:
                logging.error(f"Error loading inventory: {e}")
                # Return empty inventory if file is corrupted
                return Inventory()
        else:
            # Create new inventory file
            new_inventory = Inventory()
            await InventoryService.save_inventory(new_inventory)
            return new_inventory
    
    @staticmethod
    async def save_inventory(inventory: Inventory) -> None:
        """Save inventory to flat file."""
        try:
            inventory.last_updated = datetime.now()
            inventory_dict = inventory.model_dump()
            
            # Convert datetime objects to ISO strings
            inventory_dict['created_date'] = inventory.created_date.isoformat()
            inventory_dict['last_updated'] = inventory.last_updated.isoformat()
            
            for item in inventory_dict['items']:
                item['added_date'] = datetime.fromisoformat(item['added_date']).isoformat() if isinstance(item['added_date'], str) else item['added_date'].isoformat()
                item['last_updated'] = datetime.fromisoformat(item['last_updated']).isoformat() if isinstance(item['last_updated'], str) else item['last_updated'].isoformat()
            
            async with aiofiles.open(INVENTORY_FILE, 'w') as f:
                await f.write(json.dumps(inventory_dict, indent=2))
            
            logging.info(f"Inventory saved with {len(inventory.items)} items")
        except Exception as e:
            logging.error(f"Error saving inventory: {e}")
            raise
    
    @staticmethod
    async def add_item(request: InventoryAddRequest) -> InventoryItem:
        """Add a new item to inventory."""
        inventory = await InventoryService.load_inventory()
        
        # Create new inventory item
        new_item = InventoryItem(
            id=str(uuid.uuid4()),
            name=request.name,
            category=request.category,
            quantity=request.quantity,
            brand=request.brand,
            notes=request.notes
        )
        
        inventory.add_item(new_item)
        await InventoryService.save_inventory(inventory)
        
        return new_item
    
    @staticmethod
    async def get_all_items() -> List[InventoryItem]:
        """Get all inventory items."""
        inventory = await InventoryService.load_inventory()
        return inventory.items
    
    @staticmethod
    async def get_item_by_id(item_id: str) -> Optional[InventoryItem]:
        """Get specific inventory item by ID."""
        inventory = await InventoryService.load_inventory()
        return inventory.get_item_by_id(item_id)
    
    @staticmethod
    async def update_item(item_id: str, request: InventoryUpdateRequest) -> Optional[InventoryItem]:
        """Update an inventory item."""
        inventory = await InventoryService.load_inventory()
        item = inventory.get_item_by_id(item_id)
        
        if not item:
            return None
        
        # Update fields if provided
        if request.quantity is not None:
            item.update_quantity(request.quantity)
        if request.brand is not None:
            item.brand = request.brand
        if request.notes is not None:
            item.notes = request.notes
        if request.expires_soon is not None:
            item.expires_soon = request.expires_soon
            
        item.last_updated = datetime.now()
        
        await InventoryService.save_inventory(inventory)
        return item
    
    @staticmethod
    async def delete_item(item_id: str) -> bool:
        """Delete an inventory item."""
        inventory = await InventoryService.load_inventory()
        success = inventory.remove_item(item_id)
        
        if success:
            await InventoryService.save_inventory(inventory)
        
        return success
    
    @staticmethod
    async def get_stats() -> InventoryStats:
        """Get inventory statistics."""
        inventory = await InventoryService.load_inventory()
        return inventory.get_stats()
    
    @staticmethod
    async def analyze_image_for_ingredients(request: ImageRecognitionRequest) -> ImageRecognitionResponse:
        """Use OpenAI 4o to analyze image and recognize ingredients."""
        if async_client is None:
            raise Exception("OpenAI client not initialized. Please set OPENAI_API_KEY environment variable.")
        
        start_time = datetime.now()
        
        # Build prompt for ingredient recognition
        existing_items_text = ", ".join(request.existing_inventory) if request.existing_inventory else "none"
        
        prompt = f"""
        Analyze this image and identify any cocktail ingredients, liquor bottles, or bar supplies visible.
        
        For each item you can clearly identify:
        1. Name the ingredient/item
        2. Categorize it (spirits, liqueurs, bitters, syrups, juices, fresh_ingredients, garnishes, mixers, equipment, other)
        3. Estimate confidence (0.0-1.0)
        4. If you can see a brand name, include it
        5. If you can estimate quantity/fullness, provide it using terms like: empty, almost empty, quarter bottle, half bottle, three quarter bottle, full bottle, multiple bottles, small amount, medium amount, large amount, very large amount
        6. Describe where in the image this item appears
        
        Current inventory already includes: {existing_items_text}
        
        Focus on items that would be used for cocktail making. Be conservative - only identify items you're confident about.
        
        Return your response as a JSON object with this structure:
        {{
            "recognized_ingredients": [
                {{
                    "name": "ingredient name",
                    "category": "category",
                    "confidence": 0.85,
                    "brand": "brand name or null",
                    "quantity_estimate": "quantity description or null",
                    "location_description": "where in image"
                }}
            ],
            "suggestions": ["any general observations or suggestions"]
        }}
        """
        
        try:
            response = await async_client.chat.completions.create(
                model="gpt-4o",  # Use GPT-4o for vision capabilities
                messages=[
                    {
                        "role": "user",
                        "content": [
                            {
                                "type": "text",
                                "text": prompt
                            },
                            {
                                "type": "image_url",
                                "image_url": {
                                    "url": f"data:image/jpeg;base64,{request.image_base64}"
                                }
                            }
                        ]
                    }
                ],
                max_tokens=1500,
                temperature=0.3
            )
            
            content = response.choices[0].message.content
            
            # Parse the JSON response
            try:
                result_data = json.loads(content)
                
                # Convert to our models
                recognized_ingredients = []
                for item in result_data.get("recognized_ingredients", []):
                    # Map category string to enum
                    category_str = item.get("category", "other").lower()
                    category = IngredientCategory.OTHER
                    
                    for cat in IngredientCategory:
                        if cat.value == category_str:
                            category = cat
                            break
                    
                    # Map quantity if provided
                    quantity_estimate = None
                    if item.get("quantity_estimate"):
                        quantity_str = item["quantity_estimate"].lower().replace(" ", "_")
                        for qty in QuantityDescription:
                            if qty.value == quantity_str:
                                quantity_estimate = qty
                                break
                    
                    recognized_ingredient = RecognizedIngredient(
                        name=item.get("name", ""),
                        category=category,
                        confidence=float(item.get("confidence", 0.0)),
                        brand=item.get("brand"),
                        quantity_estimate=quantity_estimate,
                        location_description=item.get("location_description")
                    )
                    recognized_ingredients.append(recognized_ingredient)
                
                processing_time = (datetime.now() - start_time).total_seconds()
                
                return ImageRecognitionResponse(
                    recognized_ingredients=recognized_ingredients,
                    suggestions=result_data.get("suggestions", []),
                    processing_time=processing_time
                )
                
            except json.JSONDecodeError as e:
                logging.error(f"Failed to parse OpenAI vision response: {e}")
                logging.error(f"Raw response: {content}")
                
                # Return empty response with error suggestion
                return ImageRecognitionResponse(
                    recognized_ingredients=[],
                    suggestions=[f"Error parsing AI response: {str(e)}"],
                    processing_time=(datetime.now() - start_time).total_seconds()
                )
        
        except Exception as e:
            logging.error(f"Error during OpenAI vision analysis: {e}")
            return ImageRecognitionResponse(
                recognized_ingredients=[],
                suggestions=[f"Error analyzing image: {str(e)}"],
                processing_time=(datetime.now() - start_time).total_seconds()
            )
    
    @staticmethod
    async def check_recipe_availability(recipe_ingredients: List[Dict[str, str]]) -> Dict[str, any]:
        """Check if recipe ingredients are available in inventory."""
        inventory = await InventoryService.load_inventory()
        
        available_ingredients = []
        missing_ingredients = []
        substitution_suggestions = []
        
        # Create lookup dictionary for faster searching
        inventory_lookup = {item.name.lower(): item for item in inventory.items}
        
        for recipe_ingredient in recipe_ingredients:
            ingredient_name = recipe_ingredient.get("name", "").lower()
            ingredient_found = False
            
            # Direct match
            if ingredient_name in inventory_lookup:
                inventory_item = inventory_lookup[ingredient_name]
                # Check if quantity is sufficient (not empty or almost empty)
                if inventory_item.quantity not in [QuantityDescription.EMPTY, QuantityDescription.ALMOST_EMPTY]:
                    available_ingredients.append({
                        "recipe_ingredient": recipe_ingredient,
                        "inventory_item": inventory_item.model_dump(),
                        "match_type": "direct"
                    })
                    ingredient_found = True
            
            # Partial match (for spirits with specific types)
            if not ingredient_found:
                for inventory_name, inventory_item in inventory_lookup.items():
                    if (ingredient_name in inventory_name or inventory_name in ingredient_name):
                        if inventory_item.quantity not in [QuantityDescription.EMPTY, QuantityDescription.ALMOST_EMPTY]:
                            available_ingredients.append({
                                "recipe_ingredient": recipe_ingredient,
                                "inventory_item": inventory_item.model_dump(),
                                "match_type": "partial"
                            })
                            ingredient_found = True
                            break
            
            if not ingredient_found:
                missing_ingredients.append(recipe_ingredient)
                # Add substitution suggestions for common ingredients
                substitution_suggestions.extend(InventoryService._get_substitution_suggestions(ingredient_name))
        
        return {
            "available_ingredients": available_ingredients,
            "missing_ingredients": missing_ingredients,
            "substitution_suggestions": substitution_suggestions,
            "availability_score": len(available_ingredients) / len(recipe_ingredients) if recipe_ingredients else 1.0,
            "can_make_drink": len(missing_ingredients) == 0
        }
    
    @staticmethod
    def _get_substitution_suggestions(ingredient_name: str) -> List[str]:
        """Get common substitutions for missing ingredients."""
        substitutions = {
            "simple syrup": ["honey", "agave syrup", "maple syrup", "sugar"],
            "lime juice": ["lemon juice", "citric acid solution"],
            "lemon juice": ["lime juice", "citric acid solution"],
            "angostura bitters": ["any aromatic bitters", "orange bitters"],
            "orange bitters": ["angostura bitters", "any citrus bitters"],
            "triple sec": ["cointreau", "grand marnier", "orange liqueur"],
            "cointreau": ["triple sec", "grand marnier", "orange liqueur"],
            "vodka": ["white rum", "gin (for some recipes)"],
            "white rum": ["vodka", "silver tequila"],
            "gin": ["vodka (for some recipes)", "white rum"],
            "whiskey": ["bourbon", "rye whiskey", "scotch"],
            "bourbon": ["whiskey", "rye whiskey"],
            "rye whiskey": ["bourbon", "whiskey"]
        }
        
        return substitutions.get(ingredient_name.lower(), [])
    
    @staticmethod
    async def get_compatible_recipes(available_only: bool = True, include_substitutions: bool = True) -> List[str]:
        """Get list of recipe suggestions based on current inventory."""
        inventory = await InventoryService.load_inventory()
        
        # For now, return basic suggestions based on available spirits
        spirits = [item for item in inventory.items if item.category == IngredientCategory.SPIRITS and item.quantity not in [QuantityDescription.EMPTY, QuantityDescription.ALMOST_EMPTY]]
        
        recipe_suggestions = []
        
        for spirit in spirits:
            spirit_name = spirit.name.lower()
            
            if "vodka" in spirit_name:
                recipe_suggestions.extend(["Moscow Mule", "Bloody Mary", "Cosmopolitan", "Vodka Martini"])
            elif "gin" in spirit_name:
                recipe_suggestions.extend(["Gin & Tonic", "Martini", "Negroni", "Tom Collins"])
            elif "whiskey" in spirit_name or "bourbon" in spirit_name:
                recipe_suggestions.extend(["Old Fashioned", "Manhattan", "Whiskey Sour", "Mint Julep"])
            elif "rum" in spirit_name:
                recipe_suggestions.extend(["Mojito", "Daiquiri", "Piña Colada", "Dark & Stormy"])
            elif "tequila" in spirit_name:
                recipe_suggestions.extend(["Margarita", "Paloma", "Tequila Sunrise", "Mexican Mule"])
        
        # Remove duplicates and return unique suggestions
        return list(set(recipe_suggestions))