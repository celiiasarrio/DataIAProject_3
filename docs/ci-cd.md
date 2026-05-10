# CI/CD con GitHub Actions y Cloud Run

El despliegue automatico esta definido en:

```text
.github/workflows/deploy-cloud-run.yml
```

## Cuando se ejecuta

Se ejecuta automaticamente con push a:

- `main`
- `celia`

Tambien se puede lanzar manualmente:

```text
GitHub -> Actions -> Deploy Cloud Run -> Run workflow
```

## Que hace el workflow

1. Compila backend y agente con Python.
2. Instala dependencias del frontend con `npm ci`.
3. Compila el frontend con Vite.
4. Autentica contra GCP con una service account.
5. Construye y sube imagenes Docker a Artifact Registry:
   - `backend`
   - `agent`
   - `frontend`
6. Ejecuta Terraform.
7. Despliega backend, agente y frontend inicial.
8. Resuelve las URLs reales de Cloud Run.
9. Reconstruye el frontend con:
   - `VITE_BACKEND_URL`
   - `VITE_AGENT_URL`
10. Despliega el frontend final.
11. Comprueba que frontend, backend y agente responden.

El workflow no recarga `db/datos.sql`. La base de datos no se resetea en CI/CD.

## Secrets necesarios

En GitHub:

```text
Settings -> Secrets and variables -> Actions -> New repository secret
```

Secrets requeridos:

- `GCP_SA_KEY`: JSON completo de la service account de CI/CD.
- `GCP_CICD_SA_EMAIL`: email de la service account.
- `DB_USER`: usuario de Cloud SQL.
- `DB_PASSWORD`: password de Cloud SQL.
- `JWT_SECRET`: secreto JWT del backend.

## Service account de CI/CD

Crear la service account:

```cmd
gcloud iam service-accounts create project3grupo6-cicd --display-name "Project3Grupo6 CI/CD"
```

Consultar email:

```cmd
gcloud iam service-accounts list --filter="email:project3grupo6-cicd"
```

## Permisos necesarios

```cmd
gcloud projects add-iam-policy-binding project3grupo6 --member="serviceAccount:project3grupo6-cicd@project3grupo6.iam.gserviceaccount.com" --role="roles/artifactregistry.admin"
gcloud projects add-iam-policy-binding project3grupo6 --member="serviceAccount:project3grupo6-cicd@project3grupo6.iam.gserviceaccount.com" --role="roles/run.admin"
gcloud projects add-iam-policy-binding project3grupo6 --member="serviceAccount:project3grupo6-cicd@project3grupo6.iam.gserviceaccount.com" --role="roles/cloudsql.admin"
gcloud projects add-iam-policy-binding project3grupo6 --member="serviceAccount:project3grupo6-cicd@project3grupo6.iam.gserviceaccount.com" --role="roles/storage.admin"
gcloud projects add-iam-policy-binding project3grupo6 --member="serviceAccount:project3grupo6-cicd@project3grupo6.iam.gserviceaccount.com" --role="roles/serviceusage.serviceUsageAdmin"
gcloud projects add-iam-policy-binding project3grupo6 --member="serviceAccount:project3grupo6-cicd@project3grupo6.iam.gserviceaccount.com" --role="roles/iam.serviceAccountAdmin"
gcloud projects add-iam-policy-binding project3grupo6 --member="serviceAccount:project3grupo6-cicd@project3grupo6.iam.gserviceaccount.com" --role="roles/resourcemanager.projectIamAdmin"
```

Permiso para desplegar servicios que usan service accounts de Cloud Run:

```cmd
gcloud iam service-accounts add-iam-policy-binding project3grupo6-backend-sa@project3grupo6.iam.gserviceaccount.com --member="serviceAccount:project3grupo6-cicd@project3grupo6.iam.gserviceaccount.com" --role="roles/iam.serviceAccountUser"
gcloud iam service-accounts add-iam-policy-binding project3grupo6-agent-sa@project3grupo6.iam.gserviceaccount.com --member="serviceAccount:project3grupo6-cicd@project3grupo6.iam.gserviceaccount.com" --role="roles/iam.serviceAccountUser"
gcloud iam service-accounts add-iam-policy-binding project3grupo6-frontend-sa@project3grupo6.iam.gserviceaccount.com --member="serviceAccount:project3grupo6-cicd@project3grupo6.iam.gserviceaccount.com" --role="roles/iam.serviceAccountUser"
```

## Crear clave JSON

```cmd
gcloud iam service-accounts keys create cicd-key.json --iam-account=project3grupo6-cicd@project3grupo6.iam.gserviceaccount.com
```

Copiar el contenido completo de `cicd-key.json` en el secret `GCP_SA_KEY`.

Despues borrar el archivo local:

```cmd
del cicd-key.json
```

No commitear claves JSON.
