#!/usr/bin/env bash

CONTAINER_NAME="mysql";
TMP_DIRECTORY=$(mktemp -d)
ARCHIVE_NAME="dump.tar.bz2";
DOWNLOAD_LINK="https://launchpadlibrarian.net/24493586/employees_db-full-1.0.6.tar.bz2"
DUMPS_DIRECTORY="/dumps"
ARCHIVE_FILE=${TMP_DIRECTORY}/${ARCHIVE_NAME}
DB_DIRECTORY=${TMP_DIRECTORY}/employees_db
docker rm -f ${CONTAINER_NAME}
docker run --name ${CONTAINER_NAME} -e MYSQL_ROOT_PASSWORD=root -d mysql
curl -o ${ARCHIVE_FILE} ${DOWNLOAD_LINK}
tar -xjf ${ARCHIVE_FILE} -C ${TMP_DIRECTORY}
sed -i 's/storage_engine/default_storage_engine/g' ${DB_DIRECTORY}/employees.sql
docker cp  ${DB_DIRECTORY} ${CONTAINER_NAME}:${DUMPS_DIRECTORY}
echo "mysql -t < "${DUMPS_DIRECTORY}"/employees_db/employees.sql -u root -p\$MYSQL_ROOT_PASSWORD";
docker exec -t ${CONTAINER_NAME} "cd "${DUMPS_DIRECTORY}" && mysql -t < employees.sql -u root -p\$MYSQL_ROOT_PASSWORD" -u root