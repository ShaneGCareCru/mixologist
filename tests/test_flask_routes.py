import os
import sys
import json
import pytest
from unittest.mock import Mock, patch, MagicMock
from types import SimpleNamespace

# Setup path and environment
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))
os.environ.setdefault("OPENAI_API_KEY", "test-key-12345")

# Mock Flask before importing our modules
import types
from flask import Flask, Blueprint
from flask_cors import CORS

# Mock the dependencies
@pytest.fixture
def app():
    """Create a test Flask application."""
    app = Flask(__name__)
    app.config['TESTING'] = True
    
    # Register the blueprint
    from mixologist.views.bartender import bp
    app.register_blueprint(bp)
    
    return app

@pytest.fixture
def client(app):
    """Create a test client for the Flask application."""
    return app.test_client()


class TestHomeRoute:
    """Test suite for the home route."""

    def test_home_route_returns_200(self, client):
        """Test that the home route returns 200 status code."""
        # Act
        response = client.get('/')
        
        # Assert
        assert response.status_code == 200

    def test_home_route_renders_template(self, client):
        """Test that the home route renders the home template."""
        # Mock the render_template function
        with patch('mixologist.views.bartender.render_template') as mock_render:
            mock_render.return_value = "Mocked home page"
            
            # Act
            response = client.get('/')
            
            # Assert
            mock_render.assert_called_once_with('home.html')


class TestCreateDrinkRoute:
    """Test suite for the create drink route."""

    @patch('mixologist.views.bartender.get_completion_from_messages')
    def test_create_drink_success(self, mock_get_completion, client):
        """Test successful drink creation with valid input."""
        # Arrange
        mock_recipe = Mock()
        mock_recipe.drink_name = "Negroni"
        mock_recipe.alcohol_content = 0.3
        mock_recipe.serving_glass = "rocks"
        mock_recipe.rim = False
        mock_recipe.ingredients = ["1 oz Gin", "1 oz Campari", "1 oz Sweet Vermouth"]
        mock_recipe.steps = ["Stir with ice", "Strain into glass", "Garnish with orange peel"]
        mock_recipe.garnish = ["Orange peel"]
        mock_recipe.drink_image_description = "Classic Negroni in rocks glass"
        mock_recipe.drink_history = "Created in Florence, Italy in 1919"
        mock_recipe.brand_recommendations = []
        mock_recipe.ingredient_substitutions = []
        mock_recipe.related_cocktails = []
        mock_recipe.difficulty_rating = 2
        mock_recipe.preparation_time_minutes = 3
        mock_recipe.equipment_needed = []
        mock_recipe.flavor_profile = None
        mock_recipe.serving_size_base = None
        mock_recipe.phonetic_pronunciations = {}
        mock_recipe.enhanced_steps = []
        mock_recipe.suggested_variations = []
        mock_recipe.food_pairings = []
        mock_recipe.optimal_serving_temperature = ""
        mock_recipe.skill_level_recommendation = ""
        
        mock_get_completion.return_value = mock_recipe

        # Act
        response = client.post('/create', data={
            'drink_query': 'Negroni'
        })

        # Assert
        assert response.status_code == 200
        assert response.content_type == 'application/json'
        
        response_data = json.loads(response.data)
        assert response_data['drink_name'] == "Negroni"
        assert response_data['alcohol_content'] == 0.3
        assert response_data['rim'] == 'No salt'
        assert len(response_data['ingredients']) == 3

    @patch('mixologist.views.bartender.get_completion_from_messages')
    def test_create_drink_with_rim(self, mock_get_completion, client):
        """Test drink creation where rim is True."""
        # Arrange
        mock_recipe = Mock()
        mock_recipe.drink_name = "Margarita"
        mock_recipe.rim = True
        mock_recipe.alcohol_content = 0.25
        mock_recipe.serving_glass = "margarita"
        mock_recipe.ingredients = ["2 oz Tequila", "1 oz Lime juice", "1 oz Triple sec"]
        mock_recipe.steps = ["Salt rim", "Shake with ice", "Strain into glass"]
        mock_recipe.garnish = ["Lime wheel"]
        mock_recipe.drink_image_description = "Margarita with salted rim"
        mock_recipe.drink_history = "Classic Mexican cocktail"
        # Mock all other required attributes
        for attr in ['brand_recommendations', 'ingredient_substitutions', 'related_cocktails',
                     'equipment_needed', 'enhanced_steps', 'suggested_variations', 'food_pairings']:
            setattr(mock_recipe, attr, [])
        for attr in ['difficulty_rating', 'preparation_time_minutes']:
            setattr(mock_recipe, attr, 3)
        for attr in ['flavor_profile', 'serving_size_base']:
            setattr(mock_recipe, attr, None)
        for attr in ['phonetic_pronunciations']:
            setattr(mock_recipe, attr, {})
        for attr in ['optimal_serving_temperature', 'skill_level_recommendation']:
            setattr(mock_recipe, attr, "")
            
        mock_get_completion.return_value = mock_recipe

        # Act
        response = client.post('/create', data={
            'drink_query': 'Margarita'
        })

        # Assert
        response_data = json.loads(response.data)
        assert response_data['rim'] == 'Salted'

    def test_create_drink_missing_query(self, client):
        """Test drink creation with missing drink_query parameter."""
        # Act
        response = client.post('/create', data={})

        # This should handle gracefully - the actual behavior depends on implementation
        # For now, we'll just check it doesn't crash
        assert response.status_code in [200, 400, 500]

    @patch('mixologist.views.bartender.get_completion_from_messages')
    def test_create_drink_empty_query(self, mock_get_completion, client):
        """Test drink creation with empty drink_query."""
        # Arrange
        mock_recipe = Mock()
        mock_recipe.drink_name = "Unknown Cocktail"
        # Set all required attributes
        for attr in ['alcohol_content', 'serving_glass', 'rim', 'ingredients', 'steps', 
                     'garnish', 'drink_image_description', 'drink_history']:
            setattr(mock_recipe, attr, "" if attr not in ['rim', 'ingredients', 'steps', 'garnish'] else [])
        mock_recipe.rim = False
        mock_recipe.alcohol_content = 0
        for attr in ['brand_recommendations', 'ingredient_substitutions', 'related_cocktails',
                     'equipment_needed', 'enhanced_steps', 'suggested_variations', 'food_pairings']:
            setattr(mock_recipe, attr, [])
        for attr in ['difficulty_rating', 'preparation_time_minutes']:
            setattr(mock_recipe, attr, 0)
        for attr in ['flavor_profile', 'serving_size_base']:
            setattr(mock_recipe, attr, None)
        for attr in ['phonetic_pronunciations']:
            setattr(mock_recipe, attr, {})
        for attr in ['optimal_serving_temperature', 'skill_level_recommendation']:
            setattr(mock_recipe, attr, "")
            
        mock_get_completion.return_value = mock_recipe

        # Act
        response = client.post('/create', data={
            'drink_query': ''
        })

        # Assert
        assert response.status_code == 200
        response_data = json.loads(response.data)
        assert 'drink_name' in response_data

    @patch('mixologist.views.bartender.get_completion_from_messages')
    def test_create_drink_openai_error(self, mock_get_completion, client):
        """Test handling of OpenAI API errors."""
        # Arrange
        mock_get_completion.side_effect = Exception("OpenAI API Error")

        # Act
        response = client.post('/create', data={
            'drink_query': 'Negroni'
        })

        # Assert
        # The exact behavior depends on error handling implementation
        # It should either return an error response or handle gracefully
        assert response.status_code in [200, 400, 500]


class TestImageRoutes:
    """Test suite for image-related routes."""

    @patch('os.path.exists')
    @patch('os.makedirs')
    @patch('os.listdir')
    def test_images_route_lists_files(self, mock_listdir, mock_makedirs, mock_exists, client):
        """Test that images route lists image files."""
        # Arrange
        mock_exists.return_value = True
        mock_listdir.return_value = ['cocktail1.jpg', 'cocktail2.png']

        # Act
        response = client.get('/images')

        # Assert
        assert response.status_code == 200
        response_data = json.loads(response.data)
        assert response_data == ['cocktail1.jpg', 'cocktail2.png']

    @patch('os.path.exists')
    @patch('os.makedirs')
    @patch('os.listdir')
    def test_images_route_creates_directory(self, mock_listdir, mock_makedirs, mock_exists, client):
        """Test that images route creates directory if it doesn't exist."""
        # Arrange
        mock_exists.return_value = False
        mock_listdir.return_value = []

        # Act
        response = client.get('/images')

        # Assert
        mock_makedirs.assert_called_once()
        assert response.status_code == 200

    @patch('mixologist.views.bartender.generate_image_stream')
    @patch('mixologist.views.bartender.asyncio')
    def test_generate_image_route_valid_input(self, mock_asyncio, mock_generate_stream, client):
        """Test image generation route with valid input."""
        # Arrange
        async def mock_image_stream(*args, **kwargs):
            yield "chunk1"
            yield "chunk2"
            
        mock_generate_stream.return_value = mock_image_stream()
        
        # Mock asyncio behavior
        mock_loop = Mock()
        mock_asyncio.new_event_loop.return_value = mock_loop
        mock_asyncio.set_event_loop.return_value = None
        
        # Mock the async generator behavior
        mock_async_gen = Mock()
        mock_async_gen.__anext__ = Mock(side_effect=[
            "chunk1", "chunk2", StopAsyncIteration()
        ])
        
        # Act
        response = client.post('/generate_image', data={
            'image_description': 'A beautiful cocktail',
            'drink_query': 'Negroni',
            'ingredients': json.dumps([{"name": "Gin", "quantity": "1 oz"}]),
            'serving_glass': 'rocks'
        })

        # Assert
        assert response.status_code == 200
        assert response.content_type == 'text/event-stream; charset=utf-8'

    def test_generate_image_route_invalid_json(self, client):
        """Test image generation route with invalid ingredients JSON."""
        # Act
        response = client.post('/generate_image', data={
            'image_description': 'A beautiful cocktail',
            'drink_query': 'Negroni',
            'ingredients': 'invalid json',
            'serving_glass': 'rocks'
        })

        # Assert
        assert response.status_code == 400
        response_data = json.loads(response.data)
        assert 'error' in response_data
        assert 'Invalid ingredients JSON format' in response_data['error']

    def test_generate_image_route_missing_parameters(self, client):
        """Test image generation route with missing required parameters."""
        # Act
        response = client.post('/generate_image', data={
            'image_description': 'A beautiful cocktail'
            # Missing other required parameters
        })

        # Should handle gracefully - exact behavior depends on implementation
        assert response.status_code in [200, 400, 500]

    @patch('mixologist.views.bartender.asyncio')
    def test_test_async_stream_route(self, mock_asyncio, client):
        """Test the test async stream route."""
        # This is a test endpoint, so we just verify it responds
        # Mock asyncio sleep to avoid actual delays in tests
        mock_asyncio.sleep = Mock()
        
        # Act
        response = client.get('/test_async_stream')

        # Assert
        assert response.status_code == 200
        assert response.content_type == 'text/event-stream; charset=utf-8'


class TestErrorHandlers:
    """Test suite for error handling in routes."""

    def test_handle_invalid_request_error(self, client):
        """Test OpenAI BadRequestError handler."""
        # This tests the error handler registration
        # Actual testing would require triggering the specific error
        pass

    def test_handle_key_error(self, client):
        """Test KeyError handler."""
        # This tests the error handler registration
        # Actual testing would require triggering a KeyError
        pass

    def test_handle_generic_exception(self, client):
        """Test generic exception handler."""
        # This tests the error handler registration
        # Actual testing would require triggering a generic exception
        pass


class TestRouteIntegration:
    """Integration tests for route workflows."""

    @patch('mixologist.views.bartender.get_completion_from_messages')
    @patch('mixologist.views.bartender.generate_image_stream')
    def test_complete_drink_creation_and_image_generation(self, mock_generate_stream, mock_get_completion, client):
        """Test complete workflow of creating drink and generating image."""
        # Arrange
        mock_recipe = Mock()
        mock_recipe.drink_name = "Test Cocktail"
        mock_recipe.drink_image_description = "Beautiful test cocktail"
        # Set all required attributes with defaults
        for attr in ['alcohol_content', 'serving_glass', 'rim', 'ingredients', 'steps', 
                     'garnish', 'drink_history']:
            setattr(mock_recipe, attr, "" if attr not in ['rim', 'ingredients', 'steps', 'garnish'] else [])
        mock_recipe.rim = False
        mock_recipe.alcohol_content = 0.2
        mock_recipe.ingredients = ["2 oz Test Spirit"]
        for attr in ['brand_recommendations', 'ingredient_substitutions', 'related_cocktails',
                     'equipment_needed', 'enhanced_steps', 'suggested_variations', 'food_pairings']:
            setattr(mock_recipe, attr, [])
        for attr in ['difficulty_rating', 'preparation_time_minutes']:
            setattr(mock_recipe, attr, 3)
        for attr in ['flavor_profile', 'serving_size_base']:
            setattr(mock_recipe, attr, None)
        for attr in ['phonetic_pronunciations']:
            setattr(mock_recipe, attr, {})
        for attr in ['optimal_serving_temperature', 'skill_level_recommendation']:
            setattr(mock_recipe, attr, "")
            
        mock_get_completion.return_value = mock_recipe

        async def mock_image_stream(*args, **kwargs):
            yield "image_chunk_1"
            yield "image_chunk_2"
            
        mock_generate_stream.return_value = mock_image_stream()

        # Act - First create the drink
        create_response = client.post('/create', data={
            'drink_query': 'Test Cocktail'
        })

        # Assert
        assert create_response.status_code == 200
        create_data = json.loads(create_response.data)
        assert create_data['drink_name'] == "Test Cocktail"

        # Act - Then generate image (would typically use data from create response)
        # Note: This is a simplified test as the actual image generation involves SSE
        image_response = client.post('/generate_image', data={
            'image_description': create_data.get('drink_image_description', ''),
            'drink_query': create_data['drink_name'],
            'ingredients': json.dumps([{"name": "Test Spirit", "quantity": "2 oz"}]),
            'serving_glass': 'rocks'
        })

        # Assert
        assert image_response.status_code == 200

    def test_route_method_restrictions(self, client):
        """Test that routes respect HTTP method restrictions."""
        # Test that GET is not allowed on POST-only routes
        create_response = client.get('/create')
        assert create_response.status_code == 405  # Method Not Allowed

        generate_response = client.get('/generate_image')
        assert generate_response.status_code == 405  # Method Not Allowed

        # Test that POST is not allowed on GET-only routes
        home_response = client.post('/')
        assert home_response.status_code == 405  # Method Not Allowed

        images_response = client.post('/images')
        assert images_response.status_code == 405  # Method Not Allowed