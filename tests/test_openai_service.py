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

def test_parse_recipe_arguments_dict():
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
    recipe = parse_recipe_arguments(data)

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


def test_parse_recipe_arguments_defaults():
    data = {"drink_name": "Mystery"}
    recipe = parse_recipe_arguments(data)

    assert recipe.ingredients == []
    assert recipe.alcohol_content == 0
    assert recipe.steps == []
    assert recipe.rim is False
    assert recipe.garnish == []
    assert recipe.serving_glass == ""
    assert recipe.drink_image_description == ""
    assert recipe.drink_history == ""
    assert recipe.drink_name == "Mystery"


import pytest

def test_parse_recipe_arguments_invalid_json():
    with pytest.raises(json.JSONDecodeError):
        parse_recipe_arguments("{bad json}")


from types import SimpleNamespace
import mixologist.services.openai_service as openai_service

def test_get_completion_from_messages(monkeypatch):
    def fake_create(model, messages, temperature, max_tokens, functions, function_call):
        arguments = {"drink_name": "Test Drink"}
        return SimpleNamespace(choices=[SimpleNamespace(message=SimpleNamespace(function_call=SimpleNamespace(arguments=arguments)))])

    monkeypatch.setattr(openai_service.client.chat.completions, "create", fake_create)

    sentinel = openai_service.Recipe([], 0, [], False, [], "", "", "", "Test Drink")
    captured = {}
    def fake_parse(args):
        captured['args'] = args
        return sentinel

    monkeypatch.setattr(openai_service, "parse_recipe_arguments", fake_parse)

    result = openai_service.get_completion_from_messages([{"role": "user", "content": "hi"}], model="test", temperature=0.1)

    assert result is sentinel
    assert captured['args'] == {"drink_name": "Test Drink"}

