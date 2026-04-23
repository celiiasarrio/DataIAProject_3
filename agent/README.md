# Agente Campus Virtual EDEM

Asistente personal para el campus virtual construido con **Google ADK** y preparado
para desplegar en **Vertex AI Agent Engine**. En esta primera fase (PoC local) el
agente corre en tu máquina y llama al backend FastAPI existente; Firestore y el
deploy a Agent Engine se añaden después.

## Arquitectura

```
Usuario (CLI)
  └─> run_local.py
        ├─ POST /api/v1/token               (login, obtiene JWT)
        ├─ GET  /api/v1/users/me            (role, nombre, id)
        └─ ADK Runner + InMemorySessionService
              └─ LlmAgent (gemini-2.5-flash)
                    └─ tools (httpx) ─> FastAPI backend con Bearer JWT
```

Los permisos reales los sigue aplicando FastAPI: el agente actúa **en nombre del
usuario** reenviando su JWT. Si un alumno pide algo que sólo puede hacer un
profesor, el agente se lo explica (prompt) y además el backend devolvería 403
(defense in depth).

## Estructura

```
agent/
├── agent.py              # LlmAgent con todas las tools registradas
├── prompts.py            # System instruction role-aware
├── config.py             # Settings (BACKEND_BASE_URL, modelo, Vertex/API key)
├── run_local.py          # CLI interactiva: login + chat
├── tools/
│   ├── http_client.py    # httpx client con JWT desde session state
│   ├── profile.py
│   ├── academic.py       # notas, asistencia, asignaturas
│   ├── scheduling.py     # calendario, tutorías, reservas
│   └── communication.py  # correos, notificaciones
├── requirements.txt
└── .env.example
```

## Puesta en marcha (PoC local)

### 1. Backend corriendo

En otra terminal, arranca el backend (`backend/` con su propio `.env` y base de
datos local). Debe responder en `http://localhost:8080`.

### 2. Credenciales del LLM

Tienes dos opciones para llamar a `gemini-2.5-flash`:

**Opción A — Vertex AI** (recomendada, ya estás en GCP):

```bash
gcloud auth application-default login
gcloud config set project edem-hackathon-2026
```

Y en el `.env` del agente:
```
GOOGLE_GENAI_USE_VERTEXAI=TRUE
GOOGLE_CLOUD_PROJECT=edem-hackathon-2026
GOOGLE_CLOUD_LOCATION=europe-west1
```

**Opción B — Gemini API** (más rápido para arrancar, sólo para local):

```
GOOGLE_GENAI_USE_VERTEXAI=FALSE
GOOGLE_API_KEY=tu-api-key
```

### 3. Instalar dependencias

```bash
cd agent
cp .env.example .env        # y edítalo
pip install -r requirements.txt
```

### 4. Ejecutar

Desde la raíz del repo:

```bash
python -m agent.run_local
```

Te pedirá email + contraseña de un usuario del campus. A partir de ahí, chat
libre. Escribe `salir` para terminar.

## Ejemplos de conversación

**Alumno:**
- "¿Cómo voy de asistencia?"
- "Dame mis notas de la asignatura ASIG01"
- "¿Qué tutorías tiene disponibles el profesor X el jueves?"
- "Resérvame la franja FRANJA_ID el día 2026-05-10"

**Profesor:**
- "Ponle un 8.5 al alumno A001 en la tarea 17"
- "Crea una franja de tutoría los miércoles de 10:00 a 11:00 en el aula 3"
- "Confirma la reserva RESERV_ID"

**Coordinador:**
- "Dame la asistencia de la asignatura ASIG01"
- "¿Qué alumnos hay matriculados en ASIG02?"

## Mapa de tools

| Tool | Endpoint | Roles |
|---|---|---|
| `get_my_profile` | `GET /users/me` | todos |
| `update_my_profile` | `PUT /users/me` | todos |
| `get_user_by_id` | `GET /users/{id}` | todos |
| `list_subjects` / `get_subject_detail` | `/subjects*` | todos |
| `list_students_in_subject` | `GET /subjects/{id}/students` | profesor, coordinador |
| `get_my_grades` / `get_my_grades_for_subject` | `/grades/me*` | alumno |
| `register_grade` / `update_grade` | `/grades*` | profesor |
| `get_my_attendance` / `get_my_attendance_metrics` | `/attendance/me*` | alumno |
| `mark_attendance` | `POST /attendance` | profesor |
| `get_subject_attendance` | `GET /attendance/subjects/{id}` | profesor, coordinador |
| `list_calendar_events` / `get_event_detail` | `/calendar/events*` | todos |
| `create_calendar_event` / `update_calendar_event` / `delete_calendar_event` | `/calendar/events*` | profesor, coordinador |
| `list_tutoring_slots` | `GET /tutorings/slots` | todos |
| `create_tutoring_slot` | `POST /tutorings/slots` | profesor |
| `list_my_reservations` | `GET /reservations` | alumno, profesor |
| `request_tutoring` | `POST /reservations` | alumno |
| `update_reservation_status` | `PUT /reservations/{id}` | profesor |
| `list_notifications` / `mark_notification_read` / `get_notification_settings` | `/notifications*` | todos |
| `list_emails` / `read_email` / `send_email` | `/emails*` | todos |

## Gaps detectados en el backend (para fases siguientes)

- **No existe `POST /notifications`**: el coordinador no puede "broadcast"ear
  notificaciones hasta que se añada un endpoint.
- **No hay endpoint de tareas** (solo de notas): no se pueden listar las
  `tareas` de una asignatura.
- Varios endpoints de escritura (`POST /attendance`, `POST /tutorings/slots`,
  `POST /calendar/events`, `POST /grades`) **no validan el rol del usuario
  autenticado**. El agente lo controla por prompt, pero conviene reforzar en
  FastAPI antes de producción.

## Próximas fases

1. **Firestore**: memoria conversacional y preferencias del usuario.
2. **Terraform**: DB Firestore nativa + APIs (Vertex AI).
3. **Deploy a Vertex AI Agent Engine** (`deploy.py`).
4. **Backend**: endpoint `POST /api/v1/agent/chat` que proxee al Agent Engine
   reenviando el JWT del usuario.
5. **Frontend**: conectar `ChatScreen.tsx` al endpoint del agente con streaming.
