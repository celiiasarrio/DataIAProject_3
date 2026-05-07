output "project_id" {
  description = "The GCP project ID"
  value       = var.project_id
}

output "region" {
  description = "The GCP region"
  value       = var.region
}

output "artifact_registry" {
  description = "Artifact Registry repository URL"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.docker.repository_id}"
}

output "frontend_url" {
  description = "Frontend Cloud Run URL"
  value       = var.deploy_services && var.deploy_frontend ? google_cloud_run_v2_service.frontend[0].uri : null
}

output "backend_url" {
  description = "Backend Cloud Run URL"
  value       = var.deploy_services && var.deploy_backend ? google_cloud_run_v2_service.backend[0].uri : null
}

output "agent_url" {
  description = "Agent Cloud Run URL"
  value       = var.deploy_services && var.deploy_agent ? google_cloud_run_v2_service.agent[0].uri : null
}

output "database_connection" {
  description = "Cloud SQL connection name"
  value       = google_sql_database_instance.edem_db_instance.connection_name
}

output "database_ip" {
  description = "Cloud SQL public IP"
  value       = google_sql_database_instance.edem_db_instance.public_ip_address
}

output "database_name" {
  description = "Database name"
  value       = google_sql_database.edem_database.name
}

output "frontend_sa_email" {
  description = "Frontend Cloud Run service account email"
  value       = google_service_account.frontend_sa.email
}

output "backend_sa_email" {
  description = "Backend Cloud Run service account email"
  value       = google_service_account.backend_sa.email
}

output "agent_sa_email" {
  description = "Agent Cloud Run service account email"
  value       = google_service_account.agent_sa.email
}

