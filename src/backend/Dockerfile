# Use an official lightweight Python image with version pinning
FROM python:3.9-slim-bullseye AS builder

# Set working directory
WORKDIR /app

# Install required build dependencies and create non-root user
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc libpq-dev && \
    useradd -m appuser && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy requirements first for leveraging Docker caching
COPY requirements.txt .

# Install dependencies with no-cache-dir to reduce image size
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Switch to the non-root user
USER appuser

# Expose the application port
EXPOSE 8080

# Use unbuffered mode for smoother logs in containerized environments
ENV PYTHONUNBUFFERED=1

# Command to run the application
CMD ["python", "app.py"]
