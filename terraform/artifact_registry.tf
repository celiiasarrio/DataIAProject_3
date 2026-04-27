resource "google_artifact_registry_repository" "docker" {
  repository_id = var.app_name
  location      = var.region
  format        = "DOCKER"
  description   = "Docker images for backend and frontend"
}
