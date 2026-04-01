#!/usr/bin/env python3
"""
Quick Error Diagnostic - Identificar errores específicos rápidamente
"""

import requests
from datetime import datetime

BASE_URL = "https://gft-hackaton-backend-297014562013.europe-west1.run.app"

def quick_test_endpoint(endpoint: str, name: str) -> None:
    """Test rápido de endpoint con timeout corto"""
    try:
        print(f"🔍 {name}:", end=" ", flush=True)
        response = requests.get(f"{BASE_URL}{endpoint}", timeout=3)
        
        if response.status_code == 200:
            print(f"✅ OK ({response.status_code})")
        elif response.status_code in [401, 403]:
            print(f"⚠️ AUTH REQUIRED ({response.status_code}) - Normal")
        elif response.status_code == 404:
            print(f"❌ NOT FOUND ({response.status_code})")
        elif response.status_code == 500:
            print(f"🚨 SERVER ERROR ({response.status_code})")
            try:
                error_data = response.json()
                if "detail" in error_data:
                    print(f"    💥 Error: {error_data['detail']}")
                else:
                    print(f"    💥 Error: {error_data}")
            except:
                print(f"    💥 Error: {response.text[:100]}...")
        else:
            print(f"❓ HTTP {response.status_code}")
            
    except requests.exceptions.Timeout:
        print("⏰ TIMEOUT (>3s)")
    except requests.exceptions.ConnectionError:
        print("🔌 CONNECTION FAILED")
    except Exception as e:
        print(f"💥 ERROR: {str(e)[:50]}")

def main():
    print(f"🔥 Quick Error Diagnostic - {datetime.now().strftime('%H:%M:%S')}")
    print("=" * 60)
    print(f"🎯 URL: {BASE_URL}")
    print()
    
    # Test servidor básico
    print("📡 SERVIDOR:")
    quick_test_endpoint("/docs", "FastAPI Docs")
    quick_test_endpoint("/", "Root Endpoint")
    print()
    
    # Test endpoints principales
    print("⚡ API ENDPOINTS:")
    endpoints = [
        ("/api/v1/users/me", "Perfil usuario"),
        ("/api/v1/calendar/events", "Calendario"),
        ("/api/v1/subjects", "Asignaturas"),
        ("/api/v1/grades/me", "Notas"),
        ("/api/v1/attendance/me", "Asistencia"),
        ("/api/v1/attendance/me/metrics", "Métricas asistencia"),
    ]
    
    for endpoint, name in endpoints:
        quick_test_endpoint(endpoint, name)
    
    print()
    print("=" * 60)

if __name__ == "__main__":
    main()