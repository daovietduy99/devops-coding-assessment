# Use an official lightweight Python image with version pinning
FROM python:3.9-slim-bullseye AS builder

WORKDIR /app

RUN apt-get update && apt-get install -y vim && apt-get install -y --no-install-recommends \
    gcc libpq-dev && \
    useradd -m appuser && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

USER appuser

EXPOSE 8080

ENV PYTHONUNBUFFERED=1

CMD ["python", "app.py"]
