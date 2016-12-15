#!/usr/bin/env bash


function uninstall_previous {
    installation_directory="/opt/apache/jmeter";
    if [ -d "$installation_directory" ]; then
        rm -rf ${installation_directory}
    fi
    if [ ! -f /usr/bin/jmeter ]; then
        echo "Remove previous jmeter symlink"
        rm  /usr/bin/jmeter
    fi
}


function install_jmeter {
    local download_link="http://apache-mirror.rbc.ru/pub/apache//jmeter/binaries/apache-jmeter-3.1.tgz"
    local tmp_directory=$(mktemp -d)
    local archive_name="jmeter.tgz";
    local archive_file=${tmp_directory}/${archive_name}

    installation_directory="/opt/apache/jmeter";
    if [ -d "$installation_directory" ]; then
        rm -rf ${installation_directory}
    fi
    curl -o ${archive_file} ${download_link}
    mkdir -p ${installation_directory}
    tar -xvzf ${archive_file} -C ${installation_directory} --strip-components 1 &> /dev/null
    echo '$JMETER_HOME="'${installation_directory}'"'
    ln -s ${installation_directory}/bin/jmeter /usr/bin/jmeter
}

function install_backend_listener() {
    local download_link="https://github.com/axibase/jmeter-time-window-backend-listener/releases/download/v.0.0.3/time-window-backend-listener-0.0.3.jar"
    local tmp_directory=$(mktemp -d)
    local archive_name="time-window-backend-listener-0.0.3.jar";
    local archive_file=${tmp_directory}/${archive_name}
    curl -o ${archive_file} ${download_link}
    installation_directory="/opt/apache/jmeter";
    lib_directory=${installation_directory}'/lib/ext';
    chown -R $(whoami) ${installation_directory}
    cp ${archive_file} ${lib_directory}
    chmod +x ${lib_directory}/${archive_name}
}

if [ "$(whoami)" != "root" ]; then
	echo "Sorry, you are not root."
	exit 1
fi

uninstall_previous
install_jmeter
install_backend_listener