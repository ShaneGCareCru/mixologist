# Multi-User CRUD Testing Guide

## 🚀 Quick Setup

### 1. Start the Backend Server
```bash
# Use debug mode to see real-time logs
./scripts/debug_server.sh
```

This script will:
- ✅ Automatically set `BYPASS_AUTH=true` for development
- ✅ Load environment variables from `.env`
- ✅ Check PostgreSQL is running on port 15432
- ✅ Show structured JSON logs in real-time
- ✅ Display print statements from image analysis

### 2. Run Database Migration (if needed)
```bash
python run_migration.py
```

### 3. Test Logging System
```bash
python test_logging.py
```

### 4. Start Flutter App
```bash
cd flutter_app
flutter run
```

## 📊 What You'll See in the Logs

### Backend Server Startup
```json
{"timestamp": "2024-01-01T12:00:00Z", "level": "INFO", "logger": "mixologist.startup", "message": "🚀 Mixologist Backend Logging Initialized", "operation": "startup"}
```

### User Authentication (Development Mode)
```json
{"timestamp": "2024-01-01T12:00:01Z", "level": "WARNING", "logger": "mixologist.auth", "message": "🔓 Authentication bypassed for development", "user_id": "dev_user", "operation": "auth_bypass"}
```

### Multi-User Inventory Operations
```json
{"timestamp": "2024-01-01T12:00:02Z", "level": "INFO", "logger": "mixologist.api", "message": "📦 Inventory Added: Tanqueray Gin", "user_id": "dev_user", "operation": "inventory_added", "item_name": "Tanqueray Gin"}
```

### Flutter App Logs
```
[INFO] [MixologistApp] 📱 App user_authenticated {"user_id":"dev_user","is_anonymous":true}
[INFO] [MixologistApp] ✅ HTTP GET /inventory (245ms) {"status_code":200,"response_time_ms":245}
[INFO] [MixologistApp] 📦 Inventory Retrieved: bulk {"user_id":"dev_user","item_count":0}
```

## 🧪 Testing Scenarios

### Test 1: User Sign-In Flow
1. Start the app - should see auth state loading
2. Tap "Start Mixing (Guest)" - should see anonymous sign-in
3. Navigate to inventory - should see empty inventory

**Expected Logs:**
- Backend: Authentication bypass for development
- Flutter: Auth anonymous_signin successful
- Backend: New user created or existing user login

### Test 2: Add Inventory Item
1. Go to inventory screen
2. Add a new item (e.g., "Gin", "Spirits", "Full Bottle")
3. Check logs for multi-user context

**Expected Logs:**
- Flutter: HTTP POST FORM /inventory with user context
- Backend: User Action: add_inventory_item
- Backend: Inventory Added: [Item Name]

### Test 3: View Inventory
1. Navigate back to inventory list
2. Should see the item you just added

**Expected Logs:**
- Flutter: HTTP GET /inventory
- Backend: User Action: get_inventory
- Backend: Retrieved [N] inventory items for user [user_id]

### Test 4: Multi-User Isolation (Manual Test)
Since we're in development mode with anonymous auth, all operations will use the same "dev_user" ID. To test true isolation, you would need to:
1. Set `BYPASS_AUTH=false`
2. Configure real Firebase authentication
3. Sign in with different Google accounts

## 🔧 Server Management Commands

```bash
# Check if server is running
./scripts/status_server.sh

# Stop the server
./scripts/stop_server.sh

# Restart (stop + start)
./scripts/restart_server.sh

# Start in background (production mode)
./scripts/start_server.sh

# View background logs
tail -f server.log
```

## 🐛 Troubleshooting

### Server Won't Start
```bash
# Check PostgreSQL is running
nc -z localhost 15432

# Check if port 8081 is in use
lsof -i :8081

# Force stop any hanging processes
./scripts/stop_server.sh
```

### No Logs Appearing
- Ensure you're using `./scripts/debug_server.sh` (not start_server.sh)
- Check that imports are working in the fastapi_app.py
- Verify BYPASS_AUTH is set to true

### Database Errors
```bash
# Re-run migration
python run_migration.py

# Check Docker containers
docker ps | grep postgres
docker ps | grep mongo
```

### Flutter Connection Issues
- Ensure backend is running on port 8081
- Check iOS simulator can reach localhost
- Verify no CORS issues in browser console (for web)

## 📈 Performance Monitoring

Watch for these metrics in the logs:
- **HTTP Response Times**: Should be < 500ms for inventory operations
- **Database Queries**: Should complete quickly
- **Authentication**: Token verification should be fast
- **User Operations**: End-to-end request processing

## 🔒 Security Notes

In development mode (`BYPASS_AUTH=true`):
- All requests use the same "dev_user" ID
- No real authentication is performed
- Firebase tokens are not verified
- This is for development/testing only

For production:
- Set `BYPASS_AUTH=false`
- Configure Firebase service account
- Use real Google authentication
- Enable proper user isolation