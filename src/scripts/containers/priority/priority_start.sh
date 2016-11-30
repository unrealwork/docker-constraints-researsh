#!/usr/bin/env bash
rm -rf ~/myblog
jekkyl new myblog
docker run --name docker-nginx -p 80:80 -d -v ~/myblog/_site/:/usr/share/nginx/html nginx