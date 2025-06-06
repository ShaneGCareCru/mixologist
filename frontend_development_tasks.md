# Frontend Development Tasks: Visual Method Cards & Recipe Hub View

## Epic 1: Visual Method Cards Implementation

### Task 1.1: Method Card Component Architecture
- **Create** new `MethodCard` component with structure:
  ```javascript
  const MethodCard = {
    stepNumber: number,
    title: string,
    description: string,
    imageUrl: string,
    imageAlt: string,
    isCompleted: boolean,
    duration: string,
    difficulty: 'easy' | 'medium' | 'hard',
    proTip?: string
  }
  ```
- **Build** card states: default, active, completed, loading
- **Implement** card layout with image top (16:9 ratio), content bottom
- **Add** smooth height animations for expanding pro tips
- **Create** loading skeleton that matches final layout

### Task 1.2: Method Image Generation Pipeline
- **Extract** key visual moments from method text:
  ```javascript
  const extractVisualMoments = (stepText) => {
    const visualKeywords = ['blend', 'pour', 'garnish', 'shake', 'stir', 'muddle', 'strain'];
    // Parse step for primary action and context
    return {
      action: detectPrimaryAction(stepText),
      context: extractContext(stepText),
      details: extractImportantDetails(stepText)
    };
  }
  ```
- **Create** prompt templates for method steps:
  ```javascript
  const methodPromptTemplates = {
    blend: 'cocktail blending action, {ingredients} in blender, motion blur on blades, professional bar photography, side angle view',
    pour: 'pouring {liquid} into {glass}, steady stream, professional cocktail photography, dramatic lighting, close-up angle',
    garnish: 'placing {garnish} on cocktail rim, bartender hands visible, final presentation, shallow depth of field'
  }
  ```
- **Call** FastAPI endpoint with generated prompts
- **Implement** fallback to icon-based illustrations if generation fails

### Task 1.3: Progress Visualization System
- **Create** drink assembly progress indicator:
  ```javascript
  const DrinkProgress = {
    empty_glass: 0,
    ingredients_added: 1,
    mixed: 2,
    garnished: 3,
    complete: 4
  }
  ```
- **Build** animated glass fill visualization:
  - SVG-based glass outline
  - Liquid level animation tied to step completion
  - Color changes based on ingredients added
- **Add** smooth transitions between states (300ms ease-out)

### Task 1.4: Method Card Interactions
- **Implement** swipe gestures for mobile:
  - Swipe right to complete step
  - Swipe left to go back
  - Vertical scroll for long descriptions
- **Add** keyboard navigation:
  - Space/Enter to complete step
  - Arrow keys for navigation
  - Tab for pro tip expansion
- **Create** haptic feedback for step completion (mobile)
- **Build** auto-advance option with timer

### Task 1.5: Pro Tips Integration
- **Design** collapsible pro tip section within card
- **Add** tip categories with icons:
  - Technique tips (hand icon)
  - Ingredient tips (bottle icon)
  - Time-saving tips (clock icon)
- **Implement** smooth expand/collapse animation
- **Store** tip view state in localStorage

## Epic 2: Recipe Hub View Implementation

### Task 2.1: Hub Layout Architecture
- **Create** responsive grid system:
  ```javascript
  const HubLayout = {
    mobile: 'single-column-stack',
    tablet: '2x2-grid-with-hero',
    desktop: 'radial-with-center-hero'
  }
  ```
- **Build** flexible container supporting:
  - Center hero image (40% of viewport on desktop)
  - Surrounding content cards
  - Responsive reflow for different screens
- **Implement** CSS Grid with named areas:
  ```css
  .recipe-hub {
    display: grid;
    grid-template-areas:
      "ingredients hero equipment"
      "method hero variations"
      "related related related";
  }
  ```

### Task 2.2: Hero Section Enhancement
- **Create** interactive hero cocktail display:
  - High-res generated cocktail image
  - Floating stats badges (prep time, difficulty, servings)
  - Subtle parallax effect on scroll
  - "Make This Drink" CTA button
- **Add** image interaction states:
  - Hover: gentle scale and shadow
  - Click: fullscreen modal view
  - Loading: elegant skeleton
- **Implement** dynamic background color extraction from image

### Task 2.3: Section Preview Cards
- **Build** preview card component:
  ```javascript
  const SectionPreview = {
    title: string,
    icon: IconComponent,
    previewContent: ReactNode,
    totalItems: number,
    completedItems?: number,
    onClick: () => void
  }
  ```
- **Create** specific previews for each section:
  - **Ingredients**: 3-4 thumbnail images in grid
  - **Method**: First step card miniature
  - **Equipment**: Primary tool images
  - **Variations**: Variant names with diff indicators
- **Add** hover state showing "View All" overlay
- **Implement** smooth expand animation

### Task 2.4: Expandable Section Behavior
- **Create** section expansion system:
  - Click to expand section in-place
  - Smooth height animation with content fade-in
  - Other sections gracefully reflow
  - "Close" button or click outside to collapse
- **Build** section state management:
  ```javascript
  const [expandedSection, setExpandedSection] = useState<string | null>(null);
  const [sectionHeights, setSectionHeights] = useState<Record<string, number>>({});
  ```
- **Add** URL deep linking to sections:
  - `#ingredients`, `#method`, etc.
  - Restore expanded state on page load

### Task 2.5: Visual Connections System
- **Create** visual relationship indicators:
  - Subtle lines connecting related items
  - Ingredient highlighting when hovering method steps
  - Equipment glowing when relevant to current step
- **Implement** using SVG overlays:
  ```javascript
  const ConnectionLine = ({ from, to, active }) => {
    const path = calculateBezierPath(from, to);
    return (
      <svg className={`connection ${active ? 'active' : ''}`}>
        <path d={path} />
      </svg>
    );
  }
  ```
- **Add** animation on interaction (dash-offset animation)

### Task 2.6: Hub Performance Optimization
- **Implement** intersection observer for section loading:
  - Load section content only when visible
  - Preload next likely section
- **Add** image optimization:
  - Use srcset for responsive images
  - Lazy load non-critical images
  - Blur-up placeholders
- **Create** smooth scroll behavior with momentum
- **Build** reduced motion mode respecting user preferences

## Epic 3: Integration & Polish

### Task 3.1: Animation System
- **Create** consistent animation variables:
  ```css
  --transition-quick: 150ms ease-out;
  --transition-smooth: 300ms cubic-bezier(0.4, 0, 0.2, 1);
  --transition-bounce: 500ms cubic-bezier(0.68, -0.55, 0.265, 1.55);
  ```
- **Implement** staggered animations for card appearances
- **Add** micro-interactions for all interactive elements
- **Create** page transition animations

### Task 3.2: State Synchronization
- **Build** central state management for:
  - Completed steps
  - Checked ingredients
  - Current section
  - View preferences
- **Implement** real-time sync between hub and detail views
- **Add** progress persistence across sessions
- **Create** "Reset Recipe" functionality

### Task 3.3: Mobile Optimization
- **Adapt** hub view for mobile:
  - Stack sections vertically
  - Sticky section headers
  - Swipe between sections
  - Bottom sheet for expanded sections
- **Optimize** touch targets (minimum 44x44px)
- **Add** pull-to-refresh for image regeneration
- **Implement** offline support with service worker

### Task 3.4: Accessibility Enhancements
- **Add** comprehensive ARIA labels
- **Implement** keyboard navigation for hub
- **Create** screen reader announcements for progress
- **Add** focus indicators for all interactive elements
- **Build** high contrast mode support

### Task 3.5: Testing & Quality Assurance
- **Write** unit tests for:
  - Method card state management
  - Hub layout calculations
  - Image generation prompt building
- **Create** E2E tests for:
  - Complete recipe flow
  - Section expansion/collapse
  - Progress tracking
- **Implement** visual regression tests
- **Add** performance monitoring

## Definition of Done:
- [ ] All images generate successfully via FastAPI
- [ ] Smooth animations with no jank (60fps)
- [ ] Mobile responsive across all breakpoints
- [ ] Accessibility audit passes
- [ ] Page load under 2 seconds
- [ ] All interactive elements have loading states
- [ ] Progress saves and restores correctly
- [ ] Works offline after first load