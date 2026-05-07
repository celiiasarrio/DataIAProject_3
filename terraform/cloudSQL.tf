# CloudSQL
resource "google_sql_database_instance" "edem_db_instance" {
  name             = var.db_instance_name
  database_version = "POSTGRES_15"
  region           = var.db_region

  settings {
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled = true
      authorized_networks {
        name  = "Allow all"
        value = "0.0.0.0/0"
      }
    }
  }
  deletion_protection = false
}

# Base de datos
resource "google_sql_database" "edem_database" {
  name     = var.db_name
  instance = google_sql_database_instance.edem_db_instance.name
}

# DB User
resource "google_sql_user" "edem_db_user" {
  name     = var.db_user
  instance = google_sql_database_instance.edem_db_instance.name
  password = var.db_password
}
