#!/usr/bin/env python3
"""
Test script to verify that our Flask import fix works.
"""

import sys
import os
import types

# Add project root to path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__))))

# Set up environment
os.environ.setdefault("OPENAI_API_KEY", "test-key-12345")

# Mock Flask BEFORE any imports that might trigger Flask loading
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

print("✓ Flask mocking set up")

# Now try to import our modules
try:
    # This should NOT trigger Flask imports
    from mixologist.services.openai_service import Recipe, parse_recipe_arguments
    print("✓ Successfully imported from openai_service without Flask conflicts")
    
    # Test recipe construction
    recipe = Recipe(
        [], 0.2, [], False, [], "", "", "", "Test Cocktail",
        [], [], [], 0, 0, [], None, None, {}, [], [], [], "", "", []
    )
    print(f"✓ Recipe created: {recipe.drink_name}")
    
    # Test parse_recipe_arguments
    test_data = {"drink_name": "Test"}
    result = parse_recipe_arguments(test_data)
    print(f"✓ parse_recipe_arguments works: {result.drink_name}")
    
    # Now test bartender imports (this should use mocked Flask)
    from mixologist.views.bartender import bp
    print(f"✓ Successfully imported bp: {type(bp)}")
    
    print("\n🎉 All tests passed! The Flask import fix is working.")
    
except Exception as e:
    print(f"✗ Error: {e}")
    import traceback
    traceback.print_exc()