# Despliegue en GCP con Terraform

Este documento describe cómo desplegar la aplicación EDEM DataIA en Google Cloud Platform usando Terraform.

## Requisitos previos

1. Cuenta de Google Cloud Platform (GCP)
2. `gcloud` CLI instalado y configurado
3. `terraform` instalado (>= 1.0)
4. `docker` instalado (para construir las imágenes)
5. Permisos en el proyecto GCP para crear recursos

## Paso 1: Configurar autenticación en GCP

```bash
# Autenticarse en GCP
gcloud auth login

# Establecer el proyecto GCP
gcloud config set project project3grupo6

# Habilitar las APIs necesarias
gcloud services enable \
  compute.googleapis.com \
  cloudsql.googleapis.com \
  run.googleapis.com \
  artifact-registry.googleapis.com \
  storage.googleapis.com \
  firestore.googleapis.com
```

## Paso 2: Crear bucket de Terraform State

```bash
# Crear bucket para almacenar el estado de Terraform
gsutil mb gs://project3grupo6-tfstate

# Configurar el versionado del bucket
gsutil versioning set on gs://project3grupo6-tfstate
```

## Paso 3: Configurar Terraform

```bash
cd terraform

# Inicializar Terraform
terraform init

# Ver el plan (sin aplicar cambios)
terraform plan -var-file="terraform.tfvars"
```

## Paso 4: Crear archivo de variables

Crear un archivo `terraform.tfvars` con las variables necesarias:

```hcl
project_id       = "project3grupo6"
app_name         = "project3grupo6"
region           = "europe-west1"
db_region        = "europe-southwest1"
db_instance_name = "project3grupo6-postgres"
db_name          = "edem_hub_db"
db_user          = "postgres"
db_password      = "TU_CONTRASEÑA_SEGURA_AQUI"
jwt_secret       = "TU_JWT_SECRET_SEGURO_AQUI"
cicd_sa_email    = "tu-service-account@project3grupo6.iam.gserviceaccount.com"
```

## Paso 5: Construir y pushear imágenes a Artifact Registry

```bash
# Configurar Docker para usar Artifact Registry
gcloud auth configure-docker europe-west1-docker.pkg.dev

# Construir imagen del backend
docker build -f backend/Dockerfile -t europe-west1-docker.pkg.dev/project3grupo6/docker-repo/backend:latest ./backend

# Construir imagen del frontend
docker build -f frontend/Dockerfile -t europe-west1-docker.pkg.dev/project3grupo6/docker-repo/frontend:latest ./frontend

# Construir imagen del agente (si existe)
docker build -f agent/Dockerfile -t europe-west1-docker.pkg.dev/project3grupo6/docker-repo/agent:latest ./agent

# Pushear las imágenes
docker push europe-west1-docker.pkg.dev/project3grupo6/docker-repo/backend:latest
docker push europe-west1-docker.pkg.dev/project3grupo6/docker-repo/frontend:latest
docker push europe-west1-docker.pkg.dev/project3grupo6/docker-repo/agent:latest
```

## Paso 6: Aplicar la configuración de Terraform

```bash
cd terraform

# Aplicar los cambios
terraform apply -var-file="terraform.tfvars"

# Guardar los outputs importantes
terraform output > outputs.txt
```

## Paso 7: Inicializar la base de datos

Una vez que Cloud SQL está disponible, inicializar la base de datos:

```bash
# Obtener la IP de Cloud SQL
CLOUDSQL_IP=$(terraform output -raw database_ip)

# Conectarse a la BD y ejecutar los scripts SQL
psql -h $CLOUDSQL_IP -U postgres -d edem_hub_db < db/esquema.sql
psql -h $CLOUDSQL_IP -U postgres -d edem_hub_db < db/datos.sql
```

## Paso 8: Actualizar variables de entorno en Cloud Run

Las variables de entorno ya están configuradas por Terraform, pero se pueden actualizar manualmente:

```bash
# Para el backend
gcloud run services update project3grupo6-backend \
  --region=europe-west1 \
  --set-env-vars=ENVIRONMENT=production,JWT_SECRET=tu_secreto

# Para el frontend
gcloud run services update project3grupo6-frontend \
  --region=europe-west1 \
  --set-env-vars=VITE_BACKEND_URL=https://project3grupo6-backend-xxxxx.run.app

# Para el agente
gcloud run services update project3grupo6-agent \
  --region=europe-west1 \
  --set-env-vars=BACKEND_BASE_URL=https://project3grupo6-backend-xxxxx.run.app
```

## Configuración de CORS para el frontend

El backend necesita estar configurado con CORS para permitir solicitudes del frontend:

```python
# En backend/main.py (ya está configurado)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # En producción, especificar la URL del frontend
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

## Gestionar la infraestructura

### Ver el estado actual
```bash
terraform show
```

### Actualizar la infraestructura
```bash
# Ver qué cambiaría
terraform plan -var-file="terraform.tfvars"

# Aplicar cambios
terraform apply -var-file="terraform.tfvars"
```

### Destruir la infraestructura (con cuidado)
```bash
terraform destroy -var-file="terraform.tfvars"
```

## Troubleshooting

### La BD no se conecta desde Cloud Run

1. Verificar que el Cloud SQL Proxy está activo
2. Verificar los permisos de IAM de la service account del backend
3. Revisar los logs de Cloud Run: `gcloud run logs read project3grupo6-backend --region=europe-west1`

### Las imágenes no se encuentran en Artifact Registry

1. Verificar que se han pusheado correctamente: `gcloud container images list --repository-format=docker --repository=europe-west1-docker.pkg.dev/project3grupo6/docker-repo`
2. Verificar los permisos del usuario en Artifact Registry

### Cloud Storage no es accesible

1. Verificar que el bucket existe: `gsutil ls gs://project3grupo6-uploads/`
2. Verificar que el backend tiene permisos para escribir: `gsutil iam ch serviceAccount:project3grupo6-backend-sa@project3grupo6.iam.gserviceaccount.com:objectAdmin gs://project3grupo6-uploads`

## URLs de acceso

Una vez desplegado, acceder a la aplicación en:

- Frontend: `https://project3grupo6-frontend-xxxxx.run.app`
- Backend API: `https://project3grupo6-backend-xxxxx.run.app/docs`
- Agente: `https://project3grupo6-agent-xxxxx.run.app`

## Monitoreo

Usar Cloud Logging y Cloud Monitoring en GCP para monitorear la aplicación:

```bash
# Ver logs del backend
gcloud run logs read project3grupo6-backend --region=europe-west1 --limit=50

# Ver logs del frontend
gcloud run logs read project3grupo6-frontend --region=europe-west1 --limit=50
```

## Seguridad

1. Cambiar el `JWT_SECRET` por un valor seguro en `terraform.tfvars`
2. Cambiar la contraseña de la BD en `terraform.tfvars`
3. Usar Secret Manager de GCP para secretos sensibles
4. Restringir acceso público solo a las URLs necesarias
5. Configurar CORS correctamente en producción

## Notas importantes

- El backend está configurado para usar Cloud SQL Proxy automáticamente en Cloud Run
- Los uploads se almacenan en Cloud Storage y son públicamente accesibles (sin autenticación)
- Firestore se crea pero no se usa actualmente en la aplicación
- Todos los servicios se autoescalan de 0 a 1 instancia
