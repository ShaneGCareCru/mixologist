"""SQLAlchemy database models for Mixologist application."""
import os
from sqlalchemy import Column, Integer, String, Text, DECIMAL, TIMESTAMP, ForeignKey, Index, Boolean, DateTime
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from datetime import datetime

# Detect backend
DATABASE_URL = os.getenv("DATABASE_URL", "postgresql+asyncpg://mixologist:password@localhost:15432/mixologist")
USE_SQLITE = DATABASE_URL.startswith("sqlite")

if USE_SQLITE:
    JSONType = Text
    TSVECTORType = Text
else:
    from sqlalchemy.dialects.postgresql import JSONB, TSVECTOR
    JSONType = JSONB
    TSVECTORType = TSVECTOR

Base = declarative_base()

# Database migration utility
class DatabaseMigrator:
    """Utility class for managing database migrations."""
    
    @staticmethod
    def create_tables(engine):
        """Create all tables in the database."""
        Base.metadata.create_all(bind=engine)
    
    @staticmethod
    def drop_tables(engine):
        """Drop all tables in the database."""
        Base.metadata.drop_all(bind=engine)

class Recipe(Base):
    """Recipe model storing cocktail recipes and metadata."""
    __tablename__ = "recipes"
    
    id = Column(Integer, primary_key=True)
    cache_key = Column(String(32), unique=True, nullable=False, index=True)
    drink_name = Column(String(255), nullable=False, index=True)
    recipe_data = Column(JSONType, nullable=False)
    created_at = Column(TIMESTAMP, default=func.now())
    updated_at = Column(TIMESTAMP, default=func.now(), onupdate=func.now())
    
    # Extracted fields for fast querying
    alcohol_content = Column(DECIMAL(5,2), index=True)
    difficulty_rating = Column(Integer, index=True)
    preparation_time_minutes = Column(Integer, index=True)
    serving_glass = Column(String(100))
    search_vector = Column(TSVECTORType)
    
    # Relationships
    images = relationship("RecipeImage", back_populates="recipe", cascade="all, delete-orphan")
    
    __table_args__ = ()
    if not USE_SQLITE:
        __table_args__ = (
            Index('idx_recipes_jsonb', 'recipe_data', postgresql_using='gin'),
            Index('idx_recipes_search', 'search_vector', postgresql_using='gin'),
        )

class Image(Base):
    """Image model storing image metadata and file paths."""
    __tablename__ = "images"
    
    id = Column(Integer, primary_key=True)
    cache_key = Column(String(32), unique=True, nullable=False, index=True)
    category = Column(String(50), nullable=False, index=True)  # cocktail, ingredients, equipment, etc.
    file_path = Column(String(500), nullable=False)
    file_size_bytes = Column(Integer)
    content_type = Column(String(100), default='image/png')
    created_at = Column(TIMESTAMP, default=func.now())
    
    # Metadata for different image types
    related_ingredient = Column(String(255), index=True)
    related_equipment = Column(String(255))
    related_technique = Column(String(255))
    related_drink = Column(String(255))
    
    # Relationships
    recipes = relationship("RecipeImage", back_populates="image", cascade="all, delete-orphan")

class User(Base):
    """User model storing user information and Firebase UID."""
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True)
    firebase_uid = Column(String(128), unique=True, nullable=False, index=True)
    email = Column(String(255), unique=True, nullable=True)
    display_name = Column(String(255), nullable=True)
    photo_url = Column(String(500), nullable=True)
    created_at = Column(TIMESTAMP, default=func.now())
    last_login = Column(TIMESTAMP, default=func.now())
    
    # Relationships
    inventory_items = relationship("InventoryItem", back_populates="user", cascade="all, delete-orphan")

class InventoryItem(Base):
    """Inventory item model storing user-specific inventory items."""
    __tablename__ = "inventory_items"
    
    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    item_id = Column(String(36), nullable=False, index=True)  # UUID from frontend
    name = Column(String(255), nullable=False, index=True)
    category = Column(String(50), nullable=False, index=True)
    quantity = Column(String(50), nullable=False)
    fullness = Column(DECIMAL(3,2), default=1.0)
    brand = Column(String(255), nullable=True)
    notes = Column(Text, nullable=True)
    image_path = Column(String(500), nullable=True)
    expires_soon = Column(Boolean, default=False)
    added_date = Column(DateTime, default=func.now())
    last_updated = Column(DateTime, default=func.now(), onupdate=func.now())
    
    # Relationships
    user = relationship("User", back_populates="inventory_items")
    
    # Indexes for efficient queries
    __table_args__ = (
        Index('idx_inventory_user_category', 'user_id', 'category'),
        Index('idx_inventory_user_name', 'user_id', 'name'),
    )

class RecipeImage(Base):
    """Junction table linking recipes and images."""
    __tablename__ = "recipe_images"
    
    recipe_id = Column(Integer, ForeignKey("recipes.id", ondelete="CASCADE"), primary_key=True)
    image_id = Column(Integer, ForeignKey("images.id", ondelete="CASCADE"), primary_key=True)
    image_type = Column(String(50))  # main_cocktail, ingredient_X, step_X, etc.
    
    # Relationships
    recipe = relationship("Recipe", back_populates="images")
    image = relationship("Image", back_populates="recipes") 