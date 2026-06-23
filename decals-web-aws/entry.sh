#!/bin/bash
# legacypipe / tractor / astrometry are provided by the base image (ENV PYTHONPATH=/usr/local/lib/python).
# Only the viewer (imagine) code needs adding to the path.
export PYTHONPATH=/app/decals-web:${PYTHONPATH}

# matplotlib needs a writable config dir (READ_ONLY_BASEDIR).
mkdir -p /tmp/matplotlib
export MPLCONFIGDIR=/tmp/matplotlib

cd /app/decals-web
service nginx start
uwsgi --ini uwsgi.ini
