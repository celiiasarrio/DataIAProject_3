from typing import Optional

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """
    Configuración de la aplicación para Google Cloud Run + Cloud SQL.
    
    Las variables de entorno pueden ser:
    - Definidas en un archivo .env (desarrollo local)
    - Configuradas en Cloud Run Environment Variables
    - Configurdas en Google Secret Manager (ambiente de producción)
    """
    
    model_config = SettingsConfigDict(env_file=".env", case_sensitive=False)

    # Base de datos PostgreSQL
    DATABASE_URL: Optional[str] = None
    DB_USER: str = "postgres"
    DB_PASSWORD: str = ""
    DB_HOST: str = "localhost"
    DB_PORT: int = 5432
    DB_NAME: str = "edem_hub_db"
    
    # Configuración de Cloud SQL (si se usa Cloud SQL Proxy)
    CLOUD_SQL_CONNECTION_NAME: Optional[str] = None
    
    # Ambiente
    ENVIRONMENT: str = "development"  # development, production

    # Seguridad
    JWT_SECRET: str = "development-only-change-me"
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 8
    
    @property
    def database_url(self) -> str:
        """
        Genera la URL de conexión a PostgreSQL adaptada a Cloud Run.
        
        En Cloud Run se puede usar:
        1. Cloud SQL Auth proxy (recomendado): unix socket
        2. Cloud SQL Connector: protocolo especial
        3. IP pública: conexión directa (menos segura)
        """
        
        if self.DATABASE_URL:
            return self.DATABASE_URL

        # Modo 1: Usando Cloud SQL Auth Proxy (recomendado para Cloud Run)
        if self.CLOUD_SQL_CONNECTION_NAME:
            cloud_sql_host = self.CLOUD_SQL_CONNECTION_NAME
            if not cloud_sql_host.startswith("/cloudsql/"):
                cloud_sql_host = f"/cloudsql/{cloud_sql_host}"
            return f"postgresql+psycopg2://{self.DB_USER}:{self.DB_PASSWORD}@/{self.DB_NAME}?host={cloud_sql_host}&client_encoding=utf8"

        # Modo 2: Conexión directa por host/puerto (desarrollo local o IP pública)
        return f"postgresql+psycopg2://{self.DB_USER}:{self.DB_PASSWORD}@{self.DB_HOST}:{self.DB_PORT}/{self.DB_NAME}?client_encoding=utf8"

    @property
    def jwt_secret(self) -> str:
        if self.ENVIRONMENT == "production" and self.JWT_SECRET == "development-only-change-me":
            raise ValueError("JWT_SECRET debe configurarse en producción.")
        return self.JWT_SECRET


# Instancia global de configuración
settings = Settings()
