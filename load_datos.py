#!/usr/bin/env python3
"""
Script to load datos.sql into Cloud SQL
"""
import sys
from sqlalchemy import create_engine, text

# Configuration
PROJECT_ID = "project3grupo6"
DB_INSTANCE = "project3grupo6-postgres"
DB_NAME = "edem_hub_db"
DB_USER = "postgres"
DB_PASSWORD = "ChangeMe123!Secure"
DB_REGION = "europe-southwest1"
PUBLIC_IP = "34.175.58.253"

# Create connection URL for Cloud SQL
db_url = f"postgresql://{DB_USER}:{DB_PASSWORD}@{PUBLIC_IP}/{DB_NAME}"

print(f"Connecting to {db_url}...")
engine = create_engine(db_url, echo=False)

# Read and execute datos.sql
print("Reading datos.sql...")
with open("db/datos.sql", "r", encoding="utf-8") as f:
    sql_content = f.read()

print("Executing SQL statements...")
with engine.connect() as conn:
    # Split by semicolons and execute each statement
    statements = sql_content.split(";")
    for i, statement in enumerate(statements):
        stmt = statement.strip()
        if stmt:
            try:
                print(f"  [{i+1}/{len(statements)}] Executing statement ({len(stmt)} chars)...")
                conn.execute(text(stmt))
                conn.commit()
            except Exception as e:
                print(f"  ERROR: {e}")
                conn.rollback()
                sys.exit(1)

print("✓ Data loaded successfully!")
engine.dispose()
