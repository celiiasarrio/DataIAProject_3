# Service Account for frontend
resource "google_service_account" "frontend_sa" {
  account_id   = "hackaton-frontend-sa"
  display_name = "Service Account para Frontend Cloud Run"
}

# Service Account for backend
resource "google_service_account" "backend_sa" {
  account_id   = "hackaton-backend-sa"
  display_name = "Service Account para Backend Cloud Run"
}

# Service Account for Firestore
resource "google_service_account" "firestore_sa" {
  account_id   = "hackaton-firestore-sa"
  display_name = "Service Account para Firestore"
}

resource "google_cloud_run_v2_service" "frontend" {
  name     = "gft-hackaton-frontend"
  location = var.region
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {
    service_account = google_service_account.frontend_sa.email

    scaling {
      min_instance_count = 0
      max_instance_count = 1
    }

    containers {
      image = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.docker.repository_id}/frontend:latest"

      resources {
        limits = {
          cpu    = "1"
          memory = "512Mi"
        }
      }

      ports {
        container_port = 8080
      }
    }
  }

  depends_on = [google_artifact_registry_repository.docker]
}

# Frontend is publicly accessible
resource "google_cloud_run_v2_service_iam_member" "frontend_public" {
  name     = google_cloud_run_v2_service.frontend.name
  location = var.region
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# Backend is publicly accessible
resource "google_cloud_run_v2_service_iam_member" "backend_public" {
  name     = google_cloud_run_v2_service.backend.name
  location = var.region
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "google_cloud_run_v2_service" "backend" {
  name     = "gft-hackaton-backend"
  location = var.region
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {
    service_account = google_service_account.backend_sa.email

    scaling {
      min_instance_count = 0
      max_instance_count = 1
    }

    containers {
      image = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.docker.repository_id}/backend:latest"

      resources {
        limits = {
          cpu    = "1"
          memory = "512Mi"
        }
      }

      ports {
        container_port = 8080
      }

      env {
        name  = "ENVIRONMENT"
        value = "production"
      }

      env {
        name  = "DB_USER"
        value = var.db_user
      }

      env {
        name  = "DB_PASSWORD"
        value = var.db_password
      }

      env {
        name  = "DB_NAME"
        value = google_sql_database.edem_database.name
      }

      env {
        name  = "CLOUD_SQL_CONNECTION_NAME"
        value = "/cloudsql/${google_sql_database_instance.edem_db_instance.connection_name}"
      }

      volume_mounts {
        name       = "cloudsql"
        mount_path = "/cloudsql"
      }
    }

    volumes {
      name = "cloudsql"
      cloud_sql_instance {
        instances = [google_sql_database_instance.edem_db_instance.connection_name]
      }
    }
  }

  depends_on = [google_artifact_registry_repository.docker]
}
