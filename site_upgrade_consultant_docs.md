Ah, I understand now! The recipe (including all text) is AI-generated first, and then we need to create consistent visual assets based on that generated content. Let me reframe the tasks accordingly.

## Frontend Development Tasks: Dynamic Visual Generation System

### Epic 1: Recipe-Based Image Generation Pipeline

#### Task 1.1: Main Cocktail Image Generation
- **Create** cocktail image component that triggers after recipe generation
- **Extract** key visual elements from AI-generated recipe:
  ```javascript
  const extractCocktailVisuals = (recipe) => {
    return {
      drinkName: recipe.name,
      glassType: recipe.servingGlass,
      garnish: recipe.garnish,
      color: recipe.inferredColor, // e.g., "amber", "clear", "red"
      ingredients: recipe.ingredients
    };
  }
  ```
- **Build** prompt from recipe data:
  ```javascript
  const cocktailPrompt = `${drinkName} cocktail in ${glassType}, ${garnish} garnish, ${color} colored drink, professional cocktail photography, bar setting, moody lighting`;
  ```
- **Call** FastAPI image generation endpoint
- **Handle** loading and error states

#### Task 1.2: Visual Consistency System
- **Define** consistent style parameters for all generated images:
  ```javascript
  const styleConstants = {
    ingredients: 'product photography, soft studio lighting, slight shadow, white marble surface, 45-degree angle',
    glassware: 'elegant barware photography, subtle reflections, light gray gradient background, centered composition',
    equipment: 'professional bar tools, matte black surface, minimalist style, overhead view',
    garnish: 'fresh garnish macro photography, natural lighting, shallow depth of field'
  }
  ```
- **Create** prompt builder function:
  ```javascript
  const buildPrompt = (subject, category) => {
    return `${subject}, ${styleConstants[category]}`;
  }
  ```

### Epic 2: Dynamic Asset Generation from Recipe Data

#### Task 2.1: Ingredient Image Generation
- **Parse** ingredients from recipe text
- **Create** ingredient visualization component
- **Generate** prompts dynamically:
  ```javascript
  const generateIngredientPrompt = (ingredientLine) => {
    // "2 oz Bourbon" -> "bourbon whiskey bottle, product photography..."
    const ingredient = parseIngredient(ingredientLine);
    return buildPrompt(ingredient.name, 'ingredients');
  }
  ```
- **Batch** API calls to prevent overload
- **Display** ingredients in visual grid as they generate

#### Task 2.2: Glassware Extraction and Generation
- **Extract** glass type from recipe.servingGlass
- **Handle** glass variations:
  ```javascript
  const normalizeGlassName = (glassText) => {
    // "Old Fashioned glass (rocks glass)" -> "old fashioned rocks glass"
    // "Coupe" -> "coupe glass"
    return glassText.toLowerCase().replace(/[()]/g, '').trim();
  }
  ```
- **Generate** glass image with consistent styling
- **Add** to recipe header as visual element

### Epic 3: Non-Linear Recipe Interface

#### Task 3.1: Multi-Entry Dashboard Layout
- **Replace** sequential scroll with hub layout
- **Create** entry cards:
  - Overview (hero image + quick stats)
  - Ingredients (visual grid)
  - Method (step cards)
  - Equipment (tool grid)  
  - Variations (if present in recipe)
  - History (if present in recipe)
- **Implement** CSS Grid or Flexbox masonry
- **Add** smooth transitions between sections

#### Task 3.2: Visual Navigation System
- **Create** visual navigation bar with generated thumbnails
- **Implement** section preview on hover
- **Add** progress indicators for image generation
- **Enable** deep linking to sections

### Epic 4: Contextual Image Generation

#### Task 4.1: Garnish Visualization
- **Parse** garnish from recipe data
- **Generate** garnish images:
  ```javascript
  const garnishPrompt = (garnishText) => {
    // "Orange Peel: 1 twist" -> "orange peel twist cocktail garnish..."
    const garnish = parseGarnish(garnishText);
    return buildPrompt(`${garnish.type} ${garnish.preparation}`, 'garnish');
  }
  ```
- **Display** in garnish section with preparation notes

#### Task 4.2: Step-Based Visuals
- **Identify** visual moments in instructions
- **Generate** technique images for key steps:
  - Muddling action
  - Stirring technique
  - Garnish expression
- **Use** consistent style but action-focused prompts:
  ```javascript
  const techniquePrompt = `${action} cocktail technique, hands demonstrating, professional bartending, motion blur effect`;
  ```

### Epic 5: Image Generation State Management

#### Task 5.1: Generation Queue System
- **Create** queue manager for image requests
- **Implement** priority system:
  1. Main cocktail image
  2. Ingredients
  3. Glassware
  4. Equipment
  5. Garnishes
  6. Techniques
- **Add** concurrent request limiting (e.g., max 3 at once)
- **Show** generation progress in UI

#### Task 5.2: Fallback and Error Handling
- **Create** elegant placeholder components
- **Implement** retry mechanism with user notification
- **Add** "Regenerate Image" buttons
- **Log** failed prompts for debugging
- **Provide** text-only fallback mode

### Epic 6: Performance Optimization

#### Task 6.1: Progressive Image Loading
- **Load** text content immediately
- **Generate** images based on viewport priority
- **Implement** intersection observer for lazy generation
- **Add** blur-up effect as images load

#### Task 6.2: Caching Strategy
- **Cache** generated image URLs by prompt hash
- **Implement** recipe version tracking
- **Clear** cache on recipe regeneration
- **Add** preload hints for likely next views

Would you like me to continue with more epics around the non-linear navigation patterns and how to make the recipe exploration more dynamic?
