# Stage 1: Clone the source and build the React Frontend
FROM node:20-alpine AS frontend-builder
WORKDIR /app
RUN apk add --no-cache git
RUN git clone https://github.com .
WORKDIR /app/frontend
RUN npm install
RUN npm run build

# Stage 2: Build the FastAPI Backend System
FROM ghcr.io/astral-sh/uv:python3.11-bookworm-slim
WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    curl \
    git \
    build-essential \
    libffi-dev \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com .
RUN uv pip install --system -r backend/requirements.txt
RUN uv pip install --system fastapi-mcp
COPY --from=frontend-builder /app/frontend/dist ./backend/static

# FIXED EXECUTION ENVIRONMENT SETTINGS:
WORKDIR /app
ENV PYTHONPATH=/app/backend

EXPOSE 8000
CMD ["python", "-m", "uvicorn", "backend.app.main:app", "--host", "0.0.0.0", "--port", "8000"]
