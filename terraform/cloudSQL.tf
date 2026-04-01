# CloudSQL
resource "google_sql_database_instance" "edem_db_instance" {
  name             = "edem-hub-postgres-instance"
  database_version = "POSTGRES_15"
  region           = "europe-southwest1" # Madrid, latencia mínima
  
  settings {

    tier = "db-f1-micro"     
    ip_configuration {
      # IP pública temporalmente 
      ipv4_enabled = true 
    }
  }
  deletion_protection = false 
}

# Base de datos
resource "google_sql_database" "edem_database" {
  name     = "edem_hub_db"
  instance = google_sql_database_instance.edem_db_instance.name
}

# DB User
resource "google_sql_user" "edem_db_user" {
  name     = var.db_user
  instance = google_sql_database_instance.edem_db_instance.name
  password = var.db_password
}