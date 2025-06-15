"""Database initialization and migration utilities."""
import logging
import json
from pathlib import Path
from typing import Dict, Any, List
import asyncio

from .config import engine, get_db_session, DATABASE_URL
from .models import Base, Recipe, Image
from .service import DatabaseService
from ..services.openai_service import MongoDBImageService

logger = logging.getLogger(__name__)

async def init_database():
    """Initialize database tables."""
    print(f"[DEBUG] Using DATABASE_URL: {DATABASE_URL}")
    print(f"[DEBUG] Engine: {engine}")
    try:
        async with engine.begin() as conn:
            await conn.run_sync(Base.metadata.create_all)
        logger.info("Database tables created successfully")
        return True
    except Exception as e:
        logger.error(f"Error initializing database: {e}")
        return False

async def migrate_existing_data():
    """Migrate existing cached data to database."""
    try:
        # Get the path to the mixologist directory
        current_dir = Path(__file__).parent.parent
        recipe_cache_dir = current_dir / "static" / "cache" / "recipes"
        image_cache_dir = current_dir / "static" / "img" / "cache"
        
        if not recipe_cache_dir.exists():
            logger.warning(f"Recipe cache directory not found: {recipe_cache_dir}")
            return False
        
        if not image_cache_dir.exists():
            logger.warning(f"Image cache directory not found: {image_cache_dir}")
            return False
        
        async with get_db_session() as session:
            db_service = DatabaseService(session)
            
            # Migrate recipes
            recipe_count = 0
            for recipe_file in recipe_cache_dir.glob("*.json"):
                try:
                    cache_key = recipe_file.stem.replace("recipe_", "")
                    
                    # Check if recipe already exists
                    existing = await db_service.get_recipe_by_cache_key(cache_key)
                    if existing:
                        logger.info(f"Recipe {cache_key} already exists, skipping")
                        continue
                    
                    with open(recipe_file, 'r', encoding='utf-8') as f:
                        recipe_data = json.load(f)
                    
                    success = await db_service.save_recipe(cache_key, recipe_data)
                    if success:
                        recipe_count += 1
                        logger.info(f"Migrated recipe: {recipe_data.get('drink_name', cache_key)}")
                    else:
                        logger.error(f"Failed to migrate recipe: {cache_key}")
                
                except Exception as e:
                    logger.error(f"Error migrating recipe {recipe_file}: {e}")
            
            # Migrate images
            image_count = 0
            for image_file in image_cache_dir.glob("*.txt"):
                try:
                    cache_key = image_file.stem
                    
                    # Check if image already exists in MongoDB
                    mongo_image = await MongoDBImageService.get_image(cache_key)
                    if mongo_image:
                        logger.info(f"Image {cache_key} already exists in MongoDB, skipping")
                        continue
                    
                    # Extract category from filename (e.g., "cocktail_abc123" -> "cocktail")
                    category = cache_key.split("_")[0] if "_" in cache_key else "unknown"
                    
                    # Read image data from file
                    with open(image_file, 'r') as f:
                        b64_data = f.read().strip()
                    
                    # Extract metadata based on category
                    metadata = {}
                    if category == "ingredients":
                        parts = cache_key.split("_")
                        if len(parts) > 1:
                            metadata['related_ingredient'] = "_".join(parts[1:])
                    elif category == "equipment":
                        parts = cache_key.split("_")
                        if len(parts) > 1:
                            metadata['related_equipment'] = "_".join(parts[1:])
                    elif category == "technique":
                        parts = cache_key.split("_")
                        if len(parts) > 1:
                            metadata['related_technique'] = "_".join(parts[1:])
                    
                    # Save image to MongoDB
                    success = await MongoDBImageService.save_image(
                        cache_key=cache_key,
                        category=category,
                        b64_data=b64_data,
                        **metadata
                    )
                    
                    if success:
                        image_count += 1
                        logger.info(f"Migrated image to MongoDB: {cache_key}")
                    else:
                        logger.error(f"Failed to migrate image to MongoDB: {cache_key}")
                
                except Exception as e:
                    logger.error(f"Error migrating image {image_file}: {e}")
            
            logger.info(f"Migration complete: {recipe_count} recipes, {image_count} images")
            return True
            
    except Exception as e:
        logger.error(f"Error during data migration: {e}")
        return False

async def check_database_connection():
    """Check if database connection is working."""
    try:
        async with get_db_session() as session:
            db_service = DatabaseService(session)
            count = await db_service.get_recipe_count()
            logger.info(f"Database connection successful. Recipe count: {count}")
            return True
    except Exception as e:
        logger.error(f"Database connection failed: {e}")
        return False

async def initialize_app_database():
    """Initialize database for the application on startup."""
    logger.info("Starting database initialization...")
    
    # Check connection
    if not await check_database_connection():
        logger.error("Database connection failed. Please check your database configuration.")
        return False
    
    # Initialize tables
    if not await init_database():
        logger.error("Failed to initialize database tables.")
        return False
    
    # Migrate existing data
    if not await migrate_existing_data():
        logger.warning("Data migration failed or partially completed.")
    
    logger.info("Database initialization complete.")
    return True

if __name__ == "__main__":
    # Allow running this script directly for testing
    asyncio.run(initialize_app_database()) 