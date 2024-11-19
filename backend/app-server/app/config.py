from pydantic import BaseSettings

class Settings(BaseSettings):
    APP_NAME: str = "App Server"
    ENV: str = "development"

    class Config:
        env_file = ".env"
