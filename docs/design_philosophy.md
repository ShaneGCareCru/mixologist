# Mixologist Design Philosophy — iOS‑First

##
All Colour Combination must be present in the colour_combination guide. DO NOT UPDATE the guide

## Executive Summary

Mixologist is a digital bartender companion that helps people discover, create and perfect cocktails. On iPhone and iPad it must feel **inviting, informative and intuitive**, honouring the craft of mixology while respecting the practical realities of a home bar.

## Core Design Principles (Apple HIG‑Aligned)

\### 1. Content First, Clutter Free
**Every pixel serves the cocktail—nothing else.**

* **Primary Focus → Recipe Essentials**
  Drink name, hero image, ingredients and steps are always visible without scrolling on iPhone 15‑class devices.
* **Secondary  → Techniques & Tools**
  Equipment chips, technique call‑outs and timers appear in context but never compete with primary data.
* **Tertiary → Social & Brand**
  Share, favourite and profile live in the navigation bar or a pull‑up sheet.
* **Visual Hierarchy**
  System Large Title, section headers (Title 3), body (Body), captions (Footnote). Measurements are rendered in monospaced `SF Mono` for quick scanning.

\### 2. Graceful Data Handling
**“Missing data builds trust—not confusion.”**

* **Null Safety**   All widgets render from optional types; no crash paths.
* **Transparency**   If an item is missing, show an unobtrusive info chip: “Technique image coming soon.”
* **Smart Defaults**   Fallback hero → branded shaker silhouette; fallback drink name → “Untitled Cocktail”.
* **Skeleton Loading**   Blur‑up placeholders match final layout to remove layout shift.

\### 3. Unified Visual Language — Modern Craft on iOS

* **Foundation**   Apple Human Interface Guidelines (iOS 18). Native navigation‑stack, tab‑bar, sheets, menus.
* **Accents**   Warm colours inspired by spirits (amber), herbs (sage), copper bar tools.
* **Icons**   SF Symbols (variable‑width, outline + filled pairs).
* **Motion**   Core Haptics (light tap for ingredient check‑off, success = “rigid success”), UIKit spring animations for card transitions.
* **Dynamic Type**   All text respects user’s preferred size category.
* **Dark Mode**   Full colour inversion token set.

\### 4. Intelligent Image System

| Asset Type    | Aspect Ratio | Max Logical Size     | Usage                   |
| ------------- | ------------ | -------------------- | ----------------------- |
| Hero (recipe) | 16 : 9       | 1200 × 675 px        | Header & share previews |
| Ingredient    | 1 : 1        | 256 × 256 px         | List & picker           |
| Step‑by‑Step  | 4 : 3        | 800 × 600 px         | Technique overlays      |
| Equipment     | 1 : 1        | 400 × 400 px (PNG α) | In‑context chips        |

**Technical Pipeline**

```text
Single SwiftUI AsyncImage wrapper
• Disk cache: 48 h TTL, 150 px thumbnails, 400 px detail
• progressiveBlur → sharp once full‑res arrives
```

## Application Context: “Digital Bartender” on iPhone & iPad

* **Primary Users**   Home bartenders, enthusiasts, party hosts.
* **Usage Moments**   Quick glance while mixing; discovery on couch; grocery planning.
* **Environment**   Low light, wet hands → ≥44 pt targets; voice & glance‑ability crucial.

## Information Architecture

1. **Essentials (always on screen)**  Hero, drink name, glass, ABV badge, primary flavour chips.
2. **Steps & Timers**  Inline numbered cards with haptics and circular progress.
3. **Discovery Layers**  Variations, substitutions, history, pairings in collapsible sections.

## Design System Tokens

* **Colours**
  • Primary Amber #B8860B → Dynamic (`UIColor { .light(#B8860B) .dark(#C99A29) }`)
  • Sage #87A96B · Copper #CD7F32
  • Neutrals Cream #F5F5DC · Charcoal #36454F
* **Typography**
  • Display LargeTitle (Serif New York – Bold)
  • Body (SF Pro)
  • Numeric (SF Mono)
  • Labels (SF Pro Caps).
* **Spacing**
  • 8‑pt grid, 16 pt section padding, 24 pt between primary blocks.

## Specific Solutions to Known Issues

\### Data Nullability

```swift
let drinkName = recipe.name ?? "Untitled Cocktail"
```

Wrapped in `SafeRecipeRenderer` to guarantee graceful fallback.

\### Image Drift
Unified `MixologistImage` uses enum `.hero`, `.ingredient`, `.step`, `.equipment` and enforces correct ratio.

## Success Metrics

* **Time‑to‑First‑Sip** < 10 s from launch to first essential recipe detail.
* **Active Session Duration** ≥ 60 s average engaged time per user (independent of checklist usage).
