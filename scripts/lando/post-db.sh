#!/usr/bin/env bash

# Update everything after a new database has been pulled in.
echo "Running drush cr and updb"
cd /app/web
drush cr >&2
drush updb -y >&2
drush cim -y >&2
drush cr >&2
drush upwd admin password >&2
echo "Log in with credentials admin/password"

