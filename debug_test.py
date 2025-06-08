#!/usr/bin/env python3
"""
Simple debug script to identify test issues without running pytest directly.
"""

import sys
import os
import traceback

# Add project root to path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__))))

def test_basic_imports():
    """Test basic imports to identify import issues."""
    print("Testing basic imports...")
    
    try:
        # Test environment setup
        os.environ.setdefault("OPENAI_API_KEY", "test-key-12345")
        print("✓ Environment setup complete")
        
        # Test basic module imports
        import mixologist
        print("✓ mixologist module imported")
        
        import mixologist.models
        print("✓ mixologist.models imported")
        
        from mixologist.models.get_recipe_params import GetRecipeParams, Ingredient
        print("✓ GetRecipeParams and Ingredient imported")
        
        # Test service imports
        import mixologist.services
        print("✓ mixologist.services imported")
        
        from mixologist.services.openai_service import Recipe, parse_recipe_arguments
        print("✓ Recipe and parse_recipe_arguments imported")
        
        print("All basic imports successful!")
        return True
        
    except Exception as e:
        print(f"✗ Import failed: {e}")
        traceback.print_exc()
        return False

def test_recipe_construction():
    """Test Recipe namedtuple construction."""
    print("\nTesting Recipe construction...")
    
    try:
        from mixologist.services.openai_service import Recipe
        
        # Test construction with all 24 fields
        recipe = Recipe(
            [], 0.2, [], False, [], "", "", "", "Test Cocktail",
            [], [], [], 0, 0, [], None, None, {}, [], [], [], "", "", []
        )
        
        print(f"✓ Recipe created successfully: {recipe.drink_name}")
        print(f"✓ Recipe has {len(recipe._fields)} fields")
        
        # Verify all expected fields exist
        expected_fields = [
            "ingredients", "alcohol_content", "steps", "rim", "garnish", "serving_glass", 
            "drink_image_description", "drink_history", "drink_name",
            "brand_recommendations", "ingredient_substitutions", "related_cocktails",
            "difficulty_rating", "preparation_time_minutes", "equipment_needed",
            "flavor_profile", "serving_size_base", "phonetic_pronunciations",
            "enhanced_steps", "suggested_variations", "food_pairings",
            "optimal_serving_temperature", "skill_level_recommendation", "drink_trivia"
        ]
        
        actual_fields = recipe._fields
        print(f"✓ Expected {len(expected_fields)} fields, got {len(actual_fields)}")
        
        if set(expected_fields) == set(actual_fields):
            print("✓ All fields match!")
        else:
            missing = set(expected_fields) - set(actual_fields)
            extra = set(actual_fields) - set(expected_fields)
            if missing:
                print(f"✗ Missing fields: {missing}")
            if extra:
                print(f"✗ Extra fields: {extra}")
        
        return True
        
    except Exception as e:
        print(f"✗ Recipe construction failed: {e}")
        traceback.print_exc()
        return False

def test_parse_recipe_arguments():
    """Test parse_recipe_arguments function."""
    print("\nTesting parse_recipe_arguments...")
    
    try:
        from mixologist.services.openai_service import parse_recipe_arguments
        
        # Test with simple dict
        test_data = {
            "drink_name": "Test Cocktail",
            "alcohol_content": 0.3,
            "ingredients": ["2 oz Gin"],
            "steps": ["Mix", "Serve"],
            "rim": False,
            "garnish": ["Lime"],
            "serving_glass": "Coupe",
            "drink_image_description": "Test description",
            "drink_history": "Test history"
        }
        
        recipe = parse_recipe_arguments(test_data)
        print(f"✓ parse_recipe_arguments successful: {recipe.drink_name}")
        
        # Test with JSON string
        import json
        json_str = json.dumps(test_data)
        recipe2 = parse_recipe_arguments(json_str)
        print(f"✓ JSON parsing successful: {recipe2.drink_name}")
        
        return True
        
    except Exception as e:
        print(f"✗ parse_recipe_arguments failed: {e}")
        traceback.print_exc()
        return False

def test_flask_mocking():
    """Test Flask mocking setup similar to tests."""
    print("\nTesting Flask mocking...")
    
    try:
        import types
        
        # Set up dummy Flask like in tests
        dummy_flask = types.SimpleNamespace(
            Flask=object,
            Blueprint=lambda *a, **k: types.SimpleNamespace(
                route=lambda *a, **k: (lambda f: f),
                errorhandler=lambda *a, **k: (lambda f: f),
                app_errorhandler=lambda *a, **k: (lambda f: f),
            ),
            request=None,
            render_template_string=lambda *a, **k: "",
            render_template=lambda *a, **k: "",
            Response=object,
            stream_with_context=lambda f: f,
            jsonify=lambda *a, **k: {},
        )
        sys.modules.setdefault("flask", dummy_flask)
        sys.modules.setdefault("flask_cors", types.SimpleNamespace(CORS=lambda *a, **k: None))
        
        print("✓ Flask mocking setup complete")
        
        # Now try importing bartender which uses Flask
        from mixologist.views.bartender import bp
        print("✓ Bartender blueprint imported successfully")
        
        return True
        
    except Exception as e:
        print(f"✗ Flask mocking failed: {e}")
        traceback.print_exc()
        return False

def main():
    """Run all debug tests."""
    print("=== Python Test Debug Script ===")
    
    tests = [
        test_basic_imports,
        test_recipe_construction,
        test_parse_recipe_arguments,
        test_flask_mocking,
    ]
    
    results = []
    for test in tests:
        try:
            result = test()
            results.append(result)
        except Exception as e:
            print(f"✗ Test {test.__name__} crashed: {e}")
            traceback.print_exc()
            results.append(False)
    
    print(f"\n=== Summary ===")
    print(f"Passed: {sum(results)}/{len(results)}")
    
    if all(results):
        print("✓ All debug tests passed! The issue might be with test execution environment.")
    else:
        print("✗ Some debug tests failed. Check the errors above.")
    
    return all(results)

if __name__ == "__main__":
    main()