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

# Service Account for agent
resource "google_service_account" "agent_sa" {
  account_id   = "${var.app_name}-agent-sa"
  display_name = "Service Account para Agent Cloud Run"
}

resource "google_cloud_run_v2_service" "frontend" {
  count = var.deploy_services && var.deploy_frontend ? 1 : 0

  name     = "${var.app_name}-frontend"
  location = var.region
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {
    service_account = google_service_account.frontend_sa.email

    scaling {
      min_instance_count = var.frontend_min_instances
      max_instance_count = 1
    }

    containers {
      image = "${var.region}-docker.pkg.dev/${var.project_id}/docker-repo/frontend:${var.frontend_image_tag}"

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

  depends_on = [
    google_artifact_registry_repository.docker,
    google_project_service.run,
  ]
}

# Frontend is publicly accessible
resource "google_cloud_run_v2_service_iam_member" "frontend_public" {
  count = var.deploy_services && var.deploy_frontend ? 1 : 0

  name     = google_cloud_run_v2_service.frontend[0].name
  location = var.region
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# Backend is publicly accessible
resource "google_cloud_run_v2_service_iam_member" "backend_public" {
  count = var.deploy_services && var.deploy_backend ? 1 : 0

  name     = google_cloud_run_v2_service.backend[0].name
  location = var.region
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# Agent is publicly accessible (auth real via JWT del backend)
resource "google_cloud_run_v2_service_iam_member" "agent_public" {
  count = var.deploy_services && var.deploy_agent ? 1 : 0

  name     = google_cloud_run_v2_service.agent[0].name
  location = var.region
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "google_cloud_run_v2_service" "backend" {
  count = var.deploy_services && var.deploy_backend ? 1 : 0

  name     = "${var.app_name}-backend"
  location = var.region
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {
    service_account = google_service_account.backend_sa.email

    scaling {
      min_instance_count = var.backend_min_instances
      max_instance_count = 1
    }

    containers {
      image = "${var.region}-docker.pkg.dev/${var.project_id}/docker-repo/backend:${var.backend_image_tag}"

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
        value = google_sql_database_instance.edem_db_instance.connection_name
      }

      env {
        name  = "UPLOAD_ROOT"
        value = "gs://${google_storage_bucket.uploads.name}/uploads"
      }

      env {
        name  = "PUBLIC_UPLOAD_PREFIX"
        value = "https://storage.googleapis.com/${google_storage_bucket.uploads.name}/uploads"
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

  depends_on = [
    google_artifact_registry_repository.docker,
    google_project_iam_member.backend_cloudsql,
    google_storage_bucket_iam_member.backend_write,
    google_project_service.run,
  ]
}

resource "google_cloud_run_v2_service" "agent" {
  count = var.deploy_services && var.deploy_agent ? 1 : 0

  name     = "${var.app_name}-agent"
  location = var.region
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {
    service_account = google_service_account.agent_sa.email

    scaling {
      min_instance_count = var.agent_min_instances
      max_instance_count = 1
    }

    containers {
      image = "${var.region}-docker.pkg.dev/${var.project_id}/docker-repo/agent:${var.agent_image_tag}"

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
        value = google_cloud_run_v2_service.backend[0].uri
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

      env {
        name  = "FIRESTORE_PROJECT"
        value = var.project_id
      }

      env {
        name  = "FIRESTORE_DATABASE"
        value = "(default)"
      }
    }
  }

  depends_on = [
    google_artifact_registry_repository.docker,
    google_cloud_run_v2_service.backend,
    google_project_iam_member.agent_vertex_ai,
    google_project_iam_member.agent_firestore,
    google_project_service.run,
  ]
}
