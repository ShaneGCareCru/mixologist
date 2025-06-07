import os
import sys
import json
import pytest
import asyncio
from pathlib import Path
from unittest.mock import Mock, patch, AsyncMock
from types import SimpleNamespace

# Setup path and environment
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))
os.environ.setdefault("OPENAI_API_KEY", "test-key-12345")

# Mock Flask to avoid import issues in tests
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

from mixologist.services.openai_service import (
    parse_recipe_arguments,
    Recipe,
    extract_visual_moments,
    detect_primary_action,
    extract_context,
    extract_important_details,
    canonicalize_step_text,
    parse_ingredient_name,
    normalize_glass_name,
    generate_cache_key,
    generate_recipe_cache_key,
    get_completion_from_messages,
    save_recipe_to_cache,
    get_cached_recipe,
    save_image_to_cache,
    get_cached_image,
)


class TestRecipeArgumentParsing:
    """Test suite for recipe argument parsing functionality."""

    def test_parse_recipe_arguments_complete_json(self):
        """Test parsing a complete JSON recipe with all fields."""
        # Arrange
        complete_data = {
            "ingredients": ["2 oz Gin", "1 oz Dry Vermouth", "1 dash Orange Bitters"],
            "alcohol_content": 0.3,
            "steps": ["Stir with ice", "Strain into glass", "Garnish with lemon twist"],
            "rim": False,
            "garnish": ["Lemon twist"],
            "serving_glass": "Coupe",
            "drink_image_description": "Elegant martini in coupe glass with lemon twist",
            "drink_history": "Classic cocktail from the early 20th century",
            "drink_name": "Martini",
            "difficulty_rating": 3,
            "preparation_time_minutes": 5
        }
        json_str = json.dumps(complete_data)

        # Act
        recipe = parse_recipe_arguments(json_str)

        # Assert
        assert isinstance(recipe, Recipe)
        assert recipe.drink_name == "Martini"
        assert recipe.alcohol_content == 0.3
        assert len(recipe.ingredients) == 3
        assert recipe.ingredients[0] == "2 oz Gin"
        assert recipe.rim is False
        assert recipe.garnish == ["Lemon twist"]
        assert recipe.serving_glass == "Coupe"

    def test_parse_recipe_arguments_minimal_json(self):
        """Test parsing JSON with only required fields."""
        # Arrange
        minimal_data = {"drink_name": "Mystery Cocktail"}
        json_str = json.dumps(minimal_data)

        # Act
        recipe = parse_recipe_arguments(json_str)

        # Assert
        assert recipe.drink_name == "Mystery Cocktail"
        assert recipe.ingredients == []
        assert recipe.alcohol_content == 0
        assert recipe.steps == []
        assert recipe.rim is False
        assert recipe.garnish == []
        assert recipe.serving_glass == ""

    def test_parse_recipe_arguments_dict_input(self):
        """Test parsing when input is already a dictionary."""
        # Arrange
        data = {
            "drink_name": "Old Fashioned",
            "alcohol_content": 0.4,
            "ingredients": ["2 oz Bourbon", "1 sugar cube", "2 dashes Angostura bitters"],
            "rim": False
        }

        # Act
        recipe = parse_recipe_arguments(data)

        # Assert
        assert recipe.drink_name == "Old Fashioned"
        assert recipe.alcohol_content == 0.4
        assert len(recipe.ingredients) == 3

    def test_parse_recipe_arguments_invalid_json(self):
        """Test error handling for malformed JSON."""
        # Arrange
        invalid_json = '{"drink_name": "Broken", "invalid": json}'

        # Act & Assert
        with pytest.raises(json.JSONDecodeError):
            parse_recipe_arguments(invalid_json)

    def test_parse_recipe_arguments_empty_input(self):
        """Test parsing with empty or null input."""
        # Test empty string
        with pytest.raises((json.JSONDecodeError, ValueError)):
            parse_recipe_arguments("")

        # Test empty dict
        recipe = parse_recipe_arguments({})
        assert recipe.drink_name == ""
        assert recipe.ingredients == []


class TestVisualMomentExtraction:
    """Test suite for visual moment extraction from recipe steps."""

    def test_extract_visual_moments_shake_action(self):
        """Test extraction of shake action from step text."""
        # Arrange
        step_text = "Shake all ingredients vigorously with ice for 15 seconds"

        # Act
        result = extract_visual_moments(step_text)

        # Assert
        assert result["action"] == "shake"
        assert result["details"] == step_text.strip()
        assert isinstance(result["context"], dict)

    def test_extract_visual_moments_pour_action_with_context(self):
        """Test extraction of pour action with glass context."""
        # Arrange
        step_text = "Pour the mixture into a chilled coupe glass"

        # Act
        result = extract_visual_moments(step_text)

        # Assert
        assert result["action"] == "pour"
        assert "coupe" in result["context"].get("glass", "").lower()

    def test_detect_primary_action_various_verbs(self):
        """Test detection of different cocktail technique verbs."""
        # Test cases: (input_text, expected_action)
        test_cases = [
            ("Blend the strawberries with ice", "blend"),
            ("Muddle the mint leaves gently", "muddle"),
            ("Stir the ingredients slowly", "stir"),
            ("Strain through a fine mesh", "strain"),
            ("Garnish with a lime wheel", "garnish"),
            ("Unknown technique here", "other"),
        ]

        for input_text, expected_action in test_cases:
            # Act
            action = detect_primary_action(input_text)
            
            # Assert
            assert action == expected_action, f"Failed for input: {input_text}"

    def test_extract_context_glass_detection(self):
        """Test extraction of glass type from step text."""
        # Arrange
        test_cases = [
            ("Pour into a martini glass", "martini"),
            ("Serve in an old fashioned glass", "old fashioned"),
            ("Add to coupe", "coupe"),
            ("Pour liquid mixture", {}),  # No glass mentioned
        ]

        for step_text, expected_glass in test_cases:
            # Act
            context = extract_context(step_text)
            
            # Assert
            if expected_glass:
                assert expected_glass in context.get("glass", "").lower()
            else:
                assert "glass" not in context or context["glass"] == ""

    def test_extract_important_details_preserves_text(self):
        """Test that important details extraction preserves original text."""
        # Arrange
        original_text = "  Shake vigorously with ice for 10-15 seconds  "

        # Act
        details = extract_important_details(original_text)

        # Assert
        assert details == "Shake vigorously with ice for 10-15 seconds"
        assert details == original_text.strip()


class TestCacheUtilities:
    """Test suite for caching functionality."""

    def test_generate_cache_key_consistency(self):
        """Test that cache keys are generated consistently."""
        # Arrange
        ingredients1 = [{"name": "Gin", "quantity": "2 oz"}, {"name": "Vermouth", "quantity": "1 oz"}]
        ingredients2 = [{"name": "Vermouth", "quantity": "1 oz"}, {"name": "Gin", "quantity": "2 oz"}]
        prompt = "Classic martini recipe"
        drink_name = "Martini"
        glass = "coupe"

        # Act
        key1 = generate_cache_key(prompt, drink_name, ingredients1, glass)
        key2 = generate_cache_key(prompt, drink_name, ingredients2, glass)

        # Assert
        assert key1 == key2, "Cache keys should be identical regardless of ingredient order"
        assert len(key1) > 0
        assert isinstance(key1, str)

    def test_generate_recipe_cache_key_normalization(self):
        """Test recipe cache key normalization."""
        # Test cases: (input, expected_normalized)
        test_cases = [
            ("Negroni", "negroni"),
            ("  Old Fashioned  ", "old fashioned"),
            ("MOSCOW MULE", "moscow mule"),
            ("Piña Colada", "piña colada"),
        ]

        for input_name, expected in test_cases:
            # Act
            key1 = generate_recipe_cache_key(input_name)
            key2 = generate_recipe_cache_key(expected)
            
            # Assert
            assert key1 == key2, f"Failed normalization for: {input_name}"

    @pytest.mark.asyncio
    async def test_recipe_cache_roundtrip(self, tmp_path):
        """Test saving and retrieving recipe data from cache."""
        # Arrange
        cache_key = "test_recipe_key"
        recipe_data = {
            "drink_name": "Test Cocktail",
            "ingredients": ["2 oz Test Spirit"],
            "steps": ["Mix and serve"]
        }
        
        # Mock the cache directory
        with patch('mixologist.services.openai_service.RECIPE_CACHE_DIR', tmp_path):
            # Act
            await save_recipe_to_cache(cache_key, recipe_data)
            retrieved_data = await get_cached_recipe(cache_key)
            
            # Assert
            assert retrieved_data == recipe_data

    @pytest.mark.asyncio
    async def test_image_cache_roundtrip(self, tmp_path):
        """Test saving and retrieving image data from cache."""
        # Arrange
        cache_key = "test_image_key"
        image_data = "base64encodedimagedata123"
        
        # Mock the cache directory
        with patch('mixologist.services.openai_service.IMAGE_CACHE_DIR', tmp_path):
            # Act
            await save_image_to_cache(cache_key, image_data)
            retrieved_data = await get_cached_image(cache_key)
            
            # Assert
            assert retrieved_data == image_data

    @pytest.mark.asyncio
    async def test_cache_miss_returns_none(self, tmp_path):
        """Test that cache miss returns None."""
        # Arrange
        non_existent_key = "does_not_exist"
        
        # Mock the cache directories
        with patch('mixologist.services.openai_service.RECIPE_CACHE_DIR', tmp_path), \
             patch('mixologist.services.openai_service.IMAGE_CACHE_DIR', tmp_path):
            
            # Act
            recipe_result = await get_cached_recipe(non_existent_key)
            image_result = await get_cached_image(non_existent_key)
            
            # Assert
            assert recipe_result is None
            assert image_result is None


class TestDataNormalization:
    """Test suite for data normalization functions."""

    def test_parse_ingredient_name_removes_fresh_prefix(self):
        """Test ingredient name parsing removes 'Fresh' prefix."""
        # Test cases
        test_cases = [
            ({"name": "Fresh Lemon Juice"}, "Lemon Juice"),
            ({"name": "Fresh Lime Juice"}, "Lime Juice"),
            ({"name": "Regular Gin"}, "Regular Gin"),  # No change
            ({"name": "fresh mint"}, "mint"),  # Case insensitive
        ]

        for input_ingredient, expected_name in test_cases:
            # Act
            result = parse_ingredient_name(input_ingredient)
            
            # Assert
            assert result == expected_name

    def test_normalize_glass_name_adds_glass_suffix(self):
        """Test glass name normalization adds 'glass' suffix."""
        # Test cases
        test_cases = [
            ("Coupe", "coupe glass"),
            ("Old Fashioned", "old fashioned glass"),
            ("martini glass", "martini glass"),  # Already has glass
            ("HIGHBALL", "highball glass"),  # Case conversion
        ]

        for input_glass, expected_output in test_cases:
            # Act
            result = normalize_glass_name(input_glass)
            
            # Assert
            assert result == expected_output


class TestOpenAIIntegration:
    """Test suite for OpenAI API integration."""

    def test_get_completion_from_messages_success(self):
        """Test successful OpenAI API completion."""
        # Arrange
        mock_response = SimpleNamespace(
            choices=[
                SimpleNamespace(
                    message=SimpleNamespace(
                        function_call=SimpleNamespace(
                            arguments='{"drink_name": "Test Cocktail", "alcohol_content": 0.2}'
                        )
                    )
                )
            ]
        )

        expected_recipe = Recipe(
            [], 0.2, [], False, [], "", "", "", "Test Cocktail",
            [], [], [], 0, 0, [], None, None, {}, [], [], [], "", "", []
        )

        with patch('mixologist.services.openai_service.client.chat.completions.create', return_value=mock_response), \
             patch('mixologist.services.openai_service.parse_recipe_arguments', return_value=expected_recipe), \
             patch.object(type(expected_recipe), 'model_json_schema', classmethod(lambda cls: {})):

            messages = [{"role": "user", "content": "Make me a cocktail"}]
            
            # Act
            result = get_completion_from_messages(messages)
            
            # Assert
            assert result == expected_recipe
            assert result.drink_name == "Test Cocktail"

    def test_get_completion_from_messages_api_error(self):
        """Test handling of OpenAI API errors."""
        # Arrange
        with patch('mixologist.services.openai_service.client.chat.completions.create', 
                   side_effect=Exception("API Error")):
            
            messages = [{"role": "user", "content": "Make me a cocktail"}]
            
            # Act & Assert
            with pytest.raises(Exception) as exc_info:
                get_completion_from_messages(messages)
            
            assert "API Error" in str(exc_info.value)


class TestStepCanonicalization:
    """Test suite for step canonicalization functionality."""

    def test_canonicalize_step_common_patterns(self):
        """Test canonicalization of common cocktail preparation steps."""
        # Test cases: (input_step, expected_canonical_form)
        test_cases = [
            ("Salt the rim of the glass", "salt rim glass"),
            ("Salted the rim carefully", "salt rim glass"),
            ("Strain the mixture into a coupe glass", "strain into glass"),
            ("Shake vigorously with ice", "shake with ice"),
            ("Stir ingredients gently", "stir ingredients"),
            ("Unknown step here", "unknown step here"),  # No pattern match
        ]

        for input_step, expected_canonical in test_cases:
            # Act
            result = canonicalize_step_text(input_step)
            
            # Assert
            assert result == expected_canonical, f"Failed for: {input_step}"

    def test_canonicalize_step_case_insensitive(self):
        """Test that canonicalization is case insensitive."""
        # Arrange
        variations = [
            "SHAKE WITH ICE",
            "shake with ice",
            "Shake With Ice",
            "sHaKe WiTh IcE"
        ]

        # Act & Assert
        canonical_results = [canonicalize_step_text(step) for step in variations]
        assert all(result == canonical_results[0] for result in canonical_results)


class TestErrorHandling:
    """Test suite for error handling scenarios."""

    def test_parse_recipe_arguments_handles_missing_fields_gracefully(self):
        """Test that missing fields are handled with appropriate defaults."""
        # Arrange
        partial_data = {
            "drink_name": "Incomplete Recipe",
            "alcohol_content": 0.1
            # Missing most fields
        }

        # Act
        recipe = parse_recipe_arguments(partial_data)

        # Assert
        assert recipe.drink_name == "Incomplete Recipe"
        assert recipe.alcohol_content == 0.1
        assert recipe.ingredients == []  # Default value
        assert recipe.steps == []  # Default value
        assert recipe.garnish == []  # Default value

    def test_extract_visual_moments_handles_empty_input(self):
        """Test visual moment extraction with empty or None input."""
        # Test cases
        test_cases = ["", "   ", None]

        for input_step in test_cases:
            # Act
            if input_step is None:
                with pytest.raises((AttributeError, TypeError)):
                    extract_visual_moments(input_step)
            else:
                result = extract_visual_moments(input_step)
                
                # Assert
                assert result["action"] == "other"  # Default for unrecognized
                assert isinstance(result["context"], dict)

    @pytest.mark.asyncio
    async def test_cache_operations_handle_file_permissions(self, tmp_path):
        """Test cache operations handle file permission errors gracefully."""
        # Create a read-only directory
        read_only_dir = tmp_path / "readonly"
        read_only_dir.mkdir()
        read_only_dir.chmod(0o444)  # Read-only

        with patch('mixologist.services.openai_service.RECIPE_CACHE_DIR', read_only_dir):
            # Act & Assert - Should handle permission error gracefully
            try:
                await save_recipe_to_cache("test", {"data": "test"})
            except PermissionError:
                # This is expected behavior
                pass
            except Exception as e:
                # Should not raise other types of exceptions
                pytest.fail(f"Unexpected exception type: {type(e)}")


# Integration tests would go in a separate file
class TestIntegrationScenarios:
    """Integration test scenarios for complete workflows."""

    @pytest.mark.asyncio
    async def test_complete_recipe_processing_pipeline(self):
        """Test complete pipeline from user input to cached recipe."""
        # This would test the entire flow but requires more complex mocking
        # Left as placeholder for actual integration testing
        pass

    def test_error_propagation_through_layers(self):
        """Test that errors propagate correctly through service layers."""
        # Placeholder for testing error handling across the application stack
        pass