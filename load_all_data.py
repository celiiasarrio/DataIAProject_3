#!/usr/bin/env python3
"""Load datos.sql into Cloud SQL"""
import sys
try:
    import psycopg2
    from psycopg2 import sql
except ImportError:
    print("Installing psycopg2...")
    import subprocess
    subprocess.check_call([sys.executable, "-m", "pip", "install", "psycopg2-binary"])
    import psycopg2

# Configuration
HOST = "34.175.58.253"
DATABASE = "edem_hub_db"
USER = "postgres"
PASSWORD = "ChangeMe123!Secure"
SQL_FILE = "db/datos.sql"

print(f"Connecting to {HOST}...")
try:
    conn = psycopg2.connect(
        host=HOST,
        database=DATABASE,
        user=USER,
        password=PASSWORD,
        client_encoding='UTF8'
    )
    cursor = conn.cursor()

    print(f"Reading {SQL_FILE}...")
    with open(SQL_FILE, 'r', encoding='utf-8') as f:
        sql_content = f.read()

    print("Executing SQL script...")
    cursor.execute(sql_content)
    conn.commit()

    # Verify data was loaded
    cursor.execute("SELECT COUNT(*) FROM alumnos")
    alumnos = cursor.fetchone()[0]
    cursor.execute("SELECT COUNT(*) FROM profesores")
    profesores = cursor.fetchone()[0]
    cursor.execute("SELECT COUNT(*) FROM sesiones")
    sesiones = cursor.fetchone()[0]
    cursor.execute("SELECT COUNT(*) FROM eventos")
    eventos = cursor.fetchone()[0]
    cursor.execute("SELECT COUNT(*) FROM asistencia")
    asistencia = cursor.fetchone()[0]

    print(f"\n[SUCCESS] Data loaded successfully!")
    print(f"  Alumnos: {alumnos}")
    print(f"  Profesores: {profesores}")
    print(f"  Sesiones: {sesiones}")
    print(f"  Eventos: {eventos}")
    print(f"  Asistencia: {asistencia}")

    cursor.close()
    conn.close()

except Exception as e:
    print(f"ERROR: {e}")
    sys.exit(1)
