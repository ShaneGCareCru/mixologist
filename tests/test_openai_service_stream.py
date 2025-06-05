import asyncio
import types
import pytest
import sys
import os

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

os.environ.setdefault("OPENAI_API_KEY", "test")

from mixologist.services import openai_service

# helper async generator for mocking
class FakeEvent:
    def __init__(self, type_, b64=None, index=0):
        self.type = type_
        self.partial_image_b64 = b64
        self.partial_image_index = index

async def fake_stream(events):
    for ev in events:
        yield ev

@pytest.mark.asyncio
async def test_generate_image_stream_yields_partial_images(monkeypatch):
    events = [
        FakeEvent("response.image_generation_call.partial_image", b64="AAA", index=1),
        FakeEvent("response.image_generation_call.partial_image", b64="BBB", index=2),
    ]

    async def fake_create(**kwargs):
        return fake_stream(events)

    monkeypatch.setattr(openai_service.async_client.responses, "create", fake_create)

    result = []
    async for chunk in openai_service.generate_image_stream(
        prompt="desc", drink_name="test", ingredients=[{"name": "gin", "quantity": "1"}], serving_glass="glass"
    ):
        result.append(chunk)

    assert result == ["AAA", "BBB"]

@pytest.mark.asyncio
async def test_generate_image_stream_ignores_other_events(monkeypatch):
    events = [
        FakeEvent("other"),
        FakeEvent("response.image_generation_call.partial_image", b64="CCC", index=1),
    ]
    async def fake_create(**kwargs):
        return fake_stream(events)

    monkeypatch.setattr(openai_service.async_client.responses, "create", fake_create)

    result = []
    async for chunk in openai_service.generate_image_stream("desc", "drink"):
        result.append(chunk)

    assert result == ["CCC"]

@pytest.mark.asyncio
async def test_generate_image_stream_propagates_errors(monkeypatch):
    class Boom(Exception):
        pass

    async def fake_create(**kwargs):
        raise Boom("fail")

    monkeypatch.setattr(openai_service.async_client.responses, "create", fake_create)

    with pytest.raises(Boom):
        async for _ in openai_service.generate_image_stream("desc", "drink"):
            pass


def test_parse_recipe_arguments_invalid_type():
    with pytest.raises(AttributeError):
        openai_service.parse_recipe_arguments(123)
