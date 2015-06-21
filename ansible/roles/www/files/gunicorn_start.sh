#!/bin/bash
set -e
source ../bin/activate
gunicorn -c gunicorn.conf.py -p gunicorn.pid dolweb.wsgi

