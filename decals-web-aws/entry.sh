#!/bin/bash
# legacypipe / tractor / astrometry come from the base image's PYTHONPATH
# (/src/legacypipe/py, /usr/local/lib/python, ...). Prepend the viewer (imagine)
# code; do NOT clobber the inherited PYTHONPATH.
export PYTHONPATH=/app/decals-web:${PYTHONPATH}

# matplotlib needs a writable config dir; uwsgi drops to www-data (uid 33),
# so make it world-writable to avoid the slow-import fallback warning.
mkdir -p /tmp/matplotlib && chmod 777 /tmp/matplotlib
export MPLCONFIGDIR=/tmp/matplotlib

cd /app/decals-web
service nginx start
uwsgi --ini uwsgi.ini
