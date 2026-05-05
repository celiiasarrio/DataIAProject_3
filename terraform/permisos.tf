# Enable Cloud SQL API
resource "google_project_service" "sqladmin" {
  service            = "sqladmin.googleapis.com"
  disable_on_destroy = false
}

# Enable Firestore API
resource "google_project_service" "firestore" {
  service            = "firestore.googleapis.com"
  disable_on_destroy = false
}

# Enable Vertex AI API
resource "google_project_service" "aiplatform" {
  service            = "aiplatform.googleapis.com"
  disable_on_destroy = false
}

# Backend SA → Cloud SQL access
resource "google_project_iam_member" "backend_cloudsql" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.backend_sa.email}"
}

# Firestore SA → Firestore access
resource "google_project_iam_member" "firestore_access" {
  project = var.project_id
  role    = "roles/datastore.user"
  member  = "serviceAccount:${google_service_account.firestore_sa.email}"
}

# Agent SA → Vertex AI access
resource "google_project_iam_member" "agent_vertex_ai" {
  project = var.project_id
  role    = "roles/aiplatform.user"
  member  = "serviceAccount:${google_service_account.agent_sa.email}"
}

# Agent SA → Firestore access
resource "google_project_iam_member" "agent_firestore_access" {
  project = var.project_id
  role    = "roles/datastore.user"
  member  = "serviceAccount:${google_service_account.agent_sa.email}"
}

# CI/CD SA → Artifact Registry push (COMENTADO - crear service account manualmente si es necesario)
# resource "google_project_iam_member" "cicd_artifact_registry" {
#   project = var.project_id
#   role    = "roles/artifactregistry.writer"
#   member  = "serviceAccount:${var.cicd_sa_email}"
# }

# CI/CD SA → Cloud Run deploy (COMENTADO - crear service account manualmente si es necesario)
# resource "google_project_iam_member" "cicd_cloudrun" {
#   project = var.project_id
#   role    = "roles/run.developer"
#   member  = "serviceAccount:${var.cicd_sa_email}"
# }

# CI/CD SA → act as backend SA (COMENTADO - crear service account manualmente si es necesario)
# resource "google_service_account_iam_member" "cicd_actAs_backend" {
#   service_account_id = google_service_account.backend_sa.name
#   role               = "roles/iam.serviceAccountUser"
#   member             = "serviceAccount:${var.cicd_sa_email}"
# }

# CI/CD SA → act as frontend SA (COMENTADO - crear service account manualmente si es necesario)
# resource "google_service_account_iam_member" "cicd_actAs_frontend" {
#   service_account_id = google_service_account.frontend_sa.name
#   role               = "roles/iam.serviceAccountUser"
#   member             = "serviceAccount:${var.cicd_sa_email}"
# }

# CI/CD SA → act as agent SA (COMENTADO - crear service account manualmente si es necesario)
# resource "google_service_account_iam_member" "cicd_actAs_agent" {
#   service_account_id = google_service_account.agent_sa.name
#   role               = "roles/iam.serviceAccountUser"
#   member             = "serviceAccount:${var.cicd_sa_email}"
# }
