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
