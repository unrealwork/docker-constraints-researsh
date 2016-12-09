#!/usr/bin/env bash

CONTAINER_NAME="mysql";
docker rm -f ${CONTAINER_NAME}
TMP_DIRECTORY=$(mktemp -d)
ARCHIVE_NAME="dump.tar.bz2";
DOWNLOAD_LINK="https://launchpadlibrarian.net/24493586/employees_db-full-1.0.6.tar.bz2"
DUMPS_DIRECTORY="/dumps"
ARCHIVE_FILE=${TMP_DIRECTORY}/${ARCHIVE_NAME}
DB_DIRECTORY=${TMP_DIRECTORY}/employees_db
curl -o ${ARCHIVE_FILE} ${DOWNLOAD_LINK}
tar -xjf ${ARCHIVE_FILE} -C ${TMP_DIRECTORY}
sed -i 's/storage_engine/default_storage_engine/g' ${DB_DIRECTORY}/employees.sql
docker run --name ${CONTAINER_NAME} -p 3306:3306 -e MYSQL_ROOT_PASSWORD=root -d mysql
docker cp  ${DB_DIRECTORY} ${CONTAINER_NAME}:${DUMPS_DIRECTORY}
docker cp  import_dump.sh ${CONTAINER_NAME}:/run
docker exec ${CONTAINER_NAME} sh /run/import_dump.sh