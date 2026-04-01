#!/usr/bin/env python3
"""
Investigador de errores Root y Perfil Usuario
"""

import psycopg2
import requests
from datetime import datetime

# Credenciales Cloud SQL
DB_CONFIG = {
    'host': '34.175.214.149',
    'port': 5432,
    'database': 'edem_hub_db',
    'user': 'edem_admin',
    'password': '%JYSZw%4?zdNLL^HfkFvwE;+vPC_y*'
}

BASE_URL = "https://gft-hackaton-backend-297014562013.europe-west1.run.app"

def investigate_database():
    """Investigar qué usuarios existen en la base de datos"""
    print("🔍 INVESTIGANDO BASE DE DATOS")
    print("=" * 50)
    
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        cursor = conn.cursor()
        
        # Verificar usuarios en cada tabla
        tables_queries = [
            ("Alumnos", "SELECT id_alumno, nombre, apellido FROM alumnos LIMIT 10"),
            ("Profesores", "SELECT id_profesor, nombre, apellido FROM profesores LIMIT 5"),
            ("Personal EDEM", "SELECT id_personal, nombre, apellido, rol FROM personal_edem LIMIT 5")
        ]
        
        found_a001 = False
        
        for table_name, query in tables_queries:
            print(f"\n📋 {table_name}:")
            cursor.execute(query)
            results = cursor.fetchall()
            
            if results:
                for row in results:
                    user_id = row[0]
                    name = f"{row[1] or ''} {row[2] or ''}".strip()
                    role_info = f" ({row[3]})" if len(row) > 3 and row[3] else ""
                    print(f"  • {user_id}: {name}{role_info}")
                    
                    if user_id == "A001":
                        found_a001 = True
                        print(f"    🎯 ¡ENCONTRADO! Usuario A001 existe como {table_name}")
            else:
                print(f"  • Sin registros")
        
        print(f"\n🔍 Usuario A001 {'✅ ENCONTRADO' if found_a001 else '❌ NO ENCONTRADO'}")
        
        # Buscar usuarios que empiecen con A001
        print(f"\n🔍 Buscando usuarios similares a A001:")
        cursor.execute("SELECT id_alumno, nombre, apellido FROM alumnos WHERE id_alumno LIKE 'A%' LIMIT 5")
        similar_alumnos = cursor.fetchall()
        
        if similar_alumnos:
            print("  Alumnos con ID similar:")
            for row in similar_alumnos:
                print(f"  • {row[0]}: {row[1]} {row[2]}")
        else:
            print("  • No hay alumnos con IDs que empiecen por 'A'")
            
        cursor.close()
        conn.close()
        
        return found_a001, similar_alumnos
        
    except Exception as e:
        print(f"❌ Error conectando a base de datos: {e}")
        return False, []

def test_root_endpoint():
    """Probar el endpoint root específicamente"""
    print("🏠 PROBANDO ROOT ENDPOINT")
    print("=" * 30)
    
    try:
        response = requests.get(f"{BASE_URL}/", timeout=5)
        print(f"Status: {response.status_code}")
        print(f"Response: {response.text[:200]}")
        
        if response.status_code == 404:
            print("✅ 404 es normal - Root endpoint no implementado")
        
    except Exception as e:
        print(f"❌ Error: {e}")

def test_profile_with_different_ids(user_ids):
    """Probar endpoint de perfil con diferentes IDs de usuario"""
    print("👤 PROBANDO PERFIL CON DIFERENTES IDs")
    print("=" * 40)
    
    for user_id, name, surname in user_ids[:3]:  # Probar solo los primeros 3
        print(f"\n🧪 Probando con user_id: {user_id} ({name} {surname})")
        
        try:
            # Simular una petición con header de autorización
            headers = {"Authorization": f"Bearer mock-token-{user_id}"}
            response = requests.get(f"{BASE_URL}/api/v1/users/me", headers=headers, timeout=5)
            
            print(f"   Status: {response.status_code}")
            if response.status_code != 200:
                try:
                    error_data = response.json()
                    print(f"   Error: {error_data}")
                except:
                    print(f"   Error text: {response.text[:100]}")
            else:
                data = response.json()
                print(f"   ✅ Success: {data.get('nombre')} {data.get('apellido')}")
                
        except Exception as e:
            print(f"   ❌ Connection error: {e}")

def main():
    print(f"🔍 INVESTIGADOR DE ERRORES - {datetime.now().strftime('%H:%M:%S')}")
    print("=" * 70)
    
    # 1. Investigar base de datos
    found_a001, similar_users = investigate_database()
    
    print("\n" + "=" * 70)
    
    # 2. Probar root endpoint
    test_root_endpoint()
    
    print("\n" + "=" * 70)
    
    # 3. Probar perfil con usuarios reales
    if similar_users:
        test_profile_with_different_ids(similar_users)
    
    print("\n" + "=" * 70)
    print("📊 CONCLUSIONES:")
    
    if not found_a001:
        print("❌ El backend usa ID 'A001' pero este usuario NO EXISTE en la BD")
        print("💡 SOLUCIÓN: Cambiar get_current_user_id() para usar un ID que exista")
    else:
        print("✅ Usuario A001 existe - El problema puede ser de autenticación")
        
    print("✅ Root endpoint 404 es normal - no está implementado")
    
if __name__ == "__main__":
    main()