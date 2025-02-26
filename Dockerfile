
FROM python:3.11-slim


ENV DEBIAN_FRONTEND=noninteractive


RUN apt-get update && apt-get install -y \
    curl \
    procps \
    && rm -rf /var/lib/apt/lists/*


RUN curl -fsSL https://ollama.com/install.sh | sh


RUN ollama start & \
    sleep 5 && \
    ollama pull llama3.1 && \
    kill $(pgrep ollama)


WORKDIR /app


COPY requirements.txt .


RUN pip install --no-cache-dir -r requirements.txt


RUN apt update && apt install -y postgresql-client


COPY . .




EXPOSE 8000


CMD ["sh", "-c", "ollama serve & while ! ollama list | grep -q 'llama3.1'; do echo 'Waiting for Ollama to be ready...'; sleep 2; done; uvicorn chatbot:app --host 0.0.0.0 --port 8000 --reload"]

