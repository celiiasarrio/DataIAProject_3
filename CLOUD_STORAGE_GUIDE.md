# Guía de Google Cloud Storage para Producción

## Descripción

Por defecto, el backend almacena los uploads (avatares, CVs, documentos) en el sistema de archivos local. Para producción en GCP, se recomienda usar **Google Cloud Storage (GCS)**.

## Configuración actual

- **En desarrollo local**: Usa `/app/uploads` (sistema de archivos)
- **En Cloud Run (GCP)**: Puede usar GCS con ajustes en el código

## Implementación de Google Cloud Storage

### Paso 1: Instalar dependencias

Agregar a `backend/requirements.txt`:
```
google-cloud-storage==2.14.0
```

### Paso 2: Crear adaptador para GCS

Crear archivo `backend/gcs_storage.py`:

```python
import os
from pathlib import Path
from typing import Optional
from google.cloud import storage
from fastapi import UploadFile

class CloudStorageManager:
    def __init__(self, bucket_name: str):
        self.client = storage.Client()
        self.bucket = self.client.bucket(bucket_name)
        self.bucket_name = bucket_name
    
    def upload_file(self, file: UploadFile, path: str) -> str:
        """Subir archivo a Cloud Storage y retornar la URL pública"""
        blob = self.bucket.blob(path)
        blob.upload_from_string(
            file.file.read(),
            content_type=file.content_type
        )
        # Retornar URL pública
        return f"gs://{self.bucket_name}/{path}"
    
    def delete_file(self, gs_path: str) -> None:
        """Eliminar archivo de Cloud Storage"""
        if gs_path.startswith("gs://"):
            # Extraer el path del gs:// URI
            path = gs_path.replace(f"gs://{self.bucket_name}/", "")
            blob = self.bucket.blob(path)
            blob.delete()
    
    def get_public_url(self, gs_path: str) -> str:
        """Convertir gs:// URI a URL HTTPS pública"""
        if gs_path.startswith("gs://"):
            path = gs_path.replace(f"gs://{self.bucket_name}/", "")
            return f"https://storage.googleapis.com/{self.bucket_name}/{path}"
        return gs_path
```

### Paso 3: Modificar main.py para usar GCS

En `backend/main.py`:

```python
import os
from gcs_storage import CloudStorageManager

# Detectar si estamos en GCP
USE_CLOUD_STORAGE = os.getenv("USE_CLOUD_STORAGE", "false").lower() == "true"
GCS_BUCKET = os.getenv("GCS_BUCKET", "")

if USE_CLOUD_STORAGE and GCS_BUCKET:
    storage_manager = CloudStorageManager(GCS_BUCKET)
else:
    storage_manager = None

# ... resto del código

def store_upload(user_id: str, file: UploadFile, folder: str, basename: str, ext: str) -> str:
    """Almacenar archivo en GCS o filesystem local"""
    document_id = uuid.uuid4().hex
    filename = f"{basename}-{document_id}.{ext}"
    path = f"profiles/{user_id}/{folder}/{filename}"
    
    if storage_manager:
        # Usar GCS
        url = storage_manager.upload_file(file, path)
        # Convertir a URL HTTPS pública
        return storage_manager.get_public_url(url)
    else:
        # Usar filesystem local (existente)
        local_path = UPLOAD_ROOT / "profiles" / user_id / folder
        local_path.mkdir(parents=True, exist_ok=True)
        filepath = local_path / filename
        with open(filepath, "wb") as f:
            f.write(file.file.read())
        return f"{PUBLIC_UPLOAD_PREFIX}/profiles/{user_id}/{folder}/{filename}"

def delete_public_upload(url: Optional[str]) -> None:
    """Eliminar archivo de GCS o filesystem local"""
    if not url:
        return
    
    if storage_manager and url.startswith("gs://"):
        storage_manager.delete_file(url)
    else:
        # Usar filesystem local (existente)
        if url.startswith("http"):
            return  # No eliminar URLs externas
        target = (UPLOAD_ROOT / url.removeprefix(f"{PUBLIC_UPLOAD_PREFIX}/")).resolve()
        if UPLOAD_ROOT.resolve() in target.parents and target.exists():
            target.unlink()
```

### Paso 4: Actualizar Cloud Run en Terraform

En `terraform/cloudrun.tf`, agregar variables de entorno para el backend:

```hcl
env {
  name  = "USE_CLOUD_STORAGE"
  value = "true"
}

env {
  name  = "GCS_BUCKET"
  value = google_storage_bucket.uploads.name
}
```

### Paso 5: Configurar permisos de IAM

El service account del backend necesita permisos para acceder a Cloud Storage. El archivo `terraform/storage.tf` ya está configurado para esto.

## Desarrollo local con GCS

Para desarrollar localmente usando GCS:

1. Crear una cuenta de servicio en GCP
2. Descargar la clave JSON
3. Configurar la variable de entorno:
   ```bash
   export GOOGLE_APPLICATION_CREDENTIALS="/path/to/service-account-key.json"
   ```
4. Agregar a `.env`:
   ```
   USE_CLOUD_STORAGE=true
   GCS_BUCKET=project3grupo6-uploads
   ```
5. Ejecutar: `docker-compose up`

## Alternativa: Usar Cloud Storage con Cloud Run sin modificar código

Si se quiere usar Cloud Storage sin modificar el código Python, se puede:

1. Montar el bucket de GCS como un filesystem virtual en Cloud Run
2. Usar el conector de Cloud Storage de Google

Sin embargo, la implementación anterior es más flexible y recomendada.

## URLs públicas

Con GCS, las URLs de los uploads tendrán el formato:
```
https://storage.googleapis.com/project3grupo6-uploads/profiles/user_id/avatar/file-hash.jpg
```

En lugar de:
```
http://localhost:8080/uploads/profiles/user_id/avatar/file-hash.jpg
```

El código frontend ya está configurado para manejar URLs externas en la función `assetUrl()`.

## Monitoreo

Monitorear el uso de GCS en:
- Cloud Console → Cloud Storage → Metrics
- Puede configurar alertas para el costo

## Seguridad

- El bucket está configurado como público (lectura pública, escritura solo por el backend)
- Los archivos tienen ciclo de vida de 90 días (se eliminan automáticamente)
- Usar HTTPS siempre para acceder a los archivos
- Considerar usar signed URLs para más seguridad si es necesario

## Costos

- Almacenamiento: $0.020 USD/GB/mes (almacenamiento en EU)
- Transacciones: $0.01 USD/10,000 PUT (escrituras)
- Egreso de datos: $0.12 USD/GB (primeros 1 TB)

Para la mayoría de aplicaciones pequeñas, el costo será mínimo (< $1 USD/mes).
