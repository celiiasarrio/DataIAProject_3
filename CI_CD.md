# CI/CD con GitHub Actions y Cloud Run

Este repo incluye el workflow:

`.github/workflows/deploy-cloud-run.yml`

Se ejecuta al hacer push a `main` o `celia`, y también manualmente desde
GitHub Actions con `workflow_dispatch`.

## Qué hace

1. Compila backend y agente con Python.
2. Compila el frontend con Vite.
3. Autentica contra GCP.
4. Construye y sube imágenes Docker a Artifact Registry:
   - `backend`
   - `agent`
   - `frontend`
5. Aplica Terraform para actualizar Cloud Run.
6. Reconstruye el frontend con las URLs reales de backend y agente.
7. Aplica Terraform de nuevo con la imagen final del frontend.
8. Comprueba `/health` de backend y agente y que el frontend responde.

No recarga `db/datos.sql`. La base de datos no se toca en CI/CD.

## Secrets necesarios en GitHub

En GitHub:

`Settings -> Secrets and variables -> Actions -> New repository secret`

Crea estos secrets:

- `GCP_SA_KEY`: JSON completo de la service account de CI/CD.
- `GCP_CICD_SA_EMAIL`: email de esa service account.
- `DB_USER`: usuario de Cloud SQL, por ejemplo `postgres`.
- `DB_PASSWORD`: password de Cloud SQL.
- `JWT_SECRET`: secreto JWT del backend.

## Crear service account de CI/CD

Ejecuta esto una vez en tu terminal autenticada con `gcloud`:

```cmd
gcloud iam service-accounts create project3grupo6-cicd --display-name "Project3Grupo6 CI/CD"
```

Guarda el email:

```cmd
gcloud iam service-accounts list --filter="email:project3grupo6-cicd"
```

## Permisos necesarios

Sustituye `PROJECT_NUMBER_OR_ID` si hiciera falta, pero con este proyecto debería
valer:

```cmd
gcloud projects add-iam-policy-binding project3grupo6 --member="serviceAccount:project3grupo6-cicd@project3grupo6.iam.gserviceaccount.com" --role="roles/artifactregistry.admin"
gcloud projects add-iam-policy-binding project3grupo6 --member="serviceAccount:project3grupo6-cicd@project3grupo6.iam.gserviceaccount.com" --role="roles/run.admin"
gcloud projects add-iam-policy-binding project3grupo6 --member="serviceAccount:project3grupo6-cicd@project3grupo6.iam.gserviceaccount.com" --role="roles/cloudsql.admin"
gcloud projects add-iam-policy-binding project3grupo6 --member="serviceAccount:project3grupo6-cicd@project3grupo6.iam.gserviceaccount.com" --role="roles/storage.admin"
gcloud projects add-iam-policy-binding project3grupo6 --member="serviceAccount:project3grupo6-cicd@project3grupo6.iam.gserviceaccount.com" --role="roles/serviceusage.serviceUsageAdmin"
gcloud projects add-iam-policy-binding project3grupo6 --member="serviceAccount:project3grupo6-cicd@project3grupo6.iam.gserviceaccount.com" --role="roles/iam.serviceAccountAdmin"
gcloud projects add-iam-policy-binding project3grupo6 --member="serviceAccount:project3grupo6-cicd@project3grupo6.iam.gserviceaccount.com" --role="roles/resourcemanager.projectIamAdmin"
```

Permiso para que CI/CD pueda desplegar servicios que usan las service accounts de
Cloud Run:

```cmd
gcloud iam service-accounts add-iam-policy-binding project3grupo6-backend-sa@project3grupo6.iam.gserviceaccount.com --member="serviceAccount:project3grupo6-cicd@project3grupo6.iam.gserviceaccount.com" --role="roles/iam.serviceAccountUser"
gcloud iam service-accounts add-iam-policy-binding project3grupo6-agent-sa@project3grupo6.iam.gserviceaccount.com --member="serviceAccount:project3grupo6-cicd@project3grupo6.iam.gserviceaccount.com" --role="roles/iam.serviceAccountUser"
gcloud iam service-accounts add-iam-policy-binding project3grupo6-frontend-sa@project3grupo6.iam.gserviceaccount.com --member="serviceAccount:project3grupo6-cicd@project3grupo6.iam.gserviceaccount.com" --role="roles/iam.serviceAccountUser"
```

## Crear la key JSON

```cmd
gcloud iam service-accounts keys create cicd-key.json --iam-account=project3grupo6-cicd@project3grupo6.iam.gserviceaccount.com
```

Copia el contenido completo de `cicd-key.json` en el secret `GCP_SA_KEY`.
Después borra el archivo local:

```cmd
del cicd-key.json
```

## Ejecutar

Haz push a la rama `celia` o ejecútalo manualmente en GitHub:

`Actions -> Deploy Cloud Run -> Run workflow`
