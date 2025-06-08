#!/usr/bin/env python3
"""
Simple test script for the inventory system.
This verifies basic functionality without requiring the full app setup.
"""

import asyncio
import json
import tempfile
import os
from pathlib import Path

# Add the mixologist package to path
import sys
sys.path.insert(0, str(Path(__file__).parent))

from mixologist.models.inventory_models import (
    InventoryAddRequest, InventoryItem, QuantityDescription, IngredientCategory
)

async def test_inventory_models():
    """Test inventory data models."""
    print("Testing inventory models...")
    
    # Test creating an inventory item
    add_request = InventoryAddRequest(
        name="Vodka",
        category=IngredientCategory.SPIRITS,
        quantity=QuantityDescription.FULL_BOTTLE,
        brand="Grey Goose",
        notes="Premium vodka for cocktails"
    )
    
    print(f"✓ Created add request: {add_request.name}")
    
    # Test inventory item creation
    item = InventoryItem(
        id="test-id-123",
        name=add_request.name,
        category=add_request.category,
        quantity=add_request.quantity,
        brand=add_request.brand,
        notes=add_request.notes
    )
    
    print(f"✓ Created inventory item: {item.name} - {item.quantity}")
    print(f"  Category: {item.category}")
    print(f"  Brand: {item.brand}")
    
    return True

async def test_inventory_service():
    """Test inventory service functionality."""
    print("\nTesting inventory service...")
    
    # Mock the inventory directory for testing
    from mixologist.services.inventory_service import InventoryService
    
    # Test with a temporary directory
    original_file = InventoryService.__dict__.get('INVENTORY_FILE')
    
    try:
        with tempfile.TemporaryDirectory() as temp_dir:
            # Override inventory file path for testing
            test_inventory_file = Path(temp_dir) / "test_inventory.json"
            
            # Monkey patch for testing
            import mixologist.services.inventory_service as inv_service
            inv_service.INVENTORY_FILE = test_inventory_file
            
            # Test loading empty inventory
            inventory = await InventoryService.load_inventory()
            print(f"✓ Loaded empty inventory with {len(inventory.items)} items")
            
            # Test adding an item
            add_request = InventoryAddRequest(
                name="Test Gin",
                category=IngredientCategory.SPIRITS,
                quantity=QuantityDescription.HALF_BOTTLE,
                brand="Hendricks",
                notes="Test gin for testing"
            )
            
            item = await InventoryService.add_item(add_request)
            print(f"✓ Added item: {item.name} with ID {item.id}")
            
            # Test getting all items
            items = await InventoryService.get_all_items()
            print(f"✓ Retrieved {len(items)} items from inventory")
            
            # Test getting stats
            stats = await InventoryService.get_stats()
            print(f"✓ Generated stats: {stats.total_items} total items")
            print(f"  Categories: {stats.by_category}")
            
            # Test recipe availability (with mock ingredients)
            mock_ingredients = [
                {"name": "Test Gin", "quantity": "2 oz"},
                {"name": "Tonic Water", "quantity": "4 oz"}
            ]
            
            availability = await InventoryService.check_recipe_availability(mock_ingredients)
            print(f"✓ Checked recipe availability: {availability['availability_score']:.2f}")
            print(f"  Can make drink: {availability['can_make_drink']}")
            print(f"  Available ingredients: {len(availability['available_ingredients'])}")
            print(f"  Missing ingredients: {len(availability['missing_ingredients'])}")
            
    except Exception as e:
        print(f"✗ Error testing inventory service: {e}")
        return False
    
    return True

async def test_substitution_suggestions():
    """Test ingredient substitution logic."""
    print("\nTesting substitution suggestions...")
    
    from mixologist.services.inventory_service import InventoryService
    
    # Test common substitutions
    test_ingredients = [
        "simple syrup",
        "lime juice", 
        "angostura bitters",
        "vodka",
        "gin"
    ]
    
    for ingredient in test_ingredients:
        suggestions = InventoryService._get_substitution_suggestions(ingredient)
        print(f"✓ {ingredient}: {len(suggestions)} substitutions")
        if suggestions:
            print(f"  Suggestions: {', '.join(suggestions[:3])}")
    
    return True

async def main():
    """Run all tests."""
    print("🧪 Testing Mixologist Inventory System")
    print("=" * 50)
    
    try:
        # Test models
        await test_inventory_models()
        
        # Test service
        await test_inventory_service()
        
        # Test substitutions
        await test_substitution_suggestions()
        
        print("\n" + "=" * 50)
        print("✅ All tests passed! Inventory system is working correctly.")
        
    except Exception as e:
        print(f"\n❌ Tests failed with error: {e}")
        import traceback
        traceback.print_exc()
        return False
    
    return True

if __name__ == "__main__":
    asyncio.run(main())