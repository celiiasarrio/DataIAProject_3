# DataIAProject_3

Aplicacion Campus Virtual EDEM con frontend React, backend FastAPI, agente IA y despliegue en Google Cloud Run.

## Estructura

- `frontend/`: aplicacion web React + Vite.
- `backend/`: API FastAPI, autenticacion, datos academicos, uploads y Cloud SQL.
- `agent/`: servicio del asistente IA del campus.
- `db/`: esquema SQL y datos iniciales.
- `terraform/`: infraestructura GCP.
- `.github/workflows/`: CI/CD con GitHub Actions.
- `docs/`: documentacion detallada.

## Requisitos

- Python 3.11
- Node.js 20
- Docker Desktop, necesario para construir imagenes de Cloud Run
- Google Cloud CLI (`gcloud`)
- Terraform, o el binario incluido en `terraform/terraform.exe`

## Validacion antes de subir cambios

```cmd
python -m compileall backend agent
cd frontend
npm run build
```

## Despliegue manual en GCP

Despliegue completo:

```cmd
deploy.cmd
```

Despliegue parcial:

```cmd
deploy-backend.cmd
deploy-agent.cmd
deploy-frontend.cmd
```

Infraestructura base sin servicios:

```cmd
infra.cmd
```

Cargar esquema y datos en Cloud SQL, solo si quieres recargar la base:

```cmd
load-db.cmd
```

Aviso: `db/datos.sql` puede hacer `TRUNCATE` antes de insertar datos. Usalo solo cuando quieras recargar datos de forma intencionada.

## CI/CD

El workflow `.github/workflows/deploy-cloud-run.yml` se ejecuta al hacer push a:

- `main`
- `celia`

Tambien puede ejecutarse manualmente desde GitHub Actions.

Mas detalle: [docs/ci-cd.md](docs/ci-cd.md)

## Documentacion

- [docs/ci-cd.md](docs/ci-cd.md): GitHub Actions y secrets.
- [docs/gcp-deploy.md](docs/gcp-deploy.md): despliegue manual en GCP.
- [docs/storage.md](docs/storage.md): uploads y Cloud Storage.

## Archivos sensibles

No commitear:

- `terraform/terraform.tfvars`
- `.env`
- `.env.local`
- claves JSON de GCP
- archivos `cicd-key.json` o similares

El repositorio incluye ejemplos:

- `.env.example`
- `backend/.env.example`
- `agent/.env.example`
- `agent/.env.cloudrun.example`
- `terraform/terraform.tfvars.example`
