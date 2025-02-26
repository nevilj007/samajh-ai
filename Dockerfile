# Use the official Python image as base
FROM python:3.11-slim

# Set non-interactive frontend for silent installation
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary dependencies
RUN apt-get update && apt-get install -y \
    curl \
    procps \
    && rm -rf /var/lib/apt/lists/*

# Install Ollama
RUN curl -fsSL https://ollama.com/install.sh | sh

# Preload and cache the Llama model before running the app
RUN ollama start & \
    sleep 5 && \
    ollama pull llama3.1 && \
    kill $(pgrep ollama)

# Set the working directory inside the container
WORKDIR /app

# Copy requirements file
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Install PostgreSQL client (psql) for debugging & database connection testing
RUN apt update && apt install -y postgresql-client

# Copy the entire project into the container
COPY . .



# Expose FastAPI's default port
EXPOSE 8000

# Start Ollama and run the FastAPI app
CMD ["sh", "-c", "ollama serve & while ! ollama list | grep -q 'llama3.1'; do echo 'Waiting for Ollama to be ready...'; sleep 2; done; uvicorn chatbot:app --host 0.0.0.0 --port 8000 --reload"]

