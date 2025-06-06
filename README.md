# mixologist

[![PR Tests](https://github.com/ShaneGCareCru/mixologist/actions/workflows/pr-tests.yml/badge.svg)](https://github.com/ShaneGCareCru/mixologist/actions/workflows/pr-tests.yml)
[![CI](https://github.com/ShaneGCareCru/mixologist/actions/workflows/ci.yml/badge.svg)](https://github.com/ShaneGCareCru/mixologist/actions/workflows/ci.yml)

## Modern Upscale NYC Bar Color Palette

| Swatch | Use Case | Color Name | Hex Code | Description |
| ------ | -------- | ---------- | -------- | ----------- |
| ![#1C1C1E](https://via.placeholder.com/15/1C1C1E/000000?text=+) | Main background | Charcoal Black | `#1C1C1E` | Deep black with a hint of warmth, perfect for intimate, moody vibes. |
| ![#3E3C36](https://via.placeholder.com/15/3E3C36/000000?text=+) | Accent background | Smoked Bronze | `#3E3C36` | Rich bronze-gray adds an industrial elegance. |
| ![#D4AF37](https://via.placeholder.com/15/D4AF37/000000?text=+) | Primary highlight | Champagne Gold | `#D4AF37` | Refined gold for lighting accents, logos, or trim—adds luxury without being loud. |
| ![#5C2A3A](https://via.placeholder.com/15/5C2A3A/000000?text=+) | Secondary accent | Velvet Burgundy | `#5C2A3A` | A rich, wine-red tone perfect for upholstery or accent walls. |
| ![#F5F1E8](https://via.placeholder.com/15/F5F1E8/000000?text=+) | Soft lighting/neutral | Warm Ivory | `#F5F1E8` | Soft warm white to contrast the dark tones and provide comfort and readability. |
| ![#5A684A](https://via.placeholder.com/15/5A684A/000000?text=+) | Green accent (optional) | Olive Leaf | `#5A684A` | A muted green ideal for adding depth and a hint of organic sophistication. |

This palette aims to combine an intimate ambience with modern industrial touches, keeping the overall feel luxurious yet understated.

## Flutter Front End

A basic Flutter client is located in `flutter_app/`. It targets desktop, tablet and mobile platforms from a single code base. The login flow is intended to use Firebase Authentication, while requests to the OpenAI API are proxied through a secure cloud function so the API key remains server‑side.

See `flutter_app/README.md` for setup instructions.
