import logging
from .openai_service import get_mongo_collection

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
                logging.debug(f"Saving image to MongoDB: {cache_key}, category: {category}")
                result = await collection.update_one(
                    {"cache_key": cache_key},
                    {"$set": doc},
                    upsert=True
                )
                if result.acknowledged:
                    logging.info(f"Image saved to MongoDB: {cache_key}")
                else:
                    logging.error(f"Image save to MongoDB not acknowledged: {cache_key}")
                return result.acknowledged
        except Exception as e:
            logging.error(f"Error saving image to MongoDB: {cache_key}: {e}")
            return False

    @staticmethod
    async def get_image(cache_key: str) -> str | None:
        try:
            async with get_mongo_collection() as collection:
                logging.debug(f"Fetching image from MongoDB: {cache_key}")
                doc = await collection.find_one({"cache_key": cache_key})
                if doc:
                    logging.debug(f"Image found in MongoDB: {cache_key}")
                    return doc.get("b64_data")
                logging.debug(f"Image not found in MongoDB: {cache_key}")
                return None
        except Exception as e:
            logging.error(f"Error fetching image from MongoDB: {cache_key}: {e}")
            return None

    @staticmethod
    async def get_images_by_category(category: str) -> list[dict]:
        try:
            async with get_mongo_collection() as collection:
                logging.debug(f"Fetching images by category from MongoDB: {category}")
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
                logging.debug(f"Fetched {len(images)} images from MongoDB for category: {category}")
                return images
        except Exception as e:
            logging.error(f"Error fetching images by category from MongoDB: {category}: {e}")
            return []

STEP_IMAGE_INDEX_COLLECTION = "step_image_index"

async def get_cached_image(cache_key: str) -> str | None:
    return await MongoDBImageService.get_image(cache_key)

async def save_image_to_cache(cache_key: str, b64_data: str) -> None:
    category = cache_key.split("_")[0] if "_" in cache_key else "unknown"
    await MongoDBImageService.save_image(cache_key, category, b64_data)

async def get_step_image_mapping(step_hash: str) -> str | None:
    try:
        async with get_mongo_collection(STEP_IMAGE_INDEX_COLLECTION) as collection:
            logging.debug(f"Fetching step image mapping from MongoDB: {step_hash}")
            doc = await collection.find_one({"step_hash": step_hash})
            if doc:
                logging.debug(f"Step image mapping found in MongoDB: {step_hash}")
                return doc.get("cache_key")
            logging.debug(f"Step image mapping not found in MongoDB: {step_hash}")
            return None
    except Exception as e:
        logging.error(f"Error fetching step image mapping from MongoDB: {step_hash}: {e}")
        return None

async def set_step_image_mapping(step_hash: str, cache_key: str) -> None:
    try:
        async with get_mongo_collection(STEP_IMAGE_INDEX_COLLECTION) as collection:
            logging.debug(f"Saving step image mapping to MongoDB: {step_hash} -> {cache_key}")
            await collection.update_one(
                {"step_hash": step_hash},
                {"$set": {"step_hash": step_hash, "cache_key": cache_key}},
                upsert=True
            )
            logging.info(f"Step image mapping saved to MongoDB: {step_hash} -> {cache_key}")
    except Exception as e:
        logging.error(f"Error saving step image mapping to MongoDB: {step_hash} -> {cache_key}: {e}") 