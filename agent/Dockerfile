FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . /app/agent

EXPOSE 8080

CMD ["sh", "-c", "uvicorn agent.service:app --host 0.0.0.0 --port ${PORT:-8080}"]
