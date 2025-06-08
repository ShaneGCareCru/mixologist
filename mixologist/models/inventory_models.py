from pydantic import BaseModel, Field
from typing import Optional, List, Dict, Union
from enum import Enum
from datetime import datetime


class QuantityDescription(str, Enum):
    """User-friendly quantity descriptions."""
    EMPTY = "empty"
    ALMOST_EMPTY = "almost empty"
    QUARTER_BOTTLE = "quarter bottle"
    HALF_BOTTLE = "half bottle"
    THREE_QUARTER_BOTTLE = "three quarter bottle"
    FULL_BOTTLE = "full bottle"
    MULTIPLE_BOTTLES = "multiple bottles"
    SMALL_AMOUNT = "small amount"
    MEDIUM_AMOUNT = "medium amount"
    LARGE_AMOUNT = "large amount"
    VERY_LARGE_AMOUNT = "very large amount"


class IngredientCategory(str, Enum):
    """Categories of cocktail ingredients."""
    SPIRITS = "spirits"
    LIQUEURS = "liqueurs" 
    BITTERS = "bitters"
    SYRUPS = "syrups"
    JUICES = "juices"
    FRESH_INGREDIENTS = "fresh_ingredients"
    GARNISHES = "garnishes"
    MIXERS = "mixers"
    EQUIPMENT = "equipment"
    OTHER = "other"


class InventoryItem(BaseModel):
    """Individual inventory item."""
    id: str = Field(..., description="Unique identifier for the item")
    name: str = Field(..., description="Name of the ingredient")
    category: IngredientCategory = Field(..., description="Category of the ingredient")
    quantity: QuantityDescription = Field(..., description="User-friendly quantity description")
    brand: Optional[str] = Field(None, description="Brand name if applicable")
    notes: Optional[str] = Field(None, description="Additional user notes")
    added_date: datetime = Field(default_factory=datetime.now, description="When item was added")
    last_updated: datetime = Field(default_factory=datetime.now, description="Last update timestamp")
    expires_soon: Optional[bool] = Field(False, description="Flag if ingredient expires soon")
    
    def update_quantity(self, new_quantity: QuantityDescription):
        """Update quantity and timestamp."""
        self.quantity = new_quantity
        self.last_updated = datetime.now()


class InventoryAddRequest(BaseModel):
    """Request to add an item to inventory."""
    name: str = Field(..., description="Name of the ingredient")
    category: IngredientCategory = Field(..., description="Category of the ingredient")
    quantity: QuantityDescription = Field(..., description="Quantity description")
    brand: Optional[str] = Field(None, description="Brand name if applicable")
    notes: Optional[str] = Field(None, description="Additional notes")


class InventoryUpdateRequest(BaseModel):
    """Request to update an inventory item."""
    quantity: Optional[QuantityDescription] = Field(None, description="New quantity")
    brand: Optional[str] = Field(None, description="New brand")
    notes: Optional[str] = Field(None, description="New notes")
    expires_soon: Optional[bool] = Field(None, description="Expiry flag")


class ImageRecognitionRequest(BaseModel):
    """Request for OpenAI vision analysis of inventory image."""
    image_base64: str = Field(..., description="Base64 encoded image")
    existing_inventory: Optional[List[str]] = Field([], description="List of existing inventory items")


class RecognizedIngredient(BaseModel):
    """Ingredient recognized from image."""
    name: str = Field(..., description="Recognized ingredient name")
    category: IngredientCategory = Field(..., description="Predicted category")
    confidence: float = Field(..., description="Confidence score (0-1)")
    brand: Optional[str] = Field(None, description="Recognized brand if visible")
    quantity_estimate: Optional[QuantityDescription] = Field(None, description="Estimated quantity if visible")
    location_description: Optional[str] = Field(None, description="Where in image this item was found")


class ImageRecognitionResponse(BaseModel):
    """Response from image recognition."""
    recognized_ingredients: List[RecognizedIngredient] = Field(..., description="List of recognized ingredients")
    suggestions: List[str] = Field([], description="Additional suggestions or notes")
    processing_time: Optional[float] = Field(None, description="Time taken to process")


class InventoryFilterRequest(BaseModel):
    """Request to filter recipes based on inventory."""
    available_only: bool = Field(True, description="Only show recipes with available ingredients")
    include_substitutions: bool = Field(True, description="Include recipes with ingredient substitutions")
    missing_ingredient_limit: int = Field(0, description="Max missing ingredients to allow")


class InventoryStats(BaseModel):
    """Statistics about current inventory."""
    total_items: int = Field(..., description="Total number of items")
    by_category: Dict[str, int] = Field(..., description="Count by category")
    by_quantity: Dict[str, int] = Field(..., description="Count by quantity level")
    expiring_soon: int = Field(..., description="Items expiring soon")
    last_updated: datetime = Field(..., description="When inventory was last updated")


class Inventory(BaseModel):
    """Complete inventory structure."""
    items: List[InventoryItem] = Field(default_factory=list, description="List of inventory items")
    user_id: str = Field("default_user", description="User identifier")
    created_date: datetime = Field(default_factory=datetime.now, description="When inventory was created")
    last_updated: datetime = Field(default_factory=datetime.now, description="Last update timestamp")
    
    def add_item(self, item: InventoryItem) -> None:
        """Add an item to inventory."""
        self.items.append(item)
        self.last_updated = datetime.now()
    
    def get_item_by_id(self, item_id: str) -> Optional[InventoryItem]:
        """Get item by ID."""
        return next((item for item in self.items if item.id == item_id), None)
    
    def remove_item(self, item_id: str) -> bool:
        """Remove item by ID."""
        original_length = len(self.items)
        self.items = [item for item in self.items if item.id != item_id]
        if len(self.items) < original_length:
            self.last_updated = datetime.now()
            return True
        return False
    
    def get_stats(self) -> InventoryStats:
        """Get inventory statistics."""
        by_category = {}
        by_quantity = {}
        expiring_soon = 0
        
        for item in self.items:
            # Count by category
            category_key = item.category.value
            by_category[category_key] = by_category.get(category_key, 0) + 1
            
            # Count by quantity
            quantity_key = item.quantity.value
            by_quantity[quantity_key] = by_quantity.get(quantity_key, 0) + 1
            
            # Count expiring items
            if item.expires_soon:
                expiring_soon += 1
        
        return InventoryStats(
            total_items=len(self.items),
            by_category=by_category,
            by_quantity=by_quantity,
            expiring_soon=expiring_soon,
            last_updated=self.last_updated
        )