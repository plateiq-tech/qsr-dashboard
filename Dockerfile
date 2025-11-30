FROM apache/superset:latest

USER root

RUN apt-get update && apt-get install -y \
  pkg-config \
  libmariadb-dev \
  default-libmysqlclient-dev \
  build-essential \
  libpq-dev \
  postgresql-client \
  && rm -rf /var/lib/apt/lists/*

# Install Python packages into the virtual environment that Superset uses
# The venv uses /app/.venv/lib/python3.10/site-packages but doesn't include pip
# So we use system pip with --target to install into the venv's site-packages
RUN pip install --no-cache-dir --target=/app/.venv/lib/python3.10/site-packages mysqlclient psycopg2-binary

ENV ADMIN_USERNAME $ADMIN_USERNAME
ENV ADMIN_EMAIL $ADMIN_EMAIL
ENV ADMIN_PASSWORD $ADMIN_PASSWORD
ENV DATABASE $DATABASE

COPY /config/superset_init.sh ./superset_init.sh
RUN chmod +x ./superset_init.sh

COPY /config/superset_config.py /app/
ENV SUPERSET_CONFIG_PATH /app/superset_config.py
ENV SECRET_KEY $SECRET_KEY

USER superset

ENTRYPOINT [ "./superset_init.sh" ]
