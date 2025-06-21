"""
Firebase Authentication middleware and utilities for the FastAPI backend.
This module handles Firebase ID token verification and user authentication.
"""

import os
import logging
from typing import Optional
from fastapi import HTTPException, Depends, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
import firebase_admin
from firebase_admin import credentials, auth as firebase_auth
from dotenv import load_dotenv
from ..utils.logging_config import get_logger, log_auth_event

load_dotenv()

logger = get_logger('auth')

# Initialize Firebase Admin SDK
firebase_app = None
try:
    # Try to get Firebase service account from environment
    service_account_path = os.getenv("FIREBASE_SERVICE_ACCOUNT_PATH")
    service_account_json = os.getenv("FIREBASE_SERVICE_ACCOUNT_JSON")
    
    if service_account_path and os.path.exists(service_account_path):
        cred = credentials.Certificate(service_account_path)
        firebase_app = firebase_admin.initialize_app(cred)
        logger.info("Firebase Admin SDK initialized with service account file")
    elif service_account_json:
        import json
        service_account = json.loads(service_account_json)
        cred = credentials.Certificate(service_account)
        firebase_app = firebase_admin.initialize_app(cred)
        logger.info("Firebase Admin SDK initialized with service account JSON")
    else:
        # For development, try default credentials
        try:
            firebase_app = firebase_admin.initialize_app()
            logger.info("Firebase Admin SDK initialized with default credentials")
        except Exception as e:
            logger.warning(f"Firebase Admin SDK not initialized: {e}")
            firebase_app = None

except Exception as e:
    logger.error(f"Failed to initialize Firebase Admin SDK: {e}")
    firebase_app = None

# Security scheme for Bearer token
security = HTTPBearer(auto_error=False)

class FirebaseUser:
    """Represents an authenticated Firebase user."""
    
    def __init__(self, uid: str, email: str = None, name: str = None, 
                 picture: str = None, email_verified: bool = False):
        self.uid = uid
        self.email = email
        self.name = name
        self.picture = picture
        self.email_verified = email_verified

async def get_current_user(credentials: HTTPAuthorizationCredentials = Depends(security)) -> FirebaseUser:
    """
    Get the current authenticated user from Firebase ID token.
    This function is used as a dependency in FastAPI endpoints.
    """
    if not firebase_app:
        # For development/testing, allow bypassing authentication
        if os.getenv("BYPASS_AUTH", "false").lower() == "true":
            dev_user = FirebaseUser(
                uid="dev_user",
                email="dev@mixologist.local",
                name="Development User",
                email_verified=True
            )
            log_auth_event(logger, "bypass", user_id=dev_user.uid, user_email=dev_user.email, success=True)
            logger.warning("🔓 Authentication bypassed for development", extra={
                'user_id': dev_user.uid,
                'user_email': dev_user.email,
                'operation': 'auth_bypass'
            })
            return dev_user
        
        log_auth_event(logger, "service_unavailable", success=False)
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Authentication service not available"
        )
    
    if not credentials:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authentication required",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    try:
        # Verify the Firebase ID token
        decoded_token = firebase_auth.verify_id_token(credentials.credentials)
        
        # Extract user information
        uid = decoded_token["uid"]
        email = decoded_token.get("email")
        name = decoded_token.get("name")
        picture = decoded_token.get("picture")
        email_verified = decoded_token.get("email_verified", False)
        
        user = FirebaseUser(
            uid=uid,
            email=email,
            name=name,
            picture=picture,
            email_verified=email_verified
        )
        
        log_auth_event(logger, "token_verified", user_id=uid, user_email=email, success=True)
        logger.info(f"🔐 Authenticated user: {uid} ({email})", extra={
            'user_id': uid,
            'user_email': email,
            'operation': 'auth_success',
            'email_verified': email_verified
        })
        
        return user
        
    except firebase_auth.InvalidIdTokenError as e:
        log_auth_event(logger, "invalid_token", success=False)
        logger.warning(f"❌ Invalid Firebase ID token: {e}", extra={'operation': 'auth_invalid_token'})
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authentication token",
            headers={"WWW-Authenticate": "Bearer"},
        )
    except firebase_auth.ExpiredIdTokenError as e:
        log_auth_event(logger, "expired_token", success=False)
        logger.warning(f"⏰ Expired Firebase ID token: {e}", extra={'operation': 'auth_expired_token'})
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authentication token expired",
            headers={"WWW-Authenticate": "Bearer"},
        )
    except Exception as e:
        log_auth_event(logger, "error", success=False)
        logger.error(f"❌ Authentication error: {e}", extra={'operation': 'auth_error'})
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authentication failed",
            headers={"WWW-Authenticate": "Bearer"},
        )

async def get_optional_user(credentials: HTTPAuthorizationCredentials = Depends(security)) -> Optional[FirebaseUser]:
    """
    Get the current user if authenticated, otherwise return None.
    Useful for endpoints that work for both authenticated and anonymous users.
    """
    try:
        return await get_current_user(credentials)
    except HTTPException:
        return None

# Helper functions for backward compatibility during migration
async def get_user_id_for_request(current_user: FirebaseUser = Depends(get_current_user)) -> str:
    """Get the user ID for API requests. Used as a dependency."""
    return current_user.uid

async def get_optional_user_id_for_request(current_user: Optional[FirebaseUser] = Depends(get_optional_user)) -> str:
    """Get the user ID for API requests, with fallback to default user during migration."""
    if current_user:
        return current_user.uid
    else:
        # Fallback to default user for migration period
        return "default_user_migration"