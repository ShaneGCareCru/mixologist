def build_llm_prompt_for_canonicalization(drink_query: str) -> str:
    """Prompt the LLM to use its own world knowledge to canonicalize the drink, only inventing if truly novel."""
    prompt = f"""
You are an expert cocktail historian and bartender. When given a drink name or description, your first task is to determine if it matches any known classic or popular cocktail, using your own world knowledge. If it does, return ONLY the canonical name of the drink and a short explanation of the match. Do NOT invent a new recipe or name unless the description is truly novel and does not match any known drink, variation, or regional name.

If the input is a minor variation or a known twist on a canonical drink, return the canonical name and describe the variation.

User input: "{drink_query}"

Instructions:
- If the input matches a known drink (by name, description, or as a variation), reply with:
  - drink_name: <canonical name>
  - match_reason: <short explanation>
  - variation_description: <describe how the input differs from the canonical, if at all>
- If not, generate a new recipe as usual.
"""
    return prompt

def parse_llm_recipe_response(response: dict) -> tuple[str, dict]:
    """Parse the LLM response to distinguish between canonical match and new recipe."""
    # If response has 'drink_name' and 'match_reason', treat as canonical match
    if "drink_name" in response and "match_reason" in response and len(response) <= 3:
        return "canonical_match", response
    # Otherwise treat as new recipe
    return "new_recipe", response 