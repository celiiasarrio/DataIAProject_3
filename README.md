<div align="center">

# EDEM Student Hub

**Plataforma académica multi-rol con asistente conversacional integrado**

[![FastAPI](https://img.shields.io/badge/FastAPI-0.110-009688?style=flat-square&logo=fastapi&logoColor=white)](https://fastapi.tiangolo.com/)
[![React](https://img.shields.io/badge/React-18-61DAFB?style=flat-square&logo=react&logoColor=white)](https://react.dev/)
[![Vite](https://img.shields.io/badge/Vite-6-646CFF?style=flat-square&logo=vite&logoColor=white)](https://vitejs.dev/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-17-336791?style=flat-square&logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?style=flat-square&logo=docker&logoColor=white)](https://docs.docker.com/compose/)
[![Terraform](https://img.shields.io/badge/Terraform-GCP-7B42BC?style=flat-square&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Google ADK](https://img.shields.io/badge/Google_ADK-Gemini-4285F4?style=flat-square&logo=google&logoColor=white)](https://google.github.io/adk-docs/)

</div>

---

## Resumen

EDEM Student Hub es la plataforma web del Master MDA para gestionar la vida académica de hasta 3000 alumnos. Da soporte a cuatro roles (alumno, profesor, coordinador, director de área) sobre una API FastAPI con autenticación JWT, una SPA en React, y un agente conversacional basado en Google Gemini que hereda los permisos del usuario que lo invoca.

### Capacidades principales

- **Autenticación multi-rol** con bcrypt + JWT, control de acceso declarativo (`check_rol`).
- **API REST** completa con FastAPI + SQLAlchemy + Pydantic.
- **Frontend SPA** en React 18 + Vite + Tailwind, con vistas adaptadas a cada rol.
- **Agente conversacional** con Google ADK y Gemini, propagación del JWT del usuario para garantizar el aislamiento de datos.
- **Infraestructura como código** con Terraform sobre Google Cloud (Cloud Run, Cloud SQL, Firestore, Artifact Registry).

---

## Arquitectura y estructura

![Estructura del proyecto EDEM Student Hub](docs/diagrams/code-structure.svg)

---

## Stack tecnológico

| Capa | Tecnología | Función |
|------|-----------|---------|
| **Frontend** | React 18 · Vite · Tailwind · React Router 7 | Interfaz adaptada por rol |
| **Backend** | FastAPI · SQLAlchemy · Pydantic v2 | API REST + RBAC |
| **Autenticación** | bcrypt · python-jose (JWT) | Login seguro y permisos |
| **Base de datos** | PostgreSQL 17 · pgcrypto | Datos académicos |
| **Agente IA** | Google ADK · Gemini · Vertex AI | Asistente conversacional |
| **Local** | Docker Compose | Entorno de desarrollo |
| **Producción** | Terraform · Cloud Run · Cloud SQL · Firestore | Despliegue en GCP |

---

## Tabla de contenidos

- [Requisitos](#requisitos)
- [Arranque rápido](#arranque-rápido)
- [Usuarios de prueba](#usuarios-de-prueba)
- [Verificación](#verificación)
- [Despliegue en Google Cloud](#despliegue-en-google-cloud)
- [Solución de problemas](#solución-de-problemas)

---

## Requisitos

| Herramienta | Versión mínima | Necesaria para |
|-------------|---------------|----------------|
| [Docker Desktop](https://www.docker.com/products/docker-desktop/) | 4.x con `docker compose` | Backend y base de datos |
| [Node.js](https://nodejs.org/) | 18 LTS | Frontend |
| [Git](https://git-scm.com/) | cualquiera | Control de versiones |
| [gcloud CLI](https://cloud.google.com/sdk/docs/install) | última | Despliegue (opcional) |
| [Terraform](https://developer.hashicorp.com/terraform/install) | 1.0+ | Despliegue (opcional) |

---

## Arranque rápido

### 1. Backend y base de datos

Desde la raíz del repositorio:

```bash
docker compose up -d
```

Esto levanta dos contenedores:

- `postgres` en el puerto **5432**
- `backend` (FastAPI) en el puerto **8080**

La primera ejecución construye las imágenes y carga los seeds de la base de datos. Las siguientes arrancan en segundos.

### 2. Frontend

```bash
cd frontend
npm install --legacy-peer-deps
```

Crea el archivo `frontend/.env.local` con la URL del backend:

```env
VITE_BACKEND_URL=http://localhost:8080
```

Inicia el servidor de desarrollo:

```bash
npm run dev
```

La aplicación queda disponible en `http://localhost:5173`.

---

## Usuarios de prueba

Las contraseñas viven en texto plano en `db/init_db_v4.sql` y se hashean con bcrypt al arrancar Postgres mediante `init_db_v6_users.sql`.

| Rol | Correo | Contraseña | Vista al iniciar sesión |
|-----|--------|-----------|------------------------|
| **Alumno** | `ahsoka.tano@edem.es` | `demo123` | Notas, asistencia, calendario propio, chat con el agente |
| **Profesor** | `adrian.colomer@seed.local` | `prof123` | Gestión de notas, asistencia por sesión, sus grupos |
| **Coordinador** | `andrea.soler@edem.es` | `staff123` | Vista global del área, gestión académica |

> El frontend persiste el rol en `localStorage` y los componentes adaptan su contenido. Para cambiar de cuenta, cierra sesión desde el menú de perfil.

> **Opcional** — si prefieres una contraseña única `demo` para las tres cuentas:
> ```bash
> docker compose exec postgres psql -U postgres -d edem_hub_db -c \
>   "UPDATE users SET password_hash = crypt('demo', gen_salt('bf')) \
>    WHERE email IN ('ahsoka.tano@edem.es','adrian.colomer@seed.local','andrea.soler@edem.es');"
> ```
> Tendrás que repetirlo si ejecutas `docker compose down -v`.

---

## Verificación

Comprueba que los servicios están operativos:

```bash
docker compose ps
```

| Servicio | Estado esperado |
|----------|-----------------|
| `postgres` | `Up (healthy)` |
| `backend` | `Up` |

Verifica que los seeds se han cargado correctamente:

```bash
docker compose exec postgres psql -U postgres -d edem_hub_db -c \
  "SELECT 'alumnos:'||COUNT(*) FROM alumnos
   UNION ALL SELECT 'profesores:'||COUNT(*) FROM profesores
   UNION ALL SELECT 'coordinadores:'||COUNT(*) FROM coordinadores
   UNION ALL SELECT 'users:'||COUNT(*) FROM users;"
```

| Tabla | Filas esperadas |
|-------|----------------|
| `alumnos` | 8 |
| `profesores` | 6 |
| `coordinadores` | 2 |
| `users` | 16 |

Abre `http://localhost:5173`, autentícate con cualquiera de los usuarios de prueba y confirma que el dashboard se carga correctamente.

---

## Despliegue en Google Cloud

![Arquitectura en GCP](docs/diagrams/gcp-stack.svg)

La infraestructura está completamente definida en `terraform/`. El estado vive en un bucket de Cloud Storage (`gft-hackaton-tfstate-26`) compartido por todo el equipo.

### 1. Autenticación en GCP

```bash
gcloud auth login
gcloud auth application-default login
gcloud config set project edem-hackathon-2026
```

| Comando | Para qué sirve |
|---------|---------------|
| `gcloud auth login` | Identifica al usuario en `gcloud` |
| `gcloud auth application-default login` | Genera credenciales para Terraform y librerías de Google |
| `gcloud config set project` | Fija el proyecto activo |

### 2. Configurar variables sensibles

Crea `terraform/terraform.tfvars` (este archivo está en `.gitignore`):

```hcl
db_user       = "edem_admin"
db_password   = "una-contrasena-fuerte"
jwt_secret    = "un-secreto-largo-y-aleatorio"
cicd_sa_email = "github-actions@edem-hackathon-2026.iam.gserviceaccount.com"
```

### 3. Desplegar

```bash
./deploy.sh
```

El script ejecuta, en orden:

1. Configuración de Docker para Artifact Registry.
2. Creación del repositorio de imágenes con `terraform apply -target`.
3. Construcción y publicación de la imagen del frontend.
4. Aplicación del resto de la infraestructura.
5. Salida con la URL pública del frontend.

### 4. Obtener las URLs públicas

```bash
terraform -chdir=terraform output frontend_url
terraform -chdir=terraform output backend_url
```

### Apagar la infraestructura

Para evitar costes cuando no se utiliza:

```bash
terraform -chdir=terraform destroy
```

> **Nota**: El script `deploy.sh` actualmente solo construye y publica la imagen del frontend. Si has modificado el backend, ejecuta antes de `./deploy.sh`:
>
> ```bash
> docker build -t europe-west1-docker.pkg.dev/edem-hackathon-2026/gft-hackaton/backend:latest ./backend
> docker push europe-west1-docker.pkg.dev/edem-hackathon-2026/gft-hackaton/backend:latest
> ```

---

## Solución de problemas

| Síntoma | Causa probable | Solución |
|---------|---------------|----------|
| `docker compose up` falla | Docker Desktop apagado o puertos `5432` / `8080` ocupados | Abre Docker Desktop y libera los puertos |
| Backend en `Restarting` | Error de Python o de conexión a la base de datos | `docker compose logs backend` |
| Login devuelve 401 | La contraseña ya no es `demo` (volumen recreado) | Ejecuta de nuevo el `UPDATE` de usuarios |
| Frontend sin datos | `frontend/.env.local` mal configurado | Verifica `VITE_BACKEND_URL=http://localhost:8080` |
| Errores de CORS | Vite arrancó en un puerto distinto a `5173` | Cierra el proceso y relanza `npm run dev` |
| Terraform: *project not found* | Falta el `gcloud config set project` | Repite el paso 1 del despliegue |
| Terraform: *insufficient permissions* | Tu cuenta no tiene rol `Editor` u `Owner` en el proyecto | Solicita el rol al administrador |
| `Cloud SQL` tarda en crearse | Es normal en la primera ejecución | Espera 5-10 minutos |

---

<div align="center">

Master en Data Analytics, IA y Big Data · EDEM 2025-26

</div>
