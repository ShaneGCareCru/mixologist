import sys
import os
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))
import pytest
from unittest.mock import AsyncMock, patch, MagicMock, Mock
from httpx import AsyncClient, ASGITransport
from mixologist.fastapi_app import app
import openai
import httpx

# Test recipes for mocking
TEST_RECIPES = [
    {
        "drink_name": "Negroni",
        "canonical_name": "Negroni",
        "aliases": ["Count Negroni", "Negrooni"],
        "ingredients": ["1 oz Gin", "1 oz Campari", "1 oz Sweet Vermouth"],
        "instructions": "Stir with ice, strain into glass.",
        "image_url": "http://img/negroni.jpg",
        "id": 1,
    },
    {
        "drink_name": "Margarita",
        "canonical_name": "Margarita",
        "aliases": ["Marg", "Tequila Sour"],
        "ingredients": ["2 oz Tequila", "1 oz Lime", "1 oz Triple Sec"],
        "instructions": "Shake with ice, strain into glass.",
        "image_url": "http://img/margarita.jpg",
        "id": 2,
    },
    {
        "drink_name": "Paper Plane",
        "canonical_name": "Paper Plane",
        "aliases": ["Aviator", "Bitter Bird"],
        "ingredients": ["3/4 oz Bourbon", "3/4 oz Aperol", "3/4 oz Amaro Nonino", "3/4 oz Lemon"],
        "instructions": "Shake, strain, serve up.",
        "image_url": "http://img/paperplane.jpg",
        "id": 3,
    },
    {
        "drink_name": "Piña Colada",
        "canonical_name": "Piña Colada",
        "aliases": ["Pina Colada", "Colada"],
        "ingredients": ["2 oz Rum", "1 oz Coconut Cream", "1 oz Pineapple Juice"],
        "instructions": "Blend with ice, serve.",
        "image_url": "http://img/pinacolada.jpg",
        "id": 4,
    },
    {
        "drink_name": "Old Fashioned",
        "canonical_name": "Old Fashioned",
        "aliases": ["Old-Fashioned", "Whiskey Cocktail"],
        "ingredients": ["2 oz Whiskey", "Sugar", "Bitters"],
        "instructions": "Stir, strain, orange twist.",
        "image_url": "http://img/oldfashioned.jpg",
        "id": 5,
    },
]

@pytest.fixture(autouse=True)
def patch_services(monkeypatch):
    # Patch DB service methods
    db_service_path = "mixologist.database.service.DatabaseService"
    monkeypatch.setattr(f"{db_service_path}.get_all_recipes", AsyncMock(return_value=TEST_RECIPES))
    monkeypatch.setattr(f"{db_service_path}.get_recipe_by_cache_key", AsyncMock(side_effect=lambda key: next((r for r in TEST_RECIPES if r["drink_name"].replace(' ', '').lower() == key), None)))
    monkeypatch.setattr(f"{db_service_path}.save_recipe", AsyncMock(return_value=None))
    # Patch image service if needed (no-op for now)
    # Patch LLM prompt builder
    monkeypatch.setattr("mixologist.services.openai_service.build_llm_prompt_for_canonicalization", MagicMock(return_value="prompt"))
    # Patch LLM response parser
    monkeypatch.setattr("mixologist.services.openai_service.parse_llm_recipe_response", MagicMock(side_effect=lambda resp: resp))

@pytest.mark.asyncio
class TestRecipeNamesEndpoint:
    @pytest.fixture(autouse=True)
    def setup(self, monkeypatch):
        self.db_service_path = "mixologist.database.service.DatabaseService"

    @pytest.mark.asyncio
    async def test_recipe_names_normal(self, monkeypatch):
        mock_recipes = [
            {"canonical_name": "Negroni", "aliases": ["Count Negroni"]},
            {"canonical_name": "Caesar", "aliases": ["Bloody Caesar"]},
        ]
        mock_get_all = AsyncMock(return_value=mock_recipes)
        monkeypatch.setattr(f"{self.db_service_path}.get_all_recipes", mock_get_all)
        async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
            resp = await ac.get("/recipes/names")
            assert resp.status_code == 200
            data = resp.json()
            assert isinstance(data, list)
            assert data[0]["canonical_name"] == "Negroni"
            assert data[1]["aliases"] == ["Bloody Caesar"]

    @pytest.mark.asyncio
    async def test_recipe_names_empty(self, monkeypatch):
        mock_get_all = AsyncMock(return_value=[])
        monkeypatch.setattr(f"{self.db_service_path}.get_all_recipes", mock_get_all)
        async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
            resp = await ac.get("/recipes/names")
            assert resp.status_code == 200
            data = resp.json()
            assert data == []

    @pytest.mark.asyncio
    async def test_recipe_names_db_error(self, monkeypatch):
        mock_get_all = AsyncMock(side_effect=Exception("DB error"))
        monkeypatch.setattr(f"{self.db_service_path}.get_all_recipes", mock_get_all)
        async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
            resp = await ac.get("/recipes/names")
            assert resp.status_code == 500
            assert "Error getting recipe names" in resp.text 