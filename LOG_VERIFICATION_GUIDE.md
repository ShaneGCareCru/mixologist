# Multi-User CRUD Logging Verification Guide

This guide explains how to verify that the multi-user CRUD system is working correctly through comprehensive logging.

## 🚀 Quick Start

### 1. Setup Environment
```bash
# Set bypass auth for development testing
export BYPASS_AUTH=true

# Run database migration if not done already
python run_migration.py

# Test the logging system
python test_logging.py
```

### 2. Start Backend with Logging
```bash
# Use the debug script for real-time logging
./scripts/debug_server.sh

# OR start in background and tail logs
./scripts/start_server.sh
tail -f server.log
```

### 3. Start Flutter App
```bash
cd flutter_app
flutter run
```

## 📊 What to Look For in Logs

### Backend Logs (JSON Structure)

#### Authentication Events
```json
{
  "timestamp": "2024-01-01T12:00:00Z",
  "level": "INFO",
  "logger": "mixologist.auth",
  "message": "🔐 Auth Token_Verified: successful",
  "user_id": "abc123",
  "user_email": "user@example.com",
  "operation": "auth_token_verified",
  "success": true
}
```

#### User Management
```json
{
  "timestamp": "2024-01-01T12:00:01Z",
  "level": "INFO", 
  "logger": "mixologist.multiuser_inventory",
  "message": "👤 User login: abc123 (user@example.com)",
  "user_id": "abc123",
  "user_email": "user@example.com",
  "operation": "user_login"
}
```

#### Inventory Operations
```json
{
  "timestamp": "2024-01-01T12:00:02Z",
  "level": "INFO",
  "logger": "mixologist.api", 
  "message": "📦 Inventory Added: Tanqueray Gin",
  "user_id": "abc123",
  "operation": "inventory_added",
  "item_id": "item_456",
  "item_name": "Tanqueray Gin"
}
```

### Flutter Logs (Console Output)

#### Authentication Flow
```
[INFO] [MixologistApp] 🔍 Attempting Google sign-in
[INFO] [MixologistApp] ✅ Google account selected: user@example.com  
[INFO] [MixologistApp] 🔐 Auth google_signin: successful {"user_id":"abc123","user_email":"user@example.com","method":"google"}
[INFO] [MixologistApp] 📍 Navigation: login_screen → home_screen {"user_id":"abc123"}
```

#### HTTP Requests
```
[DEBUG] [MixologistApp] 🌐 HTTP GET /inventory {"user_id":"abc123","endpoint":"/inventory","method":"GET"}
[INFO] [MixologistApp] ✅ HTTP GET /inventory (245ms) {"user_id":"abc123","status_code":200,"response_time_ms":245}
[INFO] [MixologistApp] 📦 Inventory Retrieved: bulk {"user_id":"abc123","operation":"inventory_retrieved","item_count":5}
```

## 🧪 Test Scenarios

### Scenario 1: User Registration & Login

**Expected Backend Logs:**
1. `🔓 Authentication bypassed for development` (if BYPASS_AUTH=true)
2. `🆕 New user created: user_123 (user@example.com)`
3. `📋 Retrieved 0 inventory items for user user_123`

**Expected Flutter Logs:**
1. `🔍 Attempting Google sign-in`
2. `🔐 Auth google_signin: successful`
3. `📍 Navigation: login_screen → home_screen`

### Scenario 2: Adding Inventory Items

**Expected Backend Logs:**
1. `👤 User Action: add_inventory_item`
2. `📦 Inventory Added: [Item Name]`
3. `📋 Retrieved 1 inventory items for user [user_id]`

**Expected Flutter Logs:**
1. `📤 HTTP POST FORM /inventory`
2. `✅ HTTP POST /inventory (156ms)`
3. `📦 Inventory Added: [Item Name]`

### Scenario 3: Multi-User Isolation

**Test Steps:**
1. Sign in as User A, add items
2. Sign out, sign in as User B, add different items  
3. Check that each user only sees their own items

**Expected Logs:**
- Each user should have separate `user_id` in all log entries
- Inventory counts should be independent per user
- No cross-contamination of data between users

### Scenario 4: Error Handling

**Expected Logs:**
```json
{
  "level": "ERROR",
  "message": "❌ Error getting inventory for user fake_user: User not found",
  "user_id": "fake_user",
  "operation": "get_inventory",
  "exception": "HTTPException: 404"
}
```

## 🔍 Verification Checklist

### ✅ Authentication
- [ ] Google sign-in events logged with user details
- [ ] Anonymous sign-in events logged
- [ ] Token refresh events logged
- [ ] Sign-out events logged

### ✅ User Management  
- [ ] New user creation logged
- [ ] Existing user login logged
- [ ] User context preserved across requests

### ✅ Inventory Operations
- [ ] Add item: logged with user_id, item details
- [ ] Get items: logged with user_id, item count
- [ ] Update item: logged with user_id, item_id
- [ ] Delete item: logged with user_id, item_id

### ✅ Multi-User Isolation
- [ ] Each user sees only their own data
- [ ] User IDs are different for different users
- [ ] No data leakage between users

### ✅ HTTP Requests
- [ ] All requests include user authentication
- [ ] Request timing logged
- [ ] Response status codes logged
- [ ] Error requests logged with details

### ✅ Error Handling
- [ ] Invalid requests logged
- [ ] Database errors logged
- [ ] Authentication failures logged
- [ ] Network errors logged

## 🐛 Troubleshooting

### Backend Not Logging
- Check `BYPASS_AUTH=true` is set
- Verify database migration completed
- Check uvicorn log level is set to debug

### Flutter Not Logging  
- Check Flutter console output
- Verify logger import in files
- Check that operations are actually triggering

### Missing User Context
- Verify Firebase auth is working
- Check that user_id is being passed correctly
- Verify auth tokens are being sent

### Database Issues
- Run migration script again
- Check PostgreSQL/MongoDB are running
- Verify database connections in logs

## 📈 Performance Monitoring

The logs include performance metrics:

- **Response times**: HTTP request duration
- **Database queries**: Query execution time  
- **Authentication**: Token verification time
- **User operations**: End-to-end operation time

Look for slow operations (>500ms) that might need optimization.

## 🔒 Security Verification

Ensure sensitive data is not logged:
- ✅ User passwords: Never logged
- ✅ Auth tokens: Only logged as "token retrieved"
- ✅ Personal data: Only user_id and email logged
- ✅ Error details: Sanitized for production

## 📱 Mobile vs Web Logging

Flutter logs work consistently across platforms:
- **iOS/Android**: Uses developer.log() and print()
- **Web**: Uses console.log() 
- **Desktop**: Uses stdout

All platforms produce the same structured log format.