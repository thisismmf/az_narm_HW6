FROM python:3.9-slim

RUN apt-get update \
    && apt-get install -y \
       gcc \
       libpq-dev \
       postgresql-client     \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt \
    && pip install psycopg2-binary

COPY . .

ENV DJANGO_SETTINGS_MODULE=notes.settings

CMD ["sh", "-c", "\
      until PGPASSWORD=$${POSTGRES_PASSWORD} \
        psql -h $${POSTGRES_HOST} -U $${POSTGRES_USER} -d $${POSTGRES_DB} -c '\\q'; do \
          echo 'Waiting for Postgres…'; \
          sleep 2; \
      done; \
      echo 'Postgres is up — running migrations'; \
      python manage.py migrate --noinput; \
      echo 'Starting Django'; \
      python manage.py runserver 0.0.0.0:8000 \
    "]