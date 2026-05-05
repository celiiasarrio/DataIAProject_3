resource "google_artifact_registry_repository" "docker" {
  repository_id = "docker-repo"
  location      = var.region
  format        = "DOCKER"
  description   = "Docker images for backend and frontend"
}
