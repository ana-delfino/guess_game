# Backend Flask do jogo de adivinhação (Python 3.12)
ARG PYTHON_VERSION=3.12
FROM python:${PYTHON_VERSION}-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    FLASK_APP=run.py

WORKDIR /app

# Dependências primeiro para aproveitar o cache de camadas
COPY requirements.txt .
# Gunicorn (servidor WSGI de produção) é instalado aqui, sem alterar o requirements.txt do projeto
ARG GUNICORN_VERSION=23.0.0
RUN pip install --no-cache-dir -r requirements.txt gunicorn==${GUNICORN_VERSION}

COPY run.py ./
COPY guess ./guess
COPY repository ./repository

EXPOSE 5000

# As variáveis FLASK_DB_* são injetadas pelo docker-compose.yml.
# O Gunicorn executa a mesma aplicação Flask (objeto "app" de run.py) com vários workers.
# Workers/threads podem ser ajustados sem rebuild via GUNICORN_CMD_ARGS no compose.
ENV GUNICORN_CMD_ARGS="--workers=2 --threads=2 --timeout=30 --access-logfile=-"
CMD ["gunicorn", "--bind=0.0.0.0:5000", "run:app"]
