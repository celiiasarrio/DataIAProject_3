# CloudSQL
resource "google_sql_database_instance" "edem_db_instance" {
  name             = var.db_instance_name
  database_version = "POSTGRES_15"
  region           = var.db_region

  settings {
    tier = var.db_tier
    ip_configuration {
      ipv4_enabled = true
      authorized_networks {
        name  = "Allow all"
        value = "0.0.0.0/0"
      }
    }
  }
  deletion_protection = false

  depends_on = [google_project_service.sqladmin]
}

# Base de datos
resource "google_sql_database" "edem_database" {
  name     = var.db_name
  instance = google_sql_database_instance.edem_db_instance.name
}

# DB User
resource "google_sql_user" "edem_db_user" {
  name            = var.db_user
  instance        = google_sql_database_instance.edem_db_instance.name
  password        = var.db_password
  deletion_policy = "ABANDON"
}
