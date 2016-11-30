#!/usr/bin/env bash
DOWNLOAD_LINK="http://apache-mirror.rbc.ru/pub/apache//jmeter/binaries/apache-jmeter-3.1.tgz"
TMP_DIRECTORY=$(mktemp -d)
ARCHIVE_NAME="jmeter.tgz";
ARCHIVE_FILE=${TMP_DIRECTORY}/${ARCHIVE_NAME}
INSTALLATION_FOLDER="/opt/apache/jmeter";
curl -o ${ARCHIVE_FILE} ${DOWNLOAD_LINK}
mkdir -p ${INSTALLATION_FOLDER}
tar -xvzf ${ARCHIVE_FILE} -C ${INSTALLATION_FOLDER} --strip-components 1
echo '$JMETER_HOME="'${INSTALLATION_FOLDER}'"'
ln -s ${INSTALLATION_FOLDER}/bin/jmeter /usr/bin/jmeter
