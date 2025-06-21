"""Database configuration and connection utilities."""

import os
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

def get_database_url() -> str:
    """Get the database URL from environment variables."""
    return os.getenv(
        "DATABASE_URL", 
        "postgresql+asyncpg://mixologist:password@localhost:15432/mixologist"
    )

def get_async_engine():
    """Create and return an async database engine."""
    database_url = get_database_url()
    
    # SQLite configuration
    if database_url.startswith("sqlite"):
        return create_async_engine(
            database_url,
            echo=False,
            poolclass=StaticPool,
            connect_args={"check_same_thread": False}
        )
    
    # PostgreSQL configuration
    return create_async_engine(
        database_url,
        echo=False,
        pool_pre_ping=True,
        pool_recycle=300
    )

def get_async_session_factory():
    """Create and return an async session factory."""
    engine = get_async_engine()
    return sessionmaker(
        engine, 
        class_=AsyncSession, 
        expire_on_commit=False
    )

# Global session factory
async_session_factory = get_async_session_factory()