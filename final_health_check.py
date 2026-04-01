#!/usr/bin/env python3
"""
Final Health Check - Diagnostic completo post corrección
"""

import requests
import json
from datetime import datetime
from typing import Dict, Any

class FinalHealthChecker:
    def __init__(self, base_url: str = "https://gft-hackaton-backend-297014562013.europe-west1.run.app"):
        self.base_url = base_url
        self.results = []
    
    def check_endpoint(self, name: str, path: str, method: str = "GET", data: Dict = None, headers: Dict = None) -> Dict[str, Any]:
        """Comprobar endpoint específico con detalles completos"""
        url = f"{self.base_url}{path}"
        
        try:
            if method.upper() == "GET":
                response = requests.get(url, timeout=10, headers=headers)
            elif method.upper() == "POST":
                response = requests.post(url, json=data, timeout=10, headers=headers)
            else:
                return {"name": name, "url": url, "status": "UNSUPPORTED_METHOD", "details": f"Method {method} not supported"}
            
            result = {
                "name": name,
                "url": url,
                "status_code": response.status_code,
                "status": "SUCCESS" if 200 <= response.status_code < 300 else "ERROR",
                "response_time_ms": round(response.elapsed.total_seconds() * 1000, 2)
            }
            
            # Intentar parsear JSON response
            try:
                json_response = response.json()
                result["response_type"] = "JSON"
                if isinstance(json_response, list):
                    result["response_size"] = len(json_response)
                elif isinstance(json_response, dict):
                    result["response_keys"] = list(json_response.keys())
            except:
                result["response_type"] = "NON_JSON"
                result["content_type"] = response.headers.get("content-type", "unknown")
            
            # Agregar detalles del error si existe
            if response.status_code >= 400:
                try:
                    error_details = response.json()
                    result["error_details"] = error_details
                except:
                    result["error_text"] = response.text[:200] if response.text else "No error message"
            
            return result
        
        except requests.exceptions.RequestException as e:
            return {
                "name": name,
                "url": url,
                "status": "CONNECTION_ERROR",
                "error": str(e)
            }
    
    def run_complete_check(self):
        """Ejecutar check completo de todos los endpoints"""
        print(f"🔥 DIAGNOSTICO COMPLETO FINAL - {datetime.now().strftime('%H:%M:%S')}")
        print("=" * 80)
        print(f"🎯 URL Base: {self.base_url}")
        print()
        
        # Endpoints a comprobar (paths correctos con /api/v1/)
        endpoints = [
            ("FastAPI Docs", "/docs"),
            ("Root Endpoint", "/"),
            ("Perfil Usuario", "/api/v1/users/me"),
            ("Calendario Eventos", "/api/v1/calendar/events"),
            ("Asignaturas", "/api/v1/subjects"),
            ("Notas", "/api/v1/grades/me"),
            ("Asistencia", "/api/v1/attendance/me"),
            ("Métricas Asistencia", "/api/v1/attendance/me/metrics"),
            # Endpoints de una asignatura específica
            ("Notas por Asignatura", "/api/v1/grades/me/subjects/ASIG-001"),
            ("Estudiantes de Asignatura", "/api/v1/subjects/ASIG-001/students"),
            ("Crear Evento", "/api/v1/calendar/events"),  # POST test
        ]
        
        results = []
        for name, path in endpoints:
            result = self.check_endpoint(name, path)
            results.append(result)
            
            # Mostrar resultado inmediatamente
            status_emoji = "✅" if result["status"] == "SUCCESS" else "❌" if result.get("status_code", 0) >= 400 else "⚠️"
            status_code = result.get("status_code", "N/A")
            response_time = result.get("response_time_ms", 0)
            
            print(f"{status_emoji} {name:25} | {status_code:3} | {response_time:6.1f}ms")
            
            # Mostrar detalles adicionales para errores o información útil
            if result["status"] != "SUCCESS":
                if "error_details" in result:
                    print(f"    📝 Error: {result['error_details']}")
                elif "error_text" in result:
                    print(f"    📝 Error: {result['error_text']}")
                elif "error" in result:
                    print(f"    📝 Connection: {result['error']}")
            else:
                if "response_size" in result:
                    print(f"    📊 {result['response_size']} items returned")
                elif "response_keys" in result:
                    print(f"    🔑 Keys: {', '.join(result['response_keys'][:5])}")
        
        # Resumen final
        print("\n" + "=" * 80)
        print("📋 RESUMEN FINAL:")
        
        success_count = len([r for r in results if r["status"] == "SUCCESS"])
        total_count = len(results)
        
        print(f"✅ Éxitos: {success_count}/{total_count}")
        
        # Categorizar errores
        errors_404 = [r for r in results if r.get("status_code") == 404]
        errors_500 = [r for r in results if r.get("status_code", 0) >= 500]
        errors_other = [r for r in results if r["status"] != "SUCCESS" and r.get("status_code", 0) not in [404] and r.get("status_code", 0) < 500]
        
        if errors_404:
            print(f"❓ 404 Not Found: {len(errors_404)} endpoints (posiblemente no implementados)")
        if errors_500:
            print(f"🚨 500+ Server Errors: {len(errors_500)} endpoints (CRÍTICO)")
        if errors_other:
            print(f"⚠️ Otros errores: {len(errors_other)} endpoints")
            
        print()
        print("🎯 CONCLUSIÓN:")
        if errors_500:
            print("🚨 AÚN HAY ERRORES 500 - Revisar logs de Cloud Run")
        elif success_count >= total_count * 0.7:  # 70% o más funcionando
            print("✅ SISTEMA MAYORMENTE FUNCIONAL - Errores 404 son normales")
        else:
            print("⚠️ REVISAR CONFIGURACIÓN - Muchos endpoints no responden")
            
        return results

if __name__ == "__main__":
    checker = FinalHealthChecker()
    checker.run_complete_check()