from fastapi import FastAPI
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
from starlette.responses import Response
import httpx
import time
import os

app = FastAPI(title="Frontend Service")

REQUEST_COUNT = Counter("frontend_requests_total", "Total requests", ["endpoint", "status"])
REQUEST_LATENCY = Histogram("frontend_request_duration_seconds", "Request latency", ["endpoint"])

API_SERVICE_URL = os.getenv("API_SERVICE_URL", "http://localhost:8000")

@app.get("/health")
def health():
    return {"status": "ok", "service": "frontend-service"}

@app.get("/metrics")
def metrics():
    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)

@app.get("/")
def root():
    start = time.time()
    REQUEST_COUNT.labels(endpoint="/", status="200").inc()
    REQUEST_LATENCY.labels(endpoint="/").observe(time.time() - start)
    return {"message": "frontend-service running", "api_url": API_SERVICE_URL}

@app.get("/api-status")
def api_status():
    try:
        response = httpx.get(f"{API_SERVICE_URL}/health", timeout=5)
        return {"frontend": "ok", "api": response.json()}
    except Exception as e:
        REQUEST_COUNT.labels(endpoint="/api-status", status="500").inc()
        return {"frontend": "ok", "api": "unreachable", "error": str(e)}
    
    if __name__ == "__main__":
        import uvicorn
        uvicorn.run(app, host="0.0.0.0", port=8002)
