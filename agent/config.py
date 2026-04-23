from pathlib import Path

from dotenv import load_dotenv
from pydantic_settings import BaseSettings, SettingsConfigDict

# Cargamos explícitamente el .env del módulo agent/ (no el de la raíz ni el del
# backend). Esto además inyecta las vars en os.environ para que google-genai y
# la ADK las puedan leer directamente.
ENV_PATH = Path(__file__).parent / ".env"
load_dotenv(ENV_PATH, override=False)


class AgentSettings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=str(ENV_PATH),
        case_sensitive=False,
        extra="ignore",
    )

    BACKEND_BASE_URL: str = "http://localhost:8080"
    MODEL: str = "gemini-2.5-flash"
    HTTP_TIMEOUT_SECONDS: float = 15.0

    GOOGLE_GENAI_USE_VERTEXAI: bool = True
    GOOGLE_CLOUD_PROJECT: str = ""
    GOOGLE_CLOUD_LOCATION: str = "europe-west1"
    GOOGLE_API_KEY: str = ""

    FIRESTORE_PROJECT: str = ""
    FIRESTORE_DATABASE: str = "(default)"

    AGENT_EMAIL: str = ""
    AGENT_PASSWORD: str = ""


settings = AgentSettings()
