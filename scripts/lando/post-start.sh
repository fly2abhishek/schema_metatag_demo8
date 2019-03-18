#!/usr/bin/env bash

# Post-start actions.

cd /app && composer install

# Configure for phpunit tests.
cp /app/core/phpunit.xml.dist /app/core/phpunit.xml
mkdir -p -m 777 /app/files/simpletest

# Let the user know what to do next.
echo "Run tests: lando phpunit --group [MODULE]"
echo "To load database, run \e[1;32m lando db-import $DB_LOCAL \e[0m"
