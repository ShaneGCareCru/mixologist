import os
import sys
import pytest
from pydantic import ValidationError
from typing import List

# Setup path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from mixologist.models.get_recipe_params import (
    Ingredient,
    BrandRecommendation,
    IngredientSubstitution,
    Equipment,
    FlavorProfile,
    ServingSizeBase,
    RecipeVariation,
    EnhancedStep,
    TriviaFact,
    GetRecipeParams
)


class TestIngredientModel:
    """Test suite for the Ingredient model."""

    def test_ingredient_creation_valid_data(self):
        """Test creating an ingredient with valid data."""
        # Arrange & Act
        ingredient = Ingredient(
            name="Gin",
            quantity="2 oz"
        )

        # Assert
        assert ingredient.name == "Gin"
        assert ingredient.quantity == "2 oz"

    def test_ingredient_creation_missing_required_fields(self):
        """Test ingredient creation fails with missing required fields."""
        # Test missing name
        with pytest.raises(ValidationError) as exc_info:
            Ingredient(quantity="2 oz")
        
        assert "name" in str(exc_info.value)

        # Test missing quantity
        with pytest.raises(ValidationError) as exc_info:
            Ingredient(name="Gin")
        
        assert "quantity" in str(exc_info.value)

    def test_ingredient_creation_empty_strings(self):
        """Test ingredient creation with empty strings."""
        # Act & Assert
        ingredient = Ingredient(name="", quantity="")
        assert ingredient.name == ""
        assert ingredient.quantity == ""

    def test_ingredient_type_validation(self):
        """Test that ingredient fields must be strings."""
        # Test non-string name
        with pytest.raises(ValidationError):
            Ingredient(name=123, quantity="2 oz")

        # Test non-string quantity
        with pytest.raises(ValidationError):
            Ingredient(name="Gin", quantity=2)


class TestBrandRecommendationModel:
    """Test suite for the BrandRecommendation model."""

    def test_brand_recommendation_creation_valid(self):
        """Test creating brand recommendation with valid data."""
        # Arrange & Act
        brand_rec = BrandRecommendation(
            ingredient="Gin",
            brands=["Tanqueray", "Hendrick's", "Bombay Sapphire"]
        )

        # Assert
        assert brand_rec.ingredient == "Gin"
        assert len(brand_rec.brands) == 3
        assert "Tanqueray" in brand_rec.brands

    def test_brand_recommendation_empty_brands_list(self):
        """Test brand recommendation with empty brands list."""
        # Act
        brand_rec = BrandRecommendation(
            ingredient="Gin",
            brands=[]
        )

        # Assert
        assert brand_rec.ingredient == "Gin"
        assert brand_rec.brands == []

    def test_brand_recommendation_missing_required_fields(self):
        """Test brand recommendation creation fails with missing fields."""
        # Test missing ingredient
        with pytest.raises(ValidationError):
            BrandRecommendation(brands=["Tanqueray"])

        # Test missing brands
        with pytest.raises(ValidationError):
            BrandRecommendation(ingredient="Gin")


class TestIngredientSubstitutionModel:
    """Test suite for the IngredientSubstitution model."""

    def test_ingredient_substitution_creation_valid(self):
        """Test creating ingredient substitution with valid data."""
        # Arrange & Act
        substitution = IngredientSubstitution(
            original="Sweet Vermouth",
            alternatives=["Dry Vermouth", "Port Wine", "Sherry"]
        )

        # Assert
        assert substitution.original == "Sweet Vermouth"
        assert len(substitution.alternatives) == 3
        assert "Dry Vermouth" in substitution.alternatives

    def test_ingredient_substitution_single_alternative(self):
        """Test substitution with single alternative."""
        # Act
        substitution = IngredientSubstitution(
            original="Campari",
            alternatives=["Aperol"]
        )

        # Assert
        assert substitution.original == "Campari"
        assert substitution.alternatives == ["Aperol"]

    def test_ingredient_substitution_empty_alternatives(self):
        """Test substitution with empty alternatives list."""
        # Act
        substitution = IngredientSubstitution(
            original="Unique Ingredient",
            alternatives=[]
        )

        # Assert
        assert substitution.alternatives == []


class TestEquipmentModel:
    """Test suite for the Equipment model."""

    def test_equipment_creation_essential_with_no_alternative(self):
        """Test creating essential equipment with no alternative."""
        # Arrange & Act
        equipment = Equipment(
            item="Cocktail Shaker",
            essential=True
        )

        # Assert
        assert equipment.item == "Cocktail Shaker"
        assert equipment.essential is True
        assert equipment.alternative is None

    def test_equipment_creation_non_essential_with_alternative(self):
        """Test creating non-essential equipment with alternative."""
        # Arrange & Act
        equipment = Equipment(
            item="Jigger",
            essential=False,
            alternative="Measuring spoons"
        )

        # Assert
        assert equipment.item == "Jigger"
        assert equipment.essential is False
        assert equipment.alternative == "Measuring spoons"

    def test_equipment_essential_field_type_validation(self):
        """Test that essential field must be boolean."""
        # Test invalid essential field type
        with pytest.raises(ValidationError):
            Equipment(item="Shaker", essential="yes")

    def test_equipment_missing_required_fields(self):
        """Test equipment creation fails with missing required fields."""
        # Test missing item
        with pytest.raises(ValidationError):
            Equipment(essential=True)

        # Test missing essential
        with pytest.raises(ValidationError):
            Equipment(item="Shaker")


class TestFlavorProfileModel:
    """Test suite for the FlavorProfile model."""

    def test_flavor_profile_creation_complete(self):
        """Test creating complete flavor profile."""
        # Arrange & Act
        profile = FlavorProfile(
            primary_flavors=["Bitter", "Herbal"],
            secondary_notes=["Citrus", "Floral"],
            mouthfeel="Medium-bodied with slight astringency",
            finish="Long and complex",
            balance="Well-balanced between bitter and sweet"
        )

        # Assert
        assert len(profile.primary_flavors) == 2
        assert "Bitter" in profile.primary_flavors
        assert len(profile.secondary_notes) == 2
        assert profile.mouthfeel == "Medium-bodied with slight astringency"
        assert profile.finish == "Long and complex"
        assert profile.balance == "Well-balanced between bitter and sweet"

    def test_flavor_profile_empty_lists(self):
        """Test flavor profile with empty flavor lists."""
        # Act
        profile = FlavorProfile(
            primary_flavors=[],
            secondary_notes=[],
            mouthfeel="Light",
            finish="Short",
            balance="Balanced"
        )

        # Assert
        assert profile.primary_flavors == []
        assert profile.secondary_notes == []

    def test_flavor_profile_missing_required_fields(self):
        """Test flavor profile creation fails with missing required fields."""
        # Test missing primary_flavors
        with pytest.raises(ValidationError):
            FlavorProfile(
                secondary_notes=["Citrus"],
                mouthfeel="Light",
                finish="Short",
                balance="Balanced"
            )


class TestServingSizeBaseModel:
    """Test suite for the ServingSizeBase model."""

    def test_serving_size_base_with_defaults(self):
        """Test serving size base uses default values correctly."""
        # Act
        serving_size = ServingSizeBase()

        # Assert
        assert serving_size.default_servings == 1
        assert serving_size.scalable_ingredients is True
        assert serving_size.max_recommended_batch == 8
        assert serving_size.batch_preparation_notes == ""

    def test_serving_size_base_custom_values(self):
        """Test serving size base with custom values."""
        # Act
        serving_size = ServingSizeBase(
            default_servings=2,
            scalable_ingredients=False,
            max_recommended_batch=4,
            batch_preparation_notes="Best made individually"
        )

        # Assert
        assert serving_size.default_servings == 2
        assert serving_size.scalable_ingredients is False
        assert serving_size.max_recommended_batch == 4
        assert serving_size.batch_preparation_notes == "Best made individually"

    def test_serving_size_base_type_validation(self):
        """Test type validation for serving size fields."""
        # Test invalid default_servings type
        with pytest.raises(ValidationError):
            ServingSizeBase(default_servings="two")

        # Test invalid scalable_ingredients type
        with pytest.raises(ValidationError):
            ServingSizeBase(scalable_ingredients="yes")

        # Test invalid max_recommended_batch type
        with pytest.raises(ValidationError):
            ServingSizeBase(max_recommended_batch="many")


class TestRecipeVariationModel:
    """Test suite for the RecipeVariation model."""

    def test_recipe_variation_creation_valid(self):
        """Test creating recipe variation with valid data."""
        # Arrange & Act
        variation = RecipeVariation(
            name="Negroni Sbagliato",
            changes=["Replace gin with prosecco", "Add orange slice"],
            description="A lighter, sparkling version of the classic Negroni"
        )

        # Assert
        assert variation.name == "Negroni Sbagliato"
        assert len(variation.changes) == 2
        assert "Replace gin with prosecco" in variation.changes
        assert "lighter, sparkling" in variation.description

    def test_recipe_variation_empty_changes(self):
        """Test recipe variation with empty changes list."""
        # Act
        variation = RecipeVariation(
            name="Simple Variation",
            changes=[],
            description="No changes needed"
        )

        # Assert
        assert variation.changes == []

    def test_recipe_variation_missing_required_fields(self):
        """Test recipe variation creation fails with missing required fields."""
        # Test missing name
        with pytest.raises(ValidationError):
            RecipeVariation(
                changes=["Add lime"],
                description="Test variation"
            )


class TestEnhancedStepModel:
    """Test suite for the EnhancedStep model."""

    def test_enhanced_step_creation_complete(self):
        """Test creating enhanced step with all fields."""
        # Arrange & Act
        step = EnhancedStep(
            step_number=1,
            action="Shake vigorously",
            technique_detail="Use a Boston shaker with 12-15 ice cubes",
            visual_cue="Ice should sound crisp and sharp",
            common_mistakes=["Not shaking long enough", "Using too little ice"],
            timing_guidance="Shake for 10-15 seconds until well chilled"
        )

        # Assert
        assert step.step_number == 1
        assert step.action == "Shake vigorously"
        assert "Boston shaker" in step.technique_detail
        assert "crisp and sharp" in step.visual_cue
        assert len(step.common_mistakes) == 2
        assert "10-15 seconds" in step.timing_guidance

    def test_enhanced_step_creation_minimal(self):
        """Test creating enhanced step with only required fields."""
        # Act
        step = EnhancedStep(
            step_number=2,
            action="Strain into glass"
        )

        # Assert
        assert step.step_number == 2
        assert step.action == "Strain into glass"
        assert step.technique_detail == ""
        assert step.visual_cue == ""
        assert step.common_mistakes == []
        assert step.timing_guidance == ""

    def test_enhanced_step_type_validation(self):
        """Test type validation for enhanced step fields."""
        # Test invalid step_number type
        with pytest.raises(ValidationError):
            EnhancedStep(step_number="first", action="Shake")

        # Test missing required fields
        with pytest.raises(ValidationError):
            EnhancedStep(step_number=1)  # Missing action


class TestTriviaFactModel:
    """Test suite for the TriviaFact model."""

    def test_trivia_fact_creation_complete(self):
        """Test creating trivia fact with all fields."""
        # Arrange & Act
        trivia = TriviaFact(
            fact="The Negroni was invented in 1919 in Florence, Italy",
            category="history",
            source_period="1919"
        )

        # Assert
        assert "1919" in trivia.fact
        assert trivia.category == "history"
        assert trivia.source_period == "1919"

    def test_trivia_fact_creation_minimal(self):
        """Test creating trivia fact with only required fields."""
        # Act
        trivia = TriviaFact(
            fact="Gin is made from juniper berries",
            category="ingredients"
        )

        # Assert
        assert trivia.fact == "Gin is made from juniper berries"
        assert trivia.category == "ingredients"
        assert trivia.source_period == ""

    def test_trivia_fact_missing_required_fields(self):
        """Test trivia fact creation fails with missing required fields."""
        # Test missing fact
        with pytest.raises(ValidationError):
            TriviaFact(category="history")

        # Test missing category
        with pytest.raises(ValidationError):
            TriviaFact(fact="Some interesting fact")


class TestGetRecipeParamsModel:
    """Test suite for the complete GetRecipeParams model."""

    def test_get_recipe_params_creation_minimal(self):
        """Test creating GetRecipeParams with only required fields."""
        # Arrange & Act
        params = GetRecipeParams(
            ingredients=[
                Ingredient(name="Gin", quantity="2 oz"),
                Ingredient(name="Dry Vermouth", quantity="0.5 oz")
            ],
            alcohol_content=0.3,
            steps=["Stir with ice", "Strain into chilled glass"],
            rim=False,
            garnish=["Lemon twist"],
            serving_glass="Martini glass",
            drink_image_description="Classic martini in chilled glass",
            drink_history="Classic cocktail from the early 1900s",
            drink_name="Dry Martini"
        )

        # Assert
        assert params.drink_name == "Dry Martini"
        assert len(params.ingredients) == 2
        assert params.alcohol_content == 0.3
        assert len(params.steps) == 2
        assert params.rim is False
        assert params.garnish == ["Lemon twist"]
        assert params.serving_glass == "Martini glass"

        # Check default values
        assert params.difficulty_rating == 3
        assert params.preparation_time_minutes == 5
        assert params.brand_recommendations == []
        assert params.ingredient_substitutions == []
        assert params.related_cocktails == []

    def test_get_recipe_params_creation_complete(self):
        """Test creating GetRecipeParams with all fields."""
        # Arrange
        ingredients = [
            Ingredient(name="Gin", quantity="2 oz"),
            Ingredient(name="Campari", quantity="1 oz"),
            Ingredient(name="Sweet Vermouth", quantity="1 oz")
        ]
        
        brand_recommendations = [
            BrandRecommendation(ingredient="Gin", brands=["Tanqueray", "Hendrick's"])
        ]
        
        ingredient_substitutions = [
            IngredientSubstitution(original="Campari", alternatives=["Aperol"])
        ]
        
        equipment_needed = [
            Equipment(item="Mixing glass", essential=True),
            Equipment(item="Bar spoon", essential=False, alternative="Regular spoon")
        ]
        
        flavor_profile = FlavorProfile(
            primary_flavors=["Bitter", "Herbal"],
            secondary_notes=["Citrus"],
            mouthfeel="Medium-bodied",
            finish="Long and bitter",
            balance="Well-balanced"
        )
        
        enhanced_steps = [
            EnhancedStep(step_number=1, action="Stir ingredients with ice")
        ]
        
        suggested_variations = [
            RecipeVariation(
                name="Negroni Sbagliato",
                changes=["Replace gin with prosecco"],
                description="Sparkling version"
            )
        ]
        
        drink_trivia = [
            TriviaFact(
                fact="Created in Florence in 1919",
                category="history",
                source_period="1919"
            )
        ]

        # Act
        params = GetRecipeParams(
            ingredients=ingredients,
            alcohol_content=0.35,
            steps=["Stir with ice", "Strain into rocks glass", "Garnish with orange peel"],
            rim=False,
            garnish=["Orange peel"],
            serving_glass="Rocks glass",
            drink_image_description="Classic Negroni in rocks glass with orange peel",
            drink_history="Created by Count Camillo Negroni in 1919",
            drink_name="Negroni",
            brand_recommendations=brand_recommendations,
            ingredient_substitutions=ingredient_substitutions,
            related_cocktails=["Americano", "Boulevardier", "Sbagliato"],
            difficulty_rating=2,
            preparation_time_minutes=3,
            equipment_needed=equipment_needed,
            flavor_profile=flavor_profile,
            phonetic_pronunciations={"Negroni": "neh-GROH-nee"},
            enhanced_steps=enhanced_steps,
            suggested_variations=suggested_variations,
            food_pairings=["Cheese", "Olives", "Charcuterie"],
            optimal_serving_temperature="Chilled",
            skill_level_recommendation="Beginner",
            drink_trivia=drink_trivia
        )

        # Assert
        assert params.drink_name == "Negroni"
        assert len(params.ingredients) == 3
        assert params.difficulty_rating == 2
        assert len(params.brand_recommendations) == 1
        assert len(params.ingredient_substitutions) == 1
        assert len(params.related_cocktails) == 3
        assert params.flavor_profile is not None
        assert len(params.enhanced_steps) == 1
        assert len(params.suggested_variations) == 1
        assert "Negroni" in params.phonetic_pronunciations
        assert len(params.drink_trivia) == 1

    def test_get_recipe_params_missing_required_fields(self):
        """Test GetRecipeParams creation fails with missing required fields."""
        # Test missing ingredients
        with pytest.raises(ValidationError):
            GetRecipeParams(
                alcohol_content=0.3,
                steps=["Stir"],
                rim=False,
                garnish=[],
                serving_glass="Glass",
                drink_image_description="Description",
                drink_history="History",
                drink_name="Drink"
            )

        # Test missing drink_name
        with pytest.raises(ValidationError):
            GetRecipeParams(
                ingredients=[Ingredient(name="Test", quantity="1 oz")],
                alcohol_content=0.3,
                steps=["Stir"],
                rim=False,
                garnish=[],
                serving_glass="Glass",
                drink_image_description="Description",
                drink_history="History"
                # Missing drink_name
            )

    def test_get_recipe_params_type_validation(self):
        """Test type validation for GetRecipeParams fields."""
        # Test invalid alcohol_content type
        with pytest.raises(ValidationError):
            GetRecipeParams(
                ingredients=[Ingredient(name="Test", quantity="1 oz")],
                alcohol_content="high",  # Should be float
                steps=["Stir"],
                rim=False,
                garnish=[],
                serving_glass="Glass",
                drink_image_description="Description",
                drink_history="History",
                drink_name="Test Drink"
            )

        # Test invalid rim type
        with pytest.raises(ValidationError):
            GetRecipeParams(
                ingredients=[Ingredient(name="Test", quantity="1 oz")],
                alcohol_content=0.3,
                steps=["Stir"],
                rim="yes",  # Should be bool
                garnish=[],
                serving_glass="Glass",
                drink_image_description="Description",
                drink_history="History",
                drink_name="Test Drink"
            )

    def test_get_recipe_params_nested_model_validation(self):
        """Test that nested models are properly validated."""
        # Test with invalid ingredient
        with pytest.raises(ValidationError):
            GetRecipeParams(
                ingredients=[{"invalid": "ingredient"}],  # Should be Ingredient objects
                alcohol_content=0.3,
                steps=["Stir"],
                rim=False,
                garnish=[],
                serving_glass="Glass",
                drink_image_description="Description",
                drink_history="History",
                drink_name="Test Drink"
            )

        # Test with invalid equipment
        with pytest.raises(ValidationError):
            GetRecipeParams(
                ingredients=[Ingredient(name="Test", quantity="1 oz")],
                alcohol_content=0.3,
                steps=["Stir"],
                rim=False,
                garnish=[],
                serving_glass="Glass",
                drink_image_description="Description",
                drink_history="History",
                drink_name="Test Drink",
                equipment_needed=[{"invalid": "equipment"}]  # Should be Equipment objects
            )