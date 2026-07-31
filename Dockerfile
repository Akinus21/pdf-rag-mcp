# Stage 1: Clone the source and build the React Frontend
FROM node:20-alpine AS frontend-builder
WORKDIR /app

# Install git to download the target code dynamically
RUN apk add --no-cache git

# Clone the target repository directly inside the build runner environment
RUN git clone https://github.com/hyson666/pdf-rag-mcp-server.git .

# Move to the cloned frontend subdirectory and compile assets
WORKDIR /app/frontend
RUN npm install
RUN npm run build

# Stage 2: Build the FastAPI Backend System
FROM ghcr.io/astral-sh/uv:python3.11-bookworm-slim
WORKDIR /app

# Install standard compilation and network dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    curl \
    git \
    build-essential \
    libffi-dev \
    && rm -rf /var/lib/apt/lists/*

# Re-clone the repository to acquire clean backend script hierarchies
RUN git clone https://github.com/hyson666/pdf-rag-mcp-server.git .

# Install Python requirements via uv
RUN uv pip install --system -r backend/requirements.txt
RUN uv pip install --system fastapi-mcp

# Copy built frontend production bundles from Stage 1 into the backend static file routing map
COPY --from=frontend-builder /app/frontend/dist ./backend/static

EXPOSE 8000
CMD ["python", "-m", "uvicorn", "backend.app.main:app", "--host", "0.0.0.0", "--port", "8000"]
