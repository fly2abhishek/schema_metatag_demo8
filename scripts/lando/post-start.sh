#!/usr/bin/env bash

# Post-start actions.

cd /app && composer install

# Configure for phpunit tests.
cp /app/web/core/phpunit.xml.dist /app/web/core/phpunit.xml
mkdir -p -m 777 /app/files/simpletest

# Let the user know what to do next.
echo "Run tests: lando phpunit --group [MODULE]"
echo "To load database: lando db-import $DB_LOCAL"
