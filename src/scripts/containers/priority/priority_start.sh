#!/usr/bin/env bash
rm -rf ~/myblog
jekyll new myblog
docker rm -f docker-nginx
docker run --name docker-nginx -p 80:80 -d -v ~/myblog/_site/:/usr/share/nginx/html nginx