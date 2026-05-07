variable "project_id" {
  description = "GCP project ID"
  type        = string
  default     = "project3grupo6"
}

variable "app_name" {
  description = "Nombre de la aplicación usado como prefijo en los recursos GCP"
  type        = string
  default     = "project3grupo6"
}

variable "region" {
  description = "GCP region principal"
  type        = string
  default     = "europe-west1"
}

variable "db_region" {
  description = "Región de Cloud SQL (Madrid)"
  type        = string
  default     = "europe-southwest1"
}

variable "db_instance_name" {
  description = "Nombre de la instancia de Cloud SQL"
  type        = string
  default     = "project3grupo6-postgres"
}

variable "db_name" {
  description = "Nombre de la base de datos PostgreSQL"
  type        = string
  default     = "edem_hub_db"
}

variable "db_user" {
  description = "Usuario administrador de la base de datos"
  type        = string
}

variable "db_password" {
  description = "Contraseña del administrador de la base de datos"
  type        = string
  sensitive   = true
}

variable "jwt_secret" {
  description = "Secreto usado para firmar JWT del backend"
  type        = string
  sensitive   = true
}

variable "firestore_location" {
  description = "Firestore database location"
  type        = string
  default     = "europe-west1"
}

variable "cicd_sa_email" {
  description = "Email of the service account used by GitHub Actions CI/CD"
  type        = string
}

variable "deploy_services" {
  description = "Whether Terraform should create/update Cloud Run services"
  type        = bool
  default     = true
}

variable "deploy_backend" {
  description = "Whether Terraform should create/update the backend Cloud Run service"
  type        = bool
  default     = true
}

variable "deploy_frontend" {
  description = "Whether Terraform should create/update the frontend Cloud Run service"
  type        = bool
  default     = true
}

variable "deploy_agent" {
  description = "Whether Terraform should create/update the agent Cloud Run service"
  type        = bool
  default     = true
}

variable "backend_image_tag" {
  description = "Docker image tag for the backend Cloud Run service"
  type        = string
  default     = "latest"
}

variable "agent_image_tag" {
  description = "Docker image tag for the agent Cloud Run service"
  type        = string
  default     = "latest"
}

variable "frontend_image_tag" {
  description = "Docker image tag for the frontend Cloud Run service"
  type        = string
  default     = "latest"
}

variable "db_tier" {
  description = "Cloud SQL machine tier"
  type        = string
  default     = "db-g1-small"
}

variable "frontend_min_instances" {
  description = "Minimum Cloud Run instances for frontend"
  type        = number
  default     = 0
}

variable "backend_min_instances" {
  description = "Minimum Cloud Run instances for backend"
  type        = number
  default     = 1
}

variable "agent_min_instances" {
  description = "Minimum Cloud Run instances for agent"
  type        = number
  default     = 0
}
