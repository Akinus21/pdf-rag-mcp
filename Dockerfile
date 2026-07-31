# Stage 1: Build the React Frontend
FROM node:20-alpine AS frontend-builder
WORKDIR /app/frontend
COPY frontend/package.json ./
RUN npm install
COPY frontend/ ./
RUN npm run build

# Stage 2: Build the FastAPI Backend System
FROM ghcr.io/astral-sh/uv:python3.11-bookworm-slim
WORKDIR /app

# Install standard compilation and network tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    curl \
    build-essential \
    libffi-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy backend definitions and install core requirements
COPY backend/requirements.txt ./backend/
RUN uv pip install --system -r backend/requirements.txt

# CRITICAL FIX: Explicitly install the missing MCP framework module
RUN uv pip install --system fastapi-mcp

# Copy backend codebase
COPY backend/ ./backend/

# Copy built frontend assets directly into the FastAPI static files directory
COPY --from=frontend-builder /app/frontend/dist ./backend/static

EXPOSE 8000
CMD ["python", "-m", "uvicorn", "backend.app.main:app", "--host", "0.0.0.0", "--port", "8000"]
