terraform {
  required_version = ">= 1.0"

  backend "gcs" {
    bucket = "gft-hackaton-tfstate-26"
    prefix = "terraform/state"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Crear la base de datos Firestore (Modo Nativo)
resource "google_firestore_database" "database" {
  project     = var.project_id
  name        = "(default)" # Es el nombre estándar requerido
  location_id = var.firestore_location
  type        = "FIRESTORE_NATIVE"

  depends_on = [google_project_service.firestore]
}
