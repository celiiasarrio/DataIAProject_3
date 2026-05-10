# Uploads y Cloud Storage

Los uploads de produccion se almacenan en Google Cloud Storage desde Cloud Run.

## Configuracion en Cloud Run

En Cloud Run, Terraform configura el backend con:

```text
UPLOAD_ROOT=gs://<bucket>/uploads
PUBLIC_UPLOAD_PREFIX=https://storage.googleapis.com/<bucket>/uploads
```

El bucket se define en:

```text
terraform/storage.tf
```

Recurso principal:

```text
google_storage_bucket.uploads
```

## Permisos

Terraform configura:

- lectura publica para poder servir uploads por URL
- escritura del backend con `roles/storage.objectAdmin`
- lectura del frontend con `roles/storage.objectViewer`

## Ciclo de vida

Los objetos del bucket se eliminan automaticamente tras 90 dias:

```hcl
lifecycle_rule {
  action {
    type = "Delete"
  }
  condition {
    age = 90
  }
}
```

## Codigo relacionado

- `backend/main.py`: deteccion de `gs://`, subida y borrado de archivos.
- `backend/requirements.txt`: dependencia `google-cloud-storage`.
- `terraform/storage.tf`: bucket e IAM.
- `terraform/cloudrun.tf`: variables `UPLOAD_ROOT` y `PUBLIC_UPLOAD_PREFIX`.

## Notas

- No hace falta crear un adaptador adicional para GCS; el backend actual ya lo contempla.
- No guardar claves JSON de GCP dentro del repositorio.
- Si se cambia el bucket o prefijo publico, revisar tambien `PUBLIC_UPLOAD_PREFIX`.
