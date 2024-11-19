# Use an official lightweight Python image
FROM python:3.9-slim-bullseye AS builder

# Set working directory
WORKDIR /app

# Install dependencies and create non-root user
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential && \
    useradd -m appuser && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the application code
COPY . .

# Switch to non-root user for security
USER appuser

# Expose the default port
EXPOSE 5000

# Unbuffered logs for containerized environments
ENV PYTHONUNBUFFERED=1

# Run the Flask application
CMD ["python", "app.py"]
