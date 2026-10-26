from fastapi import FastAPI

app = FastAPI(
    title="Smart Pill & Medical Logbook API"
)

@app.get("/")
def home():
    return {
        "message": "Smart Pill API is running"
    }

@app.get("/health")
def health_check():
    return {
        "status": "ok"
    }