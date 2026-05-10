# Agente Campus Virtual EDEM

Servicio FastAPI del asistente IA, desplegado en Cloud Run y consumido por el frontend.

## Funcionamiento

El frontend llama al agente en:

```text
POST /api/v1/agent/chat
```

El agente recibe el JWT del usuario, consulta el perfil en el backend y ejecuta herramientas contra la API respetando los permisos reales del backend.

## Archivos principales

- `service.py`: API HTTP del agente para Cloud Run.
- `agent.py`: definicion del `LlmAgent` y registro de herramientas.
- `prompts.py`: instrucciones del sistema, privacidad y limites de uso.
- `audit.py`: logs estructurados de uso del agente.
- `firestore_session_service.py`: persistencia de sesiones en Firestore.
- `tools/`: herramientas que llaman al backend.
- `smoke_test_agent.py`: prueba manual contra servicios desplegados.

## Variables de entorno en Cloud Run

Terraform configura las principales variables en `terraform/cloudrun.tf`:

- `BACKEND_BASE_URL`
- `GOOGLE_GENAI_USE_VERTEXAI`
- `GOOGLE_CLOUD_PROJECT`
- `GOOGLE_CLOUD_LOCATION`
- `MODEL`
- `HTTP_TIMEOUT_SECONDS`
- `FIRESTORE_PROJECT`
- `FIRESTORE_DATABASE`

## Verificacion en cloud

Healthcheck:

```cmd
curl https://URL_DEL_AGENT/health
```

Smoke test contra servicios desplegados:

```cmd
python agent\smoke_test_agent.py --backend-url https://URL_DEL_BACKEND --agent-url https://URL_DEL_AGENT
```

## Seguridad

- El agente no sustituye permisos del backend.
- Todas las llamadas a herramientas reenvian el JWT del usuario.
- Si el backend devuelve `403`, el agente no puede saltarse esa restriccion.
- Los logs de auditoria registran peticiones de chat, llamadas a herramientas y accesos denegados.
