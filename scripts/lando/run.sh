#!/usr/bin/env bash

# Make sure .env has been created.
cd /app
test -f .env || { echo 'Copy .env.example to .env and fill it out, then run lando rebuild. See README.md for more information.'; exit 1; }
if test ! -f /app/$DB_LOCAL; then
				echo Downloading backup: $DB_SOURCE;
				wget -O /app/$DB_LOCAL $DB_SOURCE
fi
