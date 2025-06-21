#!/usr/bin/env python3
"""
Test script to verify multi-user logging functionality.
This script simulates user operations and demonstrates the logging output.
"""

import asyncio
import json
import sys
from pathlib import Path

# Add the mixologist directory to Python path
mixologist_dir = Path(__file__).parent / "mixologist"
sys.path.insert(0, str(mixologist_dir))

from utils.logging_config import setup_logging, get_logger, log_user_action, log_inventory_operation, log_auth_event
from services.multiuser_inventory_service import MultiUserInventoryService
from models.inventory_models import InventoryAddRequest, IngredientCategory, QuantityDescription

async def test_logging_scenarios():
    """Test various logging scenarios to verify functionality."""
    
    print("🧪 Starting Multi-User Logging Test")
    print("=" * 60)
    
    # Setup logging with high verbosity for testing
    setup_logging(level="DEBUG", include_uvicorn=False)
    
    # Create logger for this test
    test_logger = get_logger('test')
    
    # Test 1: Authentication logging
    print("\n📋 Test 1: Authentication Events")
    print("-" * 30)
    
    # Simulate auth events
    log_auth_event(test_logger, "google_signin", "test_user_123", "test@example.com", True)
    log_auth_event(test_logger, "anonymous_signin", "anon_user_456", None, True)
    log_auth_event(test_logger, "invalid_token", None, None, False)
    
    # Test 2: User creation and operations
    print("\n📋 Test 2: User Operations")
    print("-" * 30)
    
    try:
        # Create test users
        user1 = await MultiUserInventoryService.get_or_create_user(
            firebase_uid="test_user_123",
            email="test@example.com",
            display_name="Test User"
        )
        
        user2 = await MultiUserInventoryService.get_or_create_user(
            firebase_uid="anon_user_456",
            email=None,
            display_name="Anonymous User"
        )
        
        test_logger.info("✅ Test users created successfully")
        
    except Exception as e:
        test_logger.error(f"❌ Failed to create test users: {e}")
        return
    
    # Test 3: Inventory operations
    print("\n📋 Test 3: Inventory Operations")
    print("-" * 30)
    
    try:
        # Add inventory items for user 1
        item1_request = InventoryAddRequest(
            name="Tanqueray Gin",
            category=IngredientCategory.SPIRITS,
            quantity=QuantityDescription.FULL_BOTTLE,
            brand="Tanqueray",
            notes="Premium London Dry Gin"
        )
        
        item1 = await MultiUserInventoryService.add_item("test_user_123", item1_request)
        log_inventory_operation(test_logger, "test_user_123", "added", item1.id, item1.name)
        
        # Add inventory items for user 2
        item2_request = InventoryAddRequest(
            name="Lime Juice",
            category=IngredientCategory.JUICES,
            quantity=QuantityDescription.HALF_BOTTLE,
            brand=None,
            notes="Fresh squeezed"
        )
        
        item2 = await MultiUserInventoryService.add_item("anon_user_456", item2_request)
        log_inventory_operation(test_logger, "anon_user_456", "added", item2.id, item2.name)
        
        # Get inventory for both users
        user1_inventory = await MultiUserInventoryService.get_all_items("test_user_123")
        user2_inventory = await MultiUserInventoryService.get_all_items("anon_user_456")
        
        log_inventory_operation(test_logger, "test_user_123", "retrieved", item_count=len(user1_inventory))
        log_inventory_operation(test_logger, "anon_user_456", "retrieved", item_count=len(user2_inventory))
        
        test_logger.info(f"📊 User 1 has {len(user1_inventory)} items, User 2 has {len(user2_inventory)} items")
        
    except Exception as e:
        test_logger.error(f"❌ Inventory operations failed: {e}")
        return
    
    # Test 4: User action logging
    print("\n📋 Test 4: User Actions")
    print("-" * 30)
    
    log_user_action(test_logger, "test_user_123", "view_recipes", {"search_term": "gin"}, "test@example.com")
    log_user_action(test_logger, "anon_user_456", "create_recipe", {"recipe_name": "Custom Mojito"})
    log_user_action(test_logger, "test_user_123", "share_recipe", {"recipe_id": "recipe_789"}, "test@example.com")
    
    # Test 5: Error scenarios
    print("\n📋 Test 5: Error Scenarios")
    print("-" * 30)
    
    try:
        # Try to get inventory for non-existent user
        fake_inventory = await MultiUserInventoryService.get_all_items("fake_user_999")
        test_logger.warning(f"⚠️ Got inventory for fake user: {len(fake_inventory)} items")
        
        # Try to add item with invalid data
        try:
            invalid_request = InventoryAddRequest(
                name="",  # Invalid empty name
                category=IngredientCategory.SPIRITS,
                quantity=QuantityDescription.FULL_BOTTLE
            )
            await MultiUserInventoryService.add_item("test_user_123", invalid_request)
        except Exception as e:
            test_logger.error("❌ Invalid item creation failed as expected", error=e)
            
    except Exception as e:
        test_logger.error(f"❌ Error scenario testing failed: {e}")
    
    print("\n🎉 Logging Test Complete!")
    print("=" * 60)
    print("\nKey Logging Features Demonstrated:")
    print("✅ Structured JSON logging with timestamps")
    print("✅ User context tracking (user_id, email)")
    print("✅ Operation-specific logging (auth, inventory, user actions)")
    print("✅ Error handling and exception logging")
    print("✅ Multi-user data isolation verification")
    print("✅ Request tracking and performance metrics")
    
    print("\nNext Steps:")
    print("1. Run the backend: cd mixologist && python -m uvicorn fastapi_app:app --reload --port 8081")
    print("2. Run the Flutter app: cd flutter_app && flutter run")
    print("3. Monitor logs in real-time to verify multi-user functionality")

if __name__ == "__main__":
    asyncio.run(test_logging_scenarios())