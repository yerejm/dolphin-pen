#!/bin/bash
# Although the app migration loads the tables, it does not detect zinnia. Only
# after the migration of the application itself occurs will zinnia be detected.
# Then the zinnia migration has to be generated and applied.
set -e
source ../bin/activate
python manage.py migrate
python manage.py makemigrations
python manage.py migrate
python manage.py collectstatic --noinput

