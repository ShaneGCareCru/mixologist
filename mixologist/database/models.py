"""SQLAlchemy database models for Mixologist application."""
import os
from sqlalchemy import Column, Integer, String, Text, DECIMAL, TIMESTAMP, ForeignKey, Index, Boolean
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

class RecipeImage(Base):
    """Junction table linking recipes and images."""
    __tablename__ = "recipe_images"
    
    recipe_id = Column(Integer, ForeignKey("recipes.id", ondelete="CASCADE"), primary_key=True)
    image_id = Column(Integer, ForeignKey("images.id", ondelete="CASCADE"), primary_key=True)
    image_type = Column(String(50))  # main_cocktail, ingredient_X, step_X, etc.
    
    # Relationships
    recipe = relationship("Recipe", back_populates="images")
    image = relationship("Image", back_populates="recipes") 