#!/usr/bin/env python3
"""
Database migration script to convert single-user inventory to multi-user system.
This script will:
1. Create new database tables for users and inventory
2. Migrate existing JSON inventory data to the database
3. Create a default user for existing data
"""

import asyncio
import json
import os
import sys
from pathlib import Path
from typing import Dict, List
from datetime import datetime
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker

# Add parent directory to path so we can import from mixologist
sys.path.append(str(Path(__file__).parent.parent))

from models import Base, User, InventoryItem, DatabaseMigrator
from database_config import get_database_url

# Configuration
INVENTORY_FILE = Path(__file__).parent.parent / "static" / "inventory" / "user_inventory.json"
DEFAULT_USER_EMAIL = "default@mixologist.local"
DEFAULT_USER_UID = "default_user_migration"

async def main():
    """Main migration function."""
    print("🚀 Starting multi-user database migration...")
    
    # Get database URL
    database_url = get_database_url()
    print(f"📊 Database URL: {database_url.split('@')[1] if '@' in database_url else database_url}")
    
    # Create async engine
    engine = create_async_engine(database_url, echo=True)
    
    # Create session factory
    async_session = sessionmaker(
        engine, class_=AsyncSession, expire_on_commit=False
    )
    
    try:
        # Step 1: Create all tables
        print("\n📋 Step 1: Creating database tables...")
        async with engine.begin() as conn:
            await conn.run_sync(Base.metadata.create_all)
        print("✅ Database tables created successfully")
        
        # Step 2: Create default user
        print("\n👤 Step 2: Creating default user...")
        async with async_session() as session:
            # Check if default user already exists
            existing_user = await session.execute(
                "SELECT * FROM users WHERE firebase_uid = :uid",
                {"uid": DEFAULT_USER_UID}
            )
            if existing_user.first():
                print("⚠️  Default user already exists, skipping creation")
            else:
                default_user = User(
                    firebase_uid=DEFAULT_USER_UID,
                    email=DEFAULT_USER_EMAIL,
                    display_name="Default User (Migration)",
                    created_at=datetime.now(),
                    last_login=datetime.now()
                )
                session.add(default_user)
                await session.commit()
                print(f"✅ Default user created with UID: {DEFAULT_USER_UID}")
        
        # Step 3: Migrate existing inventory data
        print("\n📦 Step 3: Migrating inventory data...")
        if INVENTORY_FILE.exists():
            await migrate_inventory_data(async_session)
        else:
            print("⚠️  No existing inventory file found, skipping inventory migration")
        
        print("\n🎉 Migration completed successfully!")
        print("\n📝 Next steps:")
        print("1. Update your backend to use the new database-backed inventory service")
        print("2. Implement Firebase Authentication in your Flutter app")
        print("3. Test the multi-user functionality")
        
    except Exception as e:
        print(f"❌ Migration failed: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
    
    finally:
        await engine.dispose()

async def migrate_inventory_data(async_session):
    """Migrate existing JSON inventory data to database."""
    print(f"📂 Reading inventory data from: {INVENTORY_FILE}")
    
    try:
        with open(INVENTORY_FILE, 'r') as f:
            inventory_data = json.load(f)
        
        items = inventory_data.get('items', [])
        print(f"📊 Found {len(items)} inventory items to migrate")
        
        if not items:
            print("ℹ️  No inventory items to migrate")
            return
        
        async with async_session() as session:
            # Get the default user
            result = await session.execute(
                "SELECT id FROM users WHERE firebase_uid = :uid",
                {"uid": DEFAULT_USER_UID}
            )
            user_row = result.first()
            if not user_row:
                raise Exception("Default user not found. Cannot migrate inventory.")
            
            user_id = user_row[0]
            print(f"👤 Migrating items for user ID: {user_id}")
            
            migrated_count = 0
            for item_data in items:
                try:
                    # Convert JSON item to database model
                    inventory_item = InventoryItem(
                        user_id=user_id,
                        item_id=item_data.get('id', f"migrated_{migrated_count}"),
                        name=item_data.get('name', 'Unknown'),
                        category=item_data.get('category', 'other'),
                        quantity=item_data.get('quantity', 'full_bottle'),
                        fullness=float(item_data.get('fullness', 1.0)),
                        brand=item_data.get('brand'),
                        notes=item_data.get('notes'),
                        image_path=item_data.get('image_path'),
                        expires_soon=item_data.get('expires_soon', False),
                        added_date=datetime.fromisoformat(item_data.get('added_date', datetime.now().isoformat())),
                        last_updated=datetime.fromisoformat(item_data.get('last_updated', datetime.now().isoformat()))
                    )
                    
                    session.add(inventory_item)
                    migrated_count += 1
                    
                except Exception as e:
                    print(f"⚠️  Failed to migrate item {item_data.get('name', 'unknown')}: {e}")
            
            await session.commit()
            print(f"✅ Successfully migrated {migrated_count} inventory items")
            
            # Backup original file
            backup_file = INVENTORY_FILE.with_suffix('.json.backup')
            INVENTORY_FILE.rename(backup_file)
            print(f"💾 Original inventory file backed up to: {backup_file}")
            
    except Exception as e:
        print(f"❌ Failed to migrate inventory data: {e}")
        raise

if __name__ == "__main__":
    asyncio.run(main())