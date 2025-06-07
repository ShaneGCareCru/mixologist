import os, sys

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))
os.environ.setdefault("OPENAI_API_KEY", "test")

import types
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

import asyncio
import json
import pytest
from mixologist.services import openai_service as svc


@pytest.mark.asyncio
async def test_recipe_cache_roundtrip(tmp_path, monkeypatch):
    key = "test_recipe"
    data = {"drink_name": "Test"}
    monkeypatch.setattr(svc, "RECIPE_CACHE_DIR", tmp_path)
    await svc.save_recipe_to_cache(key, data)
    loaded = await svc.get_cached_recipe(key)
    assert loaded == data


@pytest.mark.asyncio
async def test_image_cache_roundtrip(tmp_path, monkeypatch):
    key = "img123"
    data = "abc123"
    monkeypatch.setattr(svc, "IMAGE_CACHE_DIR", tmp_path)
    await svc.save_image_to_cache(key, data)
    loaded = await svc.get_cached_image(key)
    assert loaded == data


def test_generate_cache_key_stable():
    ingredients1 = [
        {"name": "Gin", "quantity": "2 oz"},
        {"name": "Tonic", "quantity": "1 oz"},
    ]
    ingredients2 = list(reversed(ingredients1))
    key1 = svc.generate_cache_key("prompt", "drink", ingredients1, "glass")
    key2 = svc.generate_cache_key("prompt", "drink", ingredients2, "glass")
    assert key1 == key2


def test_recipe_cache_key_normalization():
    assert svc.generate_recipe_cache_key("Negroni") == svc.generate_recipe_cache_key("  negroni ")


def test_parse_ingredient_name():
    raw = {"name": "Fresh Lemon Juice"}
    assert svc.parse_ingredient_name(raw) == "Lemon Juice"


def test_normalize_glass_name():
    assert svc.normalize_glass_name("Old Fashioned") == "old fashioned glass"


def test_generate_image_stream_no_client(monkeypatch):
    monkeypatch.setattr(svc, "async_client", None)
    with pytest.raises(Exception):
        asyncio.run(svc.generate_image_stream("prompt", "drink"))
