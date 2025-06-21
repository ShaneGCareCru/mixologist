"""
Multi-user inventory service with database backend and Firebase authentication.
This service replaces the file-based inventory system with a proper database
that supports multiple users with Firebase authentication.
"""

import uuid
import logging
from typing import Optional, List, Dict
from datetime import datetime
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, delete, func
from sqlalchemy.orm import selectinload

from ..database.database_config import async_session_factory
from ..database.models import User, InventoryItem
from ..models.inventory_models import (
    Inventory, InventoryItem as InventoryItemModel, InventoryAddRequest, 
    InventoryUpdateRequest, ImageRecognitionRequest, ImageRecognitionResponse, 
    RecognizedIngredient, InventoryFilterRequest, InventoryStats, 
    QuantityDescription, IngredientCategory
)
from .inventory_service import InventoryService  # For image analysis functionality
from ..utils.logging_config import get_logger, log_user_action, log_inventory_operation

logger = get_logger('multiuser_inventory')

class MultiUserInventoryService:
    """Service for managing user-specific inventory with database backend."""
    
    @staticmethod
    async def get_or_create_user(firebase_uid: str, email: str = None, 
                               display_name: str = None, photo_url: str = None) -> User:
        """Get existing user or create new user from Firebase authentication."""
        async with async_session_factory() as session:
            # Try to find existing user
            result = await session.execute(
                select(User).where(User.firebase_uid == firebase_uid)
            )
            user = result.scalar_one_or_none()
            
            if user:
                # Update last login
                user.last_login = datetime.now()
                if email and user.email != email:
                    user.email = email
                if display_name and user.display_name != display_name:
                    user.display_name = display_name
                if photo_url and user.photo_url != photo_url:
                    user.photo_url = photo_url
                
                logger.info(f"👤 User login: {firebase_uid} ({email})", extra={
                    'user_id': firebase_uid,
                    'user_email': email,
                    'operation': 'user_login'
                })
            else:
                # Create new user
                user = User(
                    firebase_uid=firebase_uid,
                    email=email,
                    display_name=display_name or "Anonymous User",
                    photo_url=photo_url,
                    created_at=datetime.now(),
                    last_login=datetime.now()
                )
                session.add(user)
                
                logger.info(f"🆕 New user created: {firebase_uid} ({email})", extra={
                    'user_id': firebase_uid,
                    'user_email': email,
                    'operation': 'user_created'
                })
            
            await session.commit()
            await session.refresh(user)
            return user
    
    @staticmethod
    async def load_user_inventory(firebase_uid: str) -> Inventory:
        """Load inventory for a specific user."""
        async with async_session_factory() as session:
            # Get user
            user_result = await session.execute(
                select(User).where(User.firebase_uid == firebase_uid)
            )
            user = user_result.scalar_one_or_none()
            
            if not user:
                logger.warning(f"⚠️ User with UID {firebase_uid} not found", extra={
                    'user_id': firebase_uid,
                    'operation': 'load_inventory_user_not_found'
                })
                return Inventory()
            
            # Get user's inventory items
            items_result = await session.execute(
                select(InventoryItem)
                .where(InventoryItem.user_id == user.id)
                .order_by(InventoryItem.name)
            )
            db_items = items_result.scalars().all()
            
            # Convert database items to Pydantic models
            inventory_items = []
            for db_item in db_items:
                inventory_item = InventoryItemModel(
                    id=db_item.item_id,
                    name=db_item.name,
                    category=IngredientCategory(db_item.category),
                    quantity=QuantityDescription(db_item.quantity),
                    fullness=float(db_item.fullness),
                    brand=db_item.brand,
                    notes=db_item.notes,
                    image_path=db_item.image_path,
                    expires_soon=db_item.expires_soon,
                    added_date=db_item.added_date,
                    last_updated=db_item.last_updated
                )
                inventory_items.append(inventory_item)
            
            return Inventory(
                user_id=firebase_uid,
                items=inventory_items,
                created_date=user.created_at,
                last_updated=max([item.last_updated for item in inventory_items], default=user.created_at)
            )
    
    @staticmethod
    async def add_item(firebase_uid: str, request: InventoryAddRequest) -> InventoryItemModel:
        """Add a new item to user's inventory."""
        async with async_session_factory() as session:
            # Get or create user
            user = await MultiUserInventoryService.get_or_create_user(firebase_uid)
            
            # Create new inventory item
            item_id = str(uuid.uuid4())
            db_item = InventoryItem(
                user_id=user.id,
                item_id=item_id,
                name=request.name,
                category=request.category.value,
                quantity=request.quantity.value,
                fullness=MultiUserInventoryService._calculate_fullness_from_quantity(request.quantity),
                brand=request.brand,
                notes=request.notes,
                image_path=None,  # Set separately if image is provided
                expires_soon=False,
                added_date=datetime.now(),
                last_updated=datetime.now()
            )
            
            session.add(db_item)
            await session.commit()
            await session.refresh(db_item)
            
            # Convert back to Pydantic model
            return InventoryItemModel(
                id=db_item.item_id,
                name=db_item.name,
                category=IngredientCategory(db_item.category),
                quantity=QuantityDescription(db_item.quantity),
                fullness=float(db_item.fullness),
                brand=db_item.brand,
                notes=db_item.notes,
                image_path=db_item.image_path,
                expires_soon=db_item.expires_soon,
                added_date=db_item.added_date,
                last_updated=db_item.last_updated
            )
    
    @staticmethod
    async def get_all_items(firebase_uid: str) -> List[InventoryItemModel]:
        """Get all inventory items for a user."""
        inventory = await MultiUserInventoryService.load_user_inventory(firebase_uid)
        return inventory.items
    
    @staticmethod
    async def get_item_by_id(firebase_uid: str, item_id: str) -> Optional[InventoryItemModel]:
        """Get specific inventory item by ID for a user."""
        async with async_session_factory() as session:
            # Get user
            user_result = await session.execute(
                select(User).where(User.firebase_uid == firebase_uid)
            )
            user = user_result.scalar_one_or_none()
            
            if not user:
                return None
            
            # Get item
            item_result = await session.execute(
                select(InventoryItem)
                .where(InventoryItem.user_id == user.id)
                .where(InventoryItem.item_id == item_id)
            )
            db_item = item_result.scalar_one_or_none()
            
            if not db_item:
                return None
            
            return InventoryItemModel(
                id=db_item.item_id,
                name=db_item.name,
                category=IngredientCategory(db_item.category),
                quantity=QuantityDescription(db_item.quantity),
                fullness=float(db_item.fullness),
                brand=db_item.brand,
                notes=db_item.notes,
                image_path=db_item.image_path,
                expires_soon=db_item.expires_soon,
                added_date=db_item.added_date,
                last_updated=db_item.last_updated
            )
    
    @staticmethod
    async def update_item(firebase_uid: str, item_id: str, 
                         request: InventoryUpdateRequest) -> Optional[InventoryItemModel]:
        """Update an inventory item for a user."""
        async with async_session_factory() as session:
            # Get user
            user_result = await session.execute(
                select(User).where(User.firebase_uid == firebase_uid)
            )
            user = user_result.scalar_one_or_none()
            
            if not user:
                return None
            
            # Get item
            item_result = await session.execute(
                select(InventoryItem)
                .where(InventoryItem.user_id == user.id)
                .where(InventoryItem.item_id == item_id)
            )
            db_item = item_result.scalar_one_or_none()
            
            if not db_item:
                return None
            
            # Update fields if provided
            if request.quantity is not None:
                db_item.quantity = request.quantity.value
                db_item.fullness = MultiUserInventoryService._calculate_fullness_from_quantity(request.quantity)
            if request.brand is not None:
                db_item.brand = request.brand
            if request.notes is not None:
                db_item.notes = request.notes
            if request.expires_soon is not None:
                db_item.expires_soon = request.expires_soon
            
            db_item.last_updated = datetime.now()
            
            await session.commit()
            await session.refresh(db_item)
            
            return InventoryItemModel(
                id=db_item.item_id,
                name=db_item.name,
                category=IngredientCategory(db_item.category),
                quantity=QuantityDescription(db_item.quantity),
                fullness=float(db_item.fullness),
                brand=db_item.brand,
                notes=db_item.notes,
                image_path=db_item.image_path,
                expires_soon=db_item.expires_soon,
                added_date=db_item.added_date,
                last_updated=db_item.last_updated
            )
    
    @staticmethod
    async def delete_item(firebase_uid: str, item_id: str) -> bool:
        """Delete an inventory item for a user."""
        async with async_session_factory() as session:
            # Get user
            user_result = await session.execute(
                select(User).where(User.firebase_uid == firebase_uid)
            )
            user = user_result.scalar_one_or_none()
            
            if not user:
                return False
            
            # Delete item
            result = await session.execute(
                delete(InventoryItem)
                .where(InventoryItem.user_id == user.id)
                .where(InventoryItem.item_id == item_id)
            )
            
            await session.commit()
            return result.rowcount > 0
    
    @staticmethod
    async def get_stats(firebase_uid: str) -> InventoryStats:
        """Get inventory statistics for a user."""
        async with async_session_factory() as session:
            # Get user
            user_result = await session.execute(
                select(User).where(User.firebase_uid == firebase_uid)
            )
            user = user_result.scalar_one_or_none()
            
            if not user:
                return InventoryStats()
            
            # Get stats with database queries
            total_result = await session.execute(
                select(func.count()).select_from(InventoryItem)
                .where(InventoryItem.user_id == user.id)
            )
            total_items = total_result.scalar()
            
            category_result = await session.execute(
                select(InventoryItem.category, func.count())
                .where(InventoryItem.user_id == user.id)
                .group_by(InventoryItem.category)
            )
            categories = dict(category_result.all())
            
            low_stock_result = await session.execute(
                select(func.count()).select_from(InventoryItem)
                .where(InventoryItem.user_id == user.id)
                .where(InventoryItem.quantity.in_(['empty', 'almost_empty']))
            )
            low_stock_items = low_stock_result.scalar()
            
            expiring_result = await session.execute(
                select(func.count()).select_from(InventoryItem)
                .where(InventoryItem.user_id == user.id)
                .where(InventoryItem.expires_soon == True)
            )
            expiring_items = expiring_result.scalar()
            
            return InventoryStats(
                total_items=total_items,
                categories=categories,
                low_stock_items=low_stock_items,
                expiring_items=expiring_items
            )
    
    @staticmethod
    async def analyze_image_for_ingredients(firebase_uid: str, 
                                          request: ImageRecognitionRequest) -> ImageRecognitionResponse:
        """Use OpenAI to analyze image and recognize ingredients for a user."""
        # Get user's existing inventory for context
        inventory = await MultiUserInventoryService.load_user_inventory(firebase_uid)
        existing_names = [item.name for item in inventory.items]
        
        # Update request with user's existing inventory
        request.existing_inventory = existing_names
        
        # Use the original image analysis service
        return await InventoryService.analyze_image_for_ingredients(request)
    
    @staticmethod
    async def check_recipe_availability(firebase_uid: str, 
                                      recipe_ingredients: List[Dict[str, str]]) -> Dict[str, any]:
        """Check if recipe ingredients are available in user's inventory."""
        inventory = await MultiUserInventoryService.load_user_inventory(firebase_uid)
        
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
    async def get_compatible_recipes(firebase_uid: str, available_only: bool = True, 
                                   include_substitutions: bool = True) -> List[str]:
        """Get list of recipe suggestions based on user's current inventory."""
        inventory = await MultiUserInventoryService.load_user_inventory(firebase_uid)
        
        # For now, return basic suggestions based on available spirits
        spirits = [
            item for item in inventory.items 
            if item.category == IngredientCategory.SPIRITS 
            and item.quantity not in [QuantityDescription.EMPTY, QuantityDescription.ALMOST_EMPTY]
        ]
        
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
    
    @staticmethod
    def _calculate_fullness_from_quantity(quantity: QuantityDescription) -> float:
        """Calculate numeric fullness from quantity description."""
        fullness_map = {
            QuantityDescription.EMPTY: 0.0,
            QuantityDescription.ALMOST_EMPTY: 0.1,
            QuantityDescription.QUARTER_BOTTLE: 0.25,
            QuantityDescription.HALF_BOTTLE: 0.5,
            QuantityDescription.THREE_QUARTER_BOTTLE: 0.75,
            QuantityDescription.FULL_BOTTLE: 1.0,
            QuantityDescription.MULTIPLE_BOTTLES: 1.0,
            QuantityDescription.SMALL_AMOUNT: 0.2,
            QuantityDescription.MEDIUM_AMOUNT: 0.5,
            QuantityDescription.LARGE_AMOUNT: 0.8,
            QuantityDescription.VERY_LARGE_AMOUNT: 1.0,
        }
        return fullness_map.get(quantity, 1.0)