from fastapi import FastAPI
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
from starlette.responses import Response
import time

app = FastAPI(title="Worker Service")

JOBS_PROCESSED = Counter("worker_jobs_processed_total", "Total jobs processed", ["status"])
JOB_DURATION = Histogram("worker_job_duration_seconds", "Job processing duration")

@app.get("/health")
def health():
    return {"status": "ok", "service": "worker-service"}

@app.get("/metrics")
def metrics():
    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)

@app.post("/process")
def process_job(job: dict = None):
    start = time.time()
    time.sleep(0.1)  # simulate work
    JOBS_PROCESSED.labels(status="success").inc()
    JOB_DURATION.observe(time.time() - start)
    return {"status": "processed", "service": "worker-service"}

    if __name__ == "__main__":
        import uvicorn
        uvicorn.run(app, host="0.0.0.0", port=8001)