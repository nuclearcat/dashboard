#!/usr/bin/env bash
set -euo pipefail

: "${COMPOSE_FILE:=docker-compose-next.yaml}"
: "${POSTGRES_SERVICE:=dashboard_db}"
: "${DB_HOST:=127.0.0.1}"
: "${DB_PORT:=5432}"
: "${DB_PASSWORD:?DB_PASSWORD is required}"
: "${DASHBOARD_DB_USER:?DASHBOARD_DB_USER is required}"
: "${APP_DB_USER:?APP_DB_USER is required}"
: "${DASHBOARD_DB:?DASHBOARD_DB is required}"
: "${APP_DB:?APP_DB is required}"

TEMPLATE="cicd/init-dashboard-db.sql.tpl"
TMP_SQL="$(mktemp)"

python3 - "$TMP_SQL" "$TEMPLATE" <<'PY'
import os
import sys
from pathlib import Path

out_file, template_file = sys.argv[1:3]
template = Path(template_file).read_text()

replacements = {
    "{{DASHBOARD_DB_USER}}": os.environ["DASHBOARD_DB_USER"],
    "{{APP_DB_USER}}": os.environ["APP_DB_USER"],
    "{{DASHBOARD_DB}}": os.environ["DASHBOARD_DB"],
    "{{APP_DB}}": os.environ["APP_DB"],
    "{{DB_PASSWORD}}": os.environ["DB_PASSWORD"],
}

for token, value in replacements.items():
    template = template.replace(token, value)

Path(out_file).write_text(template)
PY

if [ ! -f "$TMP_SQL" ]; then
    echo "Generated SQL file missing: $TMP_SQL"
    exit 1
fi

docker compose -f "$COMPOSE_FILE" exec -T "$POSTGRES_SERVICE" \
  env PGPASSWORD="$DB_PASSWORD" \
  psql -h "$DB_HOST" -p "$DB_PORT" -U "$DASHBOARD_DB_USER" -d postgres < "$TMP_SQL"

rm -f "$TMP_SQL"
