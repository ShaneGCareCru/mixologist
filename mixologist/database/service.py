"""Database service layer for recipe and image operations."""
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_, or_, func, text
from sqlalchemy.orm import selectinload
from typing import Optional, List, Dict, Any
from pathlib import Path
import logging
import json

from .models import Recipe, Image, RecipeImage

logger = logging.getLogger(__name__)

class DatabaseService:
    """Service class for database operations."""
    
    def __init__(self, session: AsyncSession):
        self.session = session
        logger.debug("DatabaseService session initialized.")
    
    # Recipe operations
    async def get_recipe_by_cache_key(self, cache_key: str) -> Optional[Dict[str, Any]]:
        """Get recipe by cache key (maintains current API compatibility)."""
        try:
            logger.debug(f"Querying recipe by cache_key: {cache_key}")
            result = await self.session.execute(
                select(Recipe).where(Recipe.cache_key == cache_key)
            )
            recipe = result.scalar_one_or_none()
            if recipe:
                logger.debug(f"Recipe found for cache_key: {cache_key}")
            else:
                logger.debug(f"No recipe found for cache_key: {cache_key}")
            return recipe.recipe_data if recipe else None
        except Exception as e:
            logger.error(f"Error getting recipe by cache key {cache_key}: {e}")
            return None
    
    async def save_recipe(self, cache_key: str, recipe_data: Dict[str, Any]) -> bool:
        """Save recipe to database (maintains current API compatibility)."""
        try:
            logger.debug(f"Saving recipe with cache_key: {cache_key}")
            # Check if recipe already exists
            existing = await self.session.execute(
                select(Recipe).where(Recipe.cache_key == cache_key)
            )
            existing_recipe = existing.scalar_one_or_none()
            
            if existing_recipe:
                logger.debug(f"Updating existing recipe for cache_key: {cache_key}")
                # Update existing recipe
                existing_recipe.recipe_data = recipe_data
                existing_recipe.drink_name = recipe_data.get("drink_name", "")
                existing_recipe.alcohol_content = recipe_data.get("alcohol_content")
                existing_recipe.difficulty_rating = recipe_data.get("difficulty_rating")
                existing_recipe.preparation_time_minutes = recipe_data.get("preparation_time_minutes")
                existing_recipe.serving_glass = recipe_data.get("serving_glass")
                existing_recipe.updated_at = func.now()
            else:
                logger.debug(f"Creating new recipe for cache_key: {cache_key}")
                # Create new recipe
                recipe = Recipe(
                    cache_key=cache_key,
                    drink_name=recipe_data.get("drink_name", ""),
                    recipe_data=recipe_data,
                    alcohol_content=recipe_data.get("alcohol_content"),
                    difficulty_rating=recipe_data.get("difficulty_rating"),
                    preparation_time_minutes=recipe_data.get("preparation_time_minutes"),
                    serving_glass=recipe_data.get("serving_glass")
                )
                self.session.add(recipe)
            
            # Update search vector
            search_text_parts = [recipe_data.get('drink_name', '')]
            
            # Add ingredient names to search text
            ingredients = recipe_data.get('ingredients', [])
            if ingredients:
                for ingredient in ingredients:
                    if isinstance(ingredient, dict):
                        search_text_parts.append(ingredient.get('name', ''))
                    else:
                        search_text_parts.append(str(ingredient))
            
            # Add flavor profile to search text
            flavor_profile = recipe_data.get('flavor_profile', {})
            if isinstance(flavor_profile, dict):
                primary_flavors = flavor_profile.get('primary_flavors', [])
                if primary_flavors:
                    search_text_parts.extend(primary_flavors)
            
            search_text = ' '.join(filter(None, search_text_parts))
            
            if existing_recipe:
                # Update search vector for existing recipe
                await self.session.execute(
                    text("UPDATE recipes SET search_vector = to_tsvector('english', :search_text) WHERE cache_key = :cache_key"),
                    {"search_text": search_text, "cache_key": cache_key}
                )
            else:
                # Set search vector for new recipe
                await self.session.flush()  # Ensure recipe is in DB
                await self.session.execute(
                    text("UPDATE recipes SET search_vector = to_tsvector('english', :search_text) WHERE cache_key = :cache_key"),
                    {"search_text": search_text, "cache_key": cache_key}
                )
            
            await self.session.commit()
            logger.info(f"Recipe saved successfully for cache_key: {cache_key}")
            return True
            
        except Exception as e:
            logger.error(f"Error saving recipe {cache_key}: {e}")
            await self.session.rollback()
            return False
    
    async def search_recipes(
        self, 
        query: Optional[str] = None,
        difficulty_max: Optional[int] = None,
        prep_time_max: Optional[int] = None,
        has_ingredients: Optional[List[str]] = None,
        limit: int = 20,
        offset: int = 0
    ) -> List[Dict[str, Any]]:
        """Enhanced recipe search capabilities."""
        try:
            stmt = select(Recipe)
            conditions = []
            
            if query:
                # Use PostgreSQL full-text search
                conditions.append(Recipe.search_vector.match(query))
            
            if difficulty_max is not None:
                conditions.append(Recipe.difficulty_rating <= difficulty_max)
            
            if prep_time_max is not None:
                conditions.append(Recipe.preparation_time_minutes <= prep_time_max)
            
            if has_ingredients:
                # Search for recipes containing specific ingredients
                for ingredient in has_ingredients:
                    conditions.append(
                        Recipe.recipe_data.op('@>')([{"name": ingredient}])
                    )
            
            if conditions:
                stmt = stmt.where(and_(*conditions))
            
            stmt = stmt.order_by(Recipe.created_at.desc()).limit(limit).offset(offset)
            
            result = await self.session.execute(stmt)
            recipes = result.scalars().all()
            
            return [recipe.recipe_data for recipe in recipes]
            
        except Exception as e:
            logger.error(f"Error searching recipes: {e}")
            return []
    
    async def get_all_recipes(self, limit: int = 100, offset: int = 0) -> List[Dict[str, Any]]:
        """Get all recipes with pagination."""
        try:
            logger.debug(f"Querying all recipes with limit={limit}, offset={offset}")
            stmt = select(Recipe).order_by(Recipe.created_at.desc()).limit(limit).offset(offset)
            result = await self.session.execute(stmt)
            recipes = result.scalars().all()
            logger.debug(f"Fetched {len(recipes)} recipes.")
            return [recipe.recipe_data for recipe in recipes]
        except Exception as e:
            logger.error(f"Error getting all recipes: {e}")
            return []
    
    # Image operations
    async def get_image_by_cache_key(self, cache_key: str) -> Optional[str]:
        """Get image file content by cache key (maintains current API compatibility)."""
        try:
            logger.debug(f"Querying image by cache_key: {cache_key}")
            result = await self.session.execute(
                select(Image).where(Image.cache_key == cache_key)
            )
            image = result.scalar_one_or_none()
            
            if image and Path(image.file_path).exists():
                logger.debug(f"Image file found for cache_key: {cache_key}, reading file.")
                # Read and return base64 content (maintain current API)
                with open(image.file_path, 'r') as f:
                    return f.read().strip()
            logger.debug(f"No image file found for cache_key: {cache_key}")
            return None
            
        except Exception as e:
            logger.error(f"Error getting image by cache key {cache_key}: {e}")
            return None
    
    async def save_image_metadata(
        self, 
        cache_key: str, 
        category: str, 
        file_path: str,
        file_size: Optional[int] = None,
        **metadata
    ) -> bool:
        """Save image metadata to database."""
        try:
            logger.debug(f"Saving image metadata for cache_key: {cache_key}")
            # Check if image already exists
            existing = await self.session.execute(
                select(Image).where(Image.cache_key == cache_key)
            )
            existing_image = existing.scalar_one_or_none()
            
            if existing_image:
                logger.debug(f"Updating existing image metadata for cache_key: {cache_key}")
                # Update existing image metadata
                existing_image.category = category
                existing_image.file_path = file_path
                existing_image.file_size_bytes = file_size
                existing_image.related_ingredient = metadata.get('related_ingredient')
                existing_image.related_equipment = metadata.get('related_equipment')
                existing_image.related_technique = metadata.get('related_technique')
                existing_image.related_drink = metadata.get('related_drink')
            else:
                logger.debug(f"Creating new image metadata for cache_key: {cache_key}")
                # Create new image metadata
                image = Image(
                    cache_key=cache_key,
                    category=category,
                    file_path=file_path,
                    file_size_bytes=file_size,
                    related_ingredient=metadata.get('related_ingredient'),
                    related_equipment=metadata.get('related_equipment'),
                    related_technique=metadata.get('related_technique'),
                    related_drink=metadata.get('related_drink')
                )
                self.session.add(image)
            
            await self.session.commit()
            logger.info(f"Image metadata saved successfully for cache_key: {cache_key}")
            return True
            
        except Exception as e:
            logger.error(f"Error saving image metadata {cache_key}: {e}")
            await self.session.rollback()
            return False
    
    async def get_images_by_category(self, category: str) -> List[Dict[str, Any]]:
        """Get all images by category."""
        try:
            logger.debug(f"Querying images by category: {category}")
            result = await self.session.execute(
                select(Image).where(Image.category == category).order_by(Image.created_at.desc())
            )
            images = result.scalars().all()
            logger.debug(f"Fetched {len(images)} images for category: {category}")
            return [{
                'cache_key': img.cache_key,
                'category': img.category,
                'file_path': img.file_path,
                'file_size_bytes': img.file_size_bytes,
                'related_ingredient': img.related_ingredient,
                'related_equipment': img.related_equipment,
                'related_technique': img.related_technique,
                'related_drink': img.related_drink,
                'created_at': img.created_at.isoformat() if img.created_at else None
            } for img in images]
            
        except Exception as e:
            logger.error(f"Error getting images by category {category}: {e}")
            return []
    
    # Statistics and utility methods
    async def get_recipe_count(self) -> int:
        """Get total number of recipes."""
        try:
            logger.debug("Counting total recipes in database.")
            result = await self.session.execute(select(func.count(Recipe.id)))
            count = result.scalar()
            logger.info(f"Total recipes in database: {count}")
            return count
        except Exception as e:
            logger.error(f"Error getting recipe count: {e}")
            return 0
    
    async def get_image_count(self) -> int:
        """Get total number of images."""
        try:
            logger.debug("Counting total images in database.")
            result = await self.session.execute(select(func.count(Image.id)))
            count = result.scalar()
            logger.info(f"Total images in database: {count}")
            return count
        except Exception as e:
            logger.error(f"Error getting image count: {e}")
            return 0 