"""Database configuration and connection management."""
import os
import logging
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from contextlib import asynccontextmanager
import motor.motor_asyncio

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Database URL - default for development
DEFAULT_DATABASE_URL = "postgresql+asyncpg://mixologist:password@localhost:15432/mixologist"
DATABASE_URL = os.getenv("DATABASE_URL", DEFAULT_DATABASE_URL)

# For testing without PostgreSQL, use SQLite
FALLBACK_DATABASE_URL = "sqlite+aiosqlite:///./mixologist.db"

# MongoDB configuration
MONGODB_URI = os.getenv("MONGODB_URI", "mongodb://mixologist:password@localhost:27017/mixologist")
MONGODB_DB = os.getenv("MONGODB_DB", "mixologist")
MONGODB_IMAGES_COLLECTION = os.getenv("MONGODB_IMAGES_COLLECTION", "images")

def get_database_url():
    """Get the appropriate database URL, with fallback to SQLite for testing."""
    url = os.getenv("DATABASE_URL", DEFAULT_DATABASE_URL)
    # If no DATABASE_URL is set and we want to test without PostgreSQL
    if os.getenv("USE_SQLITE_FALLBACK", "false").lower() == "true":
        return FALLBACK_DATABASE_URL
    return url

# Create async engine
try:
    DATABASE_URL = get_database_url()
    engine = create_async_engine(
        DATABASE_URL, 
        echo=False,  # Set to True for SQL logging
        pool_size=10,
        max_overflow=20
    )
except Exception as e:
    logger.warning(f"Failed to create database engine with URL {DATABASE_URL}: {e}")
    logger.info("Falling back to SQLite for testing")
    DATABASE_URL = FALLBACK_DATABASE_URL
    engine = create_async_engine(
        DATABASE_URL, 
        echo=False,
        pool_size=10,
        max_overflow=20
    )

# Create async session factory
async_session_factory = sessionmaker(
    engine, 
    class_=AsyncSession, 
    expire_on_commit=False
)

# Create a single Motor client instance (reuse for all requests)
mongo_client = motor.motor_asyncio.AsyncIOMotorClient(MONGODB_URI)

@asynccontextmanager
async def get_mongo_collection(collection_name=None):
    """Async context manager for MongoDB collection."""
    db = mongo_client[MONGODB_DB]
    collection = db[collection_name or MONGODB_IMAGES_COLLECTION]
    try:
        yield collection
    finally:
        pass  # Motor handles connection pooling automatically

@asynccontextmanager
async def get_db_session():
    """Context manager for database sessions."""
    async with async_session_factory() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise
        finally:
            await session.close()

async def get_db():
    """Dependency for FastAPI to get database session."""
    async with get_db_session() as session:
        yield session 