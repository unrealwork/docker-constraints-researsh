#!/usr/bin/env bash
constraint=$1;
SITE_NAME="myblog"
SITE_FOLDER="${SITE_NAME}"

if [[ -z ${constraint} ]];then
   echo "Start container without constarint";
else
    echo "Start priority container with constarint: ${constraint}";
fi
echo "Blog will be generated in ${SITE_FOLDER} folder";
if [ -d ${SITE_FOLDER} ]; then
  echo "Remove previous version of site";
  rm -rf ${SITE_FOLDER};
else
  echo "There is no previous version of site";
fi
if [[ -z $(which jekyll) ]]; then
    echo "You need to install jekyll generator!"
    exit 1;
else
    jekyll new ${SITE_NAME}
fi
if [[ -z $(which docker) ]]; then
    echo "You need to install docker generator!"
    exit 1;
else
    docker rm -f docker-nginx &> /dev/null
    docker run --name docker-nginx ${constraint} -p 80:80 -d -v ~/myblog/_site/:/usr/share/nginx/html nginx
fi

