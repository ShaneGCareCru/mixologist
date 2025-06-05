from pydantic import BaseModel, Field
from typing import List, Dict, Optional

class Ingredient(BaseModel):
    name: str = Field(..., description="Name of the ingredient")
    quantity: str = Field(..., description="Quantity of the ingredient")

class BrandRecommendation(BaseModel):
    ingredient: str = Field(..., description="Name of the ingredient")
    brands: List[str] = Field(..., description="Recommended brands for this ingredient")

class IngredientSubstitution(BaseModel):
    original: str = Field(..., description="Original ingredient name")
    alternatives: List[str] = Field(..., description="List of substitute ingredients")

class Equipment(BaseModel):
    item: str = Field(..., description="Name of the equipment")
    essential: bool = Field(..., description="Whether this equipment is essential")
    alternative: Optional[str] = Field(None, description="Alternative equipment if not essential")

class FlavorProfile(BaseModel):
    primary_flavors: List[str] = Field(..., description="Primary flavors in the cocktail")
    secondary_notes: List[str] = Field(..., description="Secondary flavor notes")
    mouthfeel: str = Field(..., description="Description of the mouthfeel")
    finish: str = Field(..., description="Description of the finish")
    balance: str = Field(..., description="Description of the flavor balance")

class ServingSizeBase(BaseModel):
    default_servings: int = Field(1, description="Default number of servings")
    scalable_ingredients: bool = Field(True, description="Whether ingredients can be scaled")
    max_recommended_batch: int = Field(8, description="Maximum recommended batch size")
    batch_preparation_notes: str = Field("", description="Notes for batch preparation")

class RecipeVariation(BaseModel):
    name: str = Field(..., description="Name of the variation")
    changes: List[str] = Field(..., description="List of changes from the original recipe")
    description: str = Field(..., description="Description of the variation")

class EnhancedStep(BaseModel):
    step_number: int = Field(..., description="Step number in the recipe")
    action: str = Field(..., description="The action to perform")
    technique_detail: str = Field("", description="Detailed technique explanation")
    visual_cue: str = Field("", description="Visual cue for proper technique")
    common_mistakes: List[str] = Field(default_factory=list, description="Common mistakes to avoid")
    timing_guidance: str = Field("", description="Timing guidance for this step")

class GetRecipeParams(BaseModel):
    # Original fields
    ingredients: List[Ingredient] = Field(..., description="List out the ingredients and their quantities")
    alcohol_content: float = Field(..., description="The alcohol content of the drink. This is a number between 0 and 1.0")
    steps: List[str] = Field(..., description="List out the steps to make the drink")
    rim: bool = Field(..., description="If the drink has a salted rim, this should be true")
    garnish: List[str] = Field(..., description="What is the garnish for the drink")
    serving_glass: str = Field(..., description="What is the serving glass for the drink")
    drink_image_description: str = Field(..., description="Drink image from the perspective of a food photographer, must include ingredients, rim, garnish, camera, orientation, lighting, and bright background")
    drink_history: str = Field(..., description="fun history about the drink that's interesting to the reader")
    drink_name: str = Field(..., description="the name of the drink")
    
    # Enhanced fields
    brand_recommendations: List[BrandRecommendation] = Field(default_factory=list, description="Brand recommendations for each ingredient")
    ingredient_substitutions: List[IngredientSubstitution] = Field(default_factory=list, description="Substitution options for ingredients")
    related_cocktails: List[str] = Field(default_factory=list, description="List of 6-8 related cocktail names")
    difficulty_rating: int = Field(3, description="Difficulty rating from 1-5 (1=very easy, 5=expert level)")
    preparation_time_minutes: int = Field(5, description="Estimated preparation time in minutes")
    equipment_needed: List[Equipment] = Field(default_factory=list, description="Equipment needed with alternatives")
    flavor_profile: Optional[FlavorProfile] = Field(None, description="Detailed flavor profile and tasting notes")
    serving_size_base: Optional[ServingSizeBase] = Field(None, description="Base serving size information for scaling")
    phonetic_pronunciations: Dict[str, str] = Field(default_factory=dict, description="Phonetic pronunciations for complex terms")
    enhanced_steps: List[EnhancedStep] = Field(default_factory=list, description="Enhanced step instructions with technique details")
    suggested_variations: List[RecipeVariation] = Field(default_factory=list, description="Suggested recipe variations")
    food_pairings: List[str] = Field(default_factory=list, description="Recommended food pairings")
    optimal_serving_temperature: str = Field("", description="Optimal serving temperature")
    skill_level_recommendation: str = Field("", description="Recommended skill level for home bartenders")

