resource "google_artifact_registry_repository" "docker" {
  repository_id = "gft-hackaton"
  location      = var.region
  format        = "DOCKER"
  description   = "Docker images for backend and frontend"
}
