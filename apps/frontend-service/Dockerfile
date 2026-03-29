FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
RUN useradd -m -u 1000 appuser && chown -R appuser /app
USER appuser
EXPOSE 8002
HEALTHCHECK --interval=30s CMD curl -f http://localhost:8002/health || exit 1
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8002"]