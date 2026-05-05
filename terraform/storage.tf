# Cloud Storage bucket para uploads de archivos (avatares, CVs, documentos)
resource "google_storage_bucket" "uploads" {
  name          = "${var.app_name}-uploads"
  location      = var.region
  force_destroy = false

  uniform_bucket_level_access = false

  versioning {
    enabled = false
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = 90 # Eliminar archivos después de 90 días
    }
  }
}

# Hacer el bucket públicamente legible (para acceder a uploads vía URL)
resource "google_storage_bucket_iam_member" "uploads_public_read" {
  bucket = google_storage_bucket.uploads.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

# Permitir al backend escribir en el bucket
resource "google_storage_bucket_iam_member" "backend_write" {
  bucket = google_storage_bucket.uploads.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.backend_sa.email}"
}

# Permitir al frontend leer del bucket
resource "google_storage_bucket_iam_member" "frontend_read" {
  bucket = google_storage_bucket.uploads.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.frontend_sa.email}"
}
