import hashlib
import json
from .openai_service import get_db_session, DatabaseService

async def get_cached_recipe(cache_key: str) -> dict | None:
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

def generate_recipe_cache_key(drink_query: str) -> str:
    normalized_query = drink_query.strip().lower()
    cache_hash = hashlib.sha256(normalized_query.encode()).hexdigest()[:16]
    return f"recipe_{cache_hash}" 