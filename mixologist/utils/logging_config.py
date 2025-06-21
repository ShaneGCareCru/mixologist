"""
Logging configuration for the Mixologist backend.
Provides structured logging with user context and request tracking.
"""

import logging
import sys
import json
from datetime import datetime
from typing import Optional, Dict, Any
import uuid

class MixologistFormatter(logging.Formatter):
    """Custom formatter for structured logging with user context."""
    
    def format(self, record):
        # Create base log entry
        log_entry = {
            'timestamp': datetime.utcnow().isoformat() + 'Z',
            'level': record.levelname,
            'logger': record.name,
            'message': record.getMessage(),
            'module': record.module,
            'function': record.funcName,
            'line': record.lineno,
        }
        
        # Add user context if available
        if hasattr(record, 'user_id'):
            log_entry['user_id'] = record.user_id
        if hasattr(record, 'user_email'):
            log_entry['user_email'] = record.user_email
        if hasattr(record, 'request_id'):
            log_entry['request_id'] = record.request_id
        
        # Add operation context
        if hasattr(record, 'operation'):
            log_entry['operation'] = record.operation
        if hasattr(record, 'item_id'):
            log_entry['item_id'] = record.item_id
        if hasattr(record, 'item_count'):
            log_entry['item_count'] = record.item_count
        
        # Add error details if exception
        if record.exc_info:
            log_entry['exception'] = self.formatException(record.exc_info)
        
        return json.dumps(log_entry, ensure_ascii=False)

def setup_logging(level: str = "INFO", include_uvicorn: bool = True):
    """Setup logging configuration for the entire application."""
    
    # Convert string level to logging constant
    numeric_level = getattr(logging, level.upper(), logging.INFO)
    
    # Create custom formatter
    formatter = MixologistFormatter()
    
    # Setup console handler
    console_handler = logging.StreamHandler(sys.stdout)
    console_handler.setFormatter(formatter)
    console_handler.setLevel(numeric_level)
    
    # Configure root logger
    root_logger = logging.getLogger()
    root_logger.setLevel(numeric_level)
    root_logger.handlers.clear()
    root_logger.addHandler(console_handler)
    
    # Configure specific loggers
    loggers_config = {
        'mixologist': numeric_level,
        'uvicorn.access': logging.INFO if include_uvicorn else logging.WARNING,
        'uvicorn.error': logging.INFO,
        'sqlalchemy.engine': logging.WARNING,  # Reduce SQL noise
        'httpx': logging.WARNING,  # Reduce HTTP client noise
    }
    
    for logger_name, logger_level in loggers_config.items():
        logger = logging.getLogger(logger_name)
        logger.setLevel(logger_level)
    
    # Log startup message
    startup_logger = logging.getLogger('mixologist.startup')
    startup_logger.info("🚀 Mixologist Backend Logging Initialized", extra={
        'operation': 'startup',
        'log_level': level,
        'include_uvicorn': include_uvicorn
    })

class UserContextLogger:
    """Context manager for adding user information to log records."""
    
    def __init__(self, user_id: Optional[str] = None, user_email: Optional[str] = None, 
                 operation: Optional[str] = None, request_id: Optional[str] = None):
        self.user_id = user_id
        self.user_email = user_email
        self.operation = operation
        self.request_id = request_id or str(uuid.uuid4())[:8]
        self.old_factory = None
    
    def __enter__(self):
        self.old_factory = logging.getLogRecordFactory()
        
        def record_factory(*args, **kwargs):
            record = self.old_factory(*args, **kwargs)
            if self.user_id:
                record.user_id = self.user_id
            if self.user_email:
                record.user_email = self.user_email
            if self.operation:
                record.operation = self.operation
            if self.request_id:
                record.request_id = self.request_id
            return record
        
        logging.setLogRecordFactory(record_factory)
        return self
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        logging.setLogRecordFactory(self.old_factory)

def get_logger(name: str) -> logging.Logger:
    """Get a logger with the mixologist prefix."""
    return logging.getLogger(f'mixologist.{name}')

# Convenience functions for common logging patterns
def log_user_action(logger: logging.Logger, user_id: str, action: str, 
                   details: Optional[Dict[str, Any]] = None, user_email: Optional[str] = None):
    """Log a user action with context."""
    extra = {
        'user_id': user_id,
        'operation': action
    }
    if user_email:
        extra['user_email'] = user_email
    if details:
        extra.update(details)
    
    logger.info(f"👤 User Action: {action}", extra=extra)

def log_inventory_operation(logger: logging.Logger, user_id: str, operation: str, 
                          item_id: Optional[str] = None, item_name: Optional[str] = None,
                          item_count: Optional[int] = None):
    """Log an inventory operation with context."""
    extra = {
        'user_id': user_id,
        'operation': f'inventory_{operation}'
    }
    if item_id:
        extra['item_id'] = item_id
    if item_name:
        extra['item_name'] = item_name
    if item_count is not None:
        extra['item_count'] = item_count
    
    logger.info(f"📦 Inventory {operation.title()}: {item_name or item_id or 'bulk'}", extra=extra)

def log_auth_event(logger: logging.Logger, event: str, user_id: Optional[str] = None, 
                  user_email: Optional[str] = None, success: bool = True):
    """Log an authentication event."""
    extra = {
        'operation': f'auth_{event}',
        'success': success
    }
    if user_id:
        extra['user_id'] = user_id
    if user_email:
        extra['user_email'] = user_email
    
    emoji = "🔐" if success else "❌"
    status = "successful" if success else "failed"
    logger.info(f"{emoji} Auth {event.title()}: {status}", extra=extra)