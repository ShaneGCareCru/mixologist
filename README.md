# mixologist

[![PR Tests](https://github.com/ShaneGCareCru/mixologist/actions/workflows/pr-tests.yml/badge.svg)](https://github.com/ShaneGCareCru/mixologist/actions/workflows/pr-tests.yml)
[![CI](https://github.com/ShaneGCareCru/mixologist/actions/workflows/ci.yml/badge.svg)](https://github.com/ShaneGCareCru/mixologist/actions/workflows/ci.yml)

---

## Project Overview & Architecture 🗄️

Mixologist is a modern recipe and cocktail management API. It uses:
- **PostgreSQL** for recipes and metadata
- **MongoDB** for all image storage (base64, not files)
- Both databases are managed via **Docker Compose** with persistent storage

---

## Setup

### 1. Docker Compose (Recommended)

Start both databases with persistent storage:
```bash
docker-compose up -d
```
- Postgres: `localhost:15432`
- MongoDB: `localhost:27017`
- Data is persisted in `./postgres_data` and `./mongo_data`

### 2. Environment Variables
Copy `env.example` to `.env` and fill in:
```
DATABASE_URL=postgresql+asyncpg://mixologist:password@localhost:15432/mixologist
MONGODB_URI=mongodb://mixologist:password@localhost:27017/mixologist
MONGODB_DB=mixologist
MONGODB_IMAGES_COLLECTION=images
OPENAI_API_KEY=your_openai_api_key_here
```

### 3. Manual Setup (Advanced/Optional)
If you prefer not to use Docker Compose:
- Install and run Postgres and MongoDB manually
- Create the databases and users as in `env.example`
- Install Python dependencies:
  ```bash
  pip install -r requirements.txt
  ```
- Run the migration/init scripts as needed

---

## Server Management

**Always use the scripts in the `scripts/` directory to manage the backend server:**
- `scripts/start_server.sh` – Start the FastAPI backend
- `scripts/stop_server.sh` – Stop the backend
- `scripts/restart_server.sh` – Restart the backend
- `scripts/status_server.sh` – Show server and DB status
- `scripts/debug_server.sh` – Start with real-time debug output

---

## API Endpoints & Usage

- **Recipes** (Postgres):
  - `GET /recipes/search` – Search recipes
  - `GET /recipes/all` – All recipes (paginated)
  - `GET /recipes/stats` – Database statistics (recipes from Postgres, images from MongoDB)
- **Images** (MongoDB):
  - `GET /images/by_category/{category}` – Images by category (e.g., `ingredients`, `technique`, etc.)
  - `GET /images/by_category/all` – All images in MongoDB

### Example Usage
```bash
# Get all images (from MongoDB)
curl http://localhost:8081/images/by_category/all

# Get ingredient images
curl http://localhost:8081/images/by_category/ingredients

# Get recipe stats
curl http://localhost:8081/recipes/stats
```

---

## Migration Note
- The migration script (`mixologist/database/init_db.py`) moves images from disk to MongoDB.
- After migration, all images are stored in MongoDB and not on disk.

---

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

---

## Flutter Front End

A basic Flutter client is located in `flutter_app/`. It targets desktop, tablet and mobile platforms from a single code base. The login flow is intended to use Firebase Authentication, while requests to the OpenAI API are proxied through a secure cloud function so the API key remains server‑side.

### Custom drink creation

The API exposes `/create_from_description` for generating a brand new cocktail when a user describes their preferences instead of providing a drink name. The Flutter home screen includes a text field for these descriptions and will display the generated recipe with a unique name.

See `flutter_app/README.md` for setup instructions.
