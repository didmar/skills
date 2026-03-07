FROM python:3.13-slim AS builder

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

WORKDIR /app
COPY pyproject.toml uv.lock ./

FROM builder AS dev

RUN uv sync
ENV PATH="/app/.venv/bin:$PATH"
CMD ["python", "-m", "<package>.main"]

FROM builder AS prod

COPY . .
RUN uv sync --no-dev
ENV PATH="/app/.venv/bin:$PATH"
CMD ["python", "-m", "<package>.main"]
