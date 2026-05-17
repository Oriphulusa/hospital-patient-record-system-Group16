#!/usr/bin/env bash
set -e
export PATH="/Library/PostgreSQL/18/bin:$PATH"
export DB_NAME=${DB_NAME:-hprs_phase3_db}
export DB_USER=${DB_USER:-postgres}
export DB_PASSWORD=${DB_PASSWORD:-041213}
export DB_HOST=${DB_HOST:-localhost}
export DB_PORT=${DB_PORT:-5432}
python manage.py runserver
