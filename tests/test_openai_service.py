import os
import sys
import json

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

os.environ.setdefault("OPENAI_API_KEY", "test")

from mixologist.services.openai_service import parse_recipe_arguments, Recipe


def test_parse_recipe_arguments_json():
    data = {
        "ingredients": ["2 oz gin", "1 oz tonic"],
        "alcohol_content": 0.5,
        "steps": ["Mix", "Serve"],
        "rim": False,
        "garnish": ["lime"],
        "serving_glass": "highball",
        "drink_image_description": "A nice gin and tonic",
        "drink_history": "famous",
        "drink_name": "Gin & Tonic"
    }
    json_str = json.dumps(data)
    recipe = parse_recipe_arguments(json_str)

    assert isinstance(recipe, Recipe)
    assert recipe.ingredients == data["ingredients"]
    assert recipe.alcohol_content == data["alcohol_content"]
    assert recipe.steps == data["steps"]
    assert recipe.rim == data["rim"]
    assert recipe.garnish == data["garnish"]
    assert recipe.serving_glass == data["serving_glass"]
    assert recipe.drink_image_description == data["drink_image_description"]
    assert recipe.drink_history == data["drink_history"]
    assert recipe.drink_name == data["drink_name"]
