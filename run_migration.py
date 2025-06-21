#!/usr/bin/env python3
"""
Convenience script to run the multi-user database migration.
"""

import asyncio
import sys
from pathlib import Path

# Add the mixologist directory to Python path
mixologist_dir = Path(__file__).parent / "mixologist"
sys.path.insert(0, str(mixologist_dir))

from database.migrate_to_multiuser import main

if __name__ == "__main__":
    print("🚀 Running Multi-User Database Migration")
    print("=" * 50)
    asyncio.run(main())