# Despliegue en GCP

Esta guia resume el despliegue manual. Para CI/CD, ver [ci-cd.md](ci-cd.md).

## Recursos principales

Terraform crea y gestiona:

- Artifact Registry
- Cloud Run frontend
- Cloud Run backend
- Cloud Run agente
- Cloud SQL PostgreSQL
- Cloud Storage para uploads
- Firestore
- service accounts e IAM

## Requisitos

- `gcloud` autenticado
- Docker Desktop activo
- Terraform instalado o `terraform/terraform.exe`
- `terraform/terraform.tfvars` configurado

Ejemplo de `terraform.tfvars`:

```hcl
project_id       = "project3grupo6"
app_name         = "project3grupo6"
region           = "europe-west1"
db_region        = "europe-southwest1"
db_instance_name = "project3grupo6-postgres"
db_name          = "edem_hub_db"
db_user          = "postgres"
db_password      = "CAMBIAR"
jwt_secret       = "CAMBIAR"
cicd_sa_email    = "project3grupo6-cicd@project3grupo6.iam.gserviceaccount.com"
```

No commitear `terraform.tfvars`.

## Despliegue recomendado desde Windows

Desde la raiz del repositorio:

```cmd
deploy.cmd
```

Este script:

1. Configura Docker para Artifact Registry.
2. Inicializa Terraform.
3. Asegura Artifact Registry.
4. Construye y sube backend, agente y frontend.
5. Aplica Terraform.
6. Resuelve URLs reales de backend y agente.
7. Reconstruye frontend con esas URLs.
8. Aplica Terraform con la imagen final del frontend.

## Despliegues parciales

Backend:

```cmd
deploy-backend.cmd
```

Agente:

```cmd
deploy-agent.cmd
```

Frontend:

```cmd
deploy-frontend.cmd
```

## Infraestructura sin servicios

```cmd
infra.cmd
```

Usa `deploy_services=false` para preparar recursos base.

## Carga de base de datos

```cmd
load-db.cmd
```

Este script pide confirmacion manual y ejecuta:

- `db/esquema.sql`
- `db/datos.sql`

Aviso: `db/datos.sql` puede truncar tablas antes de insertar datos. No usarlo si quieres conservar cambios hechos directamente en Cloud SQL.

## Verificar Cloud SQL

```cmd
verify-db.cmd
```

Muestra un recuento estimado de filas por tabla.

## Destruir recursos

```cmd
destroy-cloud.cmd
```

Usarlo solo cuando se quiera destruir recursos gestionados por Terraform dentro del proyecto. No borra el proyecto GCP.
