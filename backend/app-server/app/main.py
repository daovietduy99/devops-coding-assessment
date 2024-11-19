from fastapi import FastAPI
from app.config import Settings

app = FastAPI()
settings = Settings()

@app.get("/")
def read_root():
    return {"message": "Welcome to the App Server!"}

@app.get("/health")
def health_check():
    return {"status": "healthy"}

@app.get("/config")
def get_config():
    return {
        "app_name": settings.APP_NAME,
        "environment": settings.ENV
    }
