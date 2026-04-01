import os
from pydantic_settings import BaseSettings
from typing import Optional


class Settings(BaseSettings):
    """
    Configuración de la aplicación para Google Cloud Run + Cloud SQL.
    
    Las variables de entorno pueden ser:
    - Definidas en un archivo .env (desarrollo local)
    - Configuradas en Cloud Run Environment Variables
    - Configurdas en Google Secret Manager (ambiente de producción)
    """
    
    # Base de datos PostgreSQL
    DB_USER: str = os.getenv("DB_USER", "postgres")
    DB_PASSWORD: str = os.getenv("DB_PASSWORD", "")
    DB_HOST: str = os.getenv("DB_HOST", "localhost")
    DB_PORT: int = int(os.getenv("DB_PORT", "5432"))
    DB_NAME: str = os.getenv("DB_NAME", "edem_hub_db")
    
    # Configuración de Cloud SQL (si se usa Cloud SQL Proxy)
    CLOUD_SQL_CONNECTION_NAME: Optional[str] = os.getenv("CLOUD_SQL_CONNECTION_NAME")
    
    # Ambiente
    ENVIRONMENT: str = os.getenv("ENVIRONMENT", "development")  # development, production
    
    class Config:
        env_file = ".env"
        case_sensitive = False
    
    @property
    def database_url(self) -> str:
        """
        Genera la URL de conexión a PostgreSQL adaptada a Cloud Run.
        
        En Cloud Run se puede usar:
        1. Cloud SQL Auth proxy (recomendado): unix socket
        2. Cloud SQL Connector: protocolo especial
        3. IP pública: conexión directa (menos segura)
        """
        
        # Modo 1: Usando Cloud SQL Auth Proxy (recomendado para Cloud Run)
        if self.CLOUD_SQL_CONNECTION_NAME:
            # Format: /cloudsql/PROJECT:REGION:INSTANCE
            # Ejemplo: /cloudsql/my-project:us-central1:my-instance
            return f"postgresql+psycopg2://{self.DB_USER}:{self.DB_PASSWORD}@/{self.DB_NAME}?host=/{self.CLOUD_SQL_CONNECTION_NAME}"
        
        # Modo 2: Conexión directa por host/puerto (desarrollo local o IP pública)
        return f"postgresql+psycopg2://{self.DB_USER}:{self.DB_PASSWORD}@{self.DB_HOST}:{self.DB_PORT}/{self.DB_NAME}"


# Instancia global de configuración
settings = Settings()
