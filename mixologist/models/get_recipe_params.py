from pydantic import BaseModel, Field
from typing import List

class Ingredient(BaseModel):
    name: str = Field(..., description="Name of the ingredient")
    quantity: str = Field(..., description="Quantity of the ingredient")

class GetRecipeParams(BaseModel):
    ingredients: List[Ingredient] = Field(..., description="List out the ingredients and their quantities")
    alcohol_content: float = Field(..., description="The alcohol content of the drink. This is a number between 0 and 1.0")
    steps: List[str] = Field(..., description="List out the steps to make the drink")
    rim: bool = Field(..., description="If the drink has a salted rim, this should be true")
    garnish: List[str] = Field(..., description="What is the garnish for the drink")
    serving_glass: str = Field(..., description="What is the serving glass for the drink")
    drink_image_description: str = Field(..., description="Drink image from the perspective of a food photographer, must include ingredients, rim, garnish, camera, orientation, lighting, and bright background")
    drink_history: str = Field(..., description="fun history about the drink that's interesting to the reader")
    drink_name: str = Field(..., description="the name of the drink")

