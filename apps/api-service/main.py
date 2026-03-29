from fastapi import FastAPI, HTTPException
from prometheus_client import Counter, Histogram, generate_latest
import httpx, time, os, logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)
app = FastAPI(title="API Service")

REQUEST_COUNT = Counter('api_requests_total', 'Total requests', ['status'])
REQUEST_LATENCY = Histogram('api_request_duration_seconds', 'Latency', ['endpoint'])
WORKER_URL = os.getenv("WORKER_URL", "http://worker-service:8001")

@app.get("/health")
def health():
    return {"status": "ok", "service": "api-service"}
 
@app.get("/metrics")
def metrics():
    return generate_latest()

@app.post("/jobs")
async def create_job(job_type: str = "default"):
    start = time.time()
    try:
        async with httpx.AsyncClient(timeout=5.0) as client:
            resp = await client.post(f"{WORKER_URL}/process", json={"type": job_type})
            resp.raise_for_status()
        REQUEST_COUNT.labels("200").inc()
        return {"job_id": resp.json()["job_id"], "status": "queued"}
    except Exception as e:
        REQUEST_COUNT.labels("500").inc()
        logger.error(f"Job creation failed: {e}")
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        REQUEST_LATENCY.labels("/jobs").observe(time.time() - start)
 
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
