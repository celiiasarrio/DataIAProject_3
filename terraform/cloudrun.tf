# Service Account for frontend
resource "google_service_account" "frontend_sa" {
  account_id   = "${var.app_name}-frontend-sa"
  display_name = "Service Account para Frontend Cloud Run"
}

# Service Account for backend
resource "google_service_account" "backend_sa" {
  account_id   = "${var.app_name}-backend-sa"
  display_name = "Service Account para Backend Cloud Run"
}

# Service Account for Firestore
resource "google_service_account" "firestore_sa" {
  account_id   = "${var.app_name}-firestore-sa"
  display_name = "Service Account para Firestore"
}

# Service Account for agent
resource "google_service_account" "agent_sa" {
  account_id   = "${var.app_name}-agent-sa"
  display_name = "Service Account para Agent Cloud Run"
}

resource "google_cloud_run_v2_service" "frontend" {
  name     = "${var.app_name}-frontend"
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

# Agent is publicly accessible (auth real via JWT del backend)
resource "google_cloud_run_v2_service_iam_member" "agent_public" {
  name     = google_cloud_run_v2_service.agent.name
  location = var.region
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "google_cloud_run_v2_service" "backend" {
  name     = "${var.app_name}-backend"
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
        name  = "JWT_SECRET"
        value = var.jwt_secret
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

resource "google_cloud_run_v2_service" "agent" {
  name     = "${var.app_name}-agent"
  location = var.region
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {
    service_account = google_service_account.agent_sa.email

    scaling {
      min_instance_count = 0
      max_instance_count = 1
    }

    containers {
      image = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.docker.repository_id}/agent:latest"

      resources {
        limits = {
          cpu    = "1"
          memory = "1Gi"
        }
      }

      ports {
        container_port = 8080
      }

      env {
        name  = "BACKEND_BASE_URL"
        value = google_cloud_run_v2_service.backend.uri
      }

      env {
        name  = "GOOGLE_GENAI_USE_VERTEXAI"
        value = "TRUE"
      }

      env {
        name  = "GOOGLE_CLOUD_PROJECT"
        value = var.project_id
      }

      env {
        name  = "GOOGLE_CLOUD_LOCATION"
        value = var.region
      }

      env {
        name  = "MODEL"
        value = "gemini-2.5-flash"
      }

      env {
        name  = "HTTP_TIMEOUT_SECONDS"
        value = "15"
      }
    }
  }

  depends_on = [google_artifact_registry_repository.docker]
}
