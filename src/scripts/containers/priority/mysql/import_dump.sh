#!/usr/bin/env bash

DUMPS_DIRECTORY="/dumps"
cd ${DUMPS_DIRECTORY}
mysql -t < employees.sql -u root -p${MYSQL_ROOT_PASSWORD}