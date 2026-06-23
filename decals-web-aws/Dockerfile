# DR11 AWS viewer ("lite", Elastic Beanstalk) -- single container: nginx -> uwsgi -> Django (imagine).
#
# Modernized 2026-06 for DR11. The old image (python:3.6-buster + hand-built intel-numpy +
# astrometry 0.84 / tractor dr9.5) predated DR10/DR11. We now build on Dustin Lang's current
# recipe (imagine docker/spin/Dockerfile), which bakes the full scientific stack
# (astrometry.net, tractor, legacypipe, numpy/scipy/astropy/fitsio) into the base image.
# Only the lightweight web layer is pip-installed here.
#
# NOTE: pin the base tag to whatever the DR11 render image used; DR10.3.7b is the current
# legacypipe release image. Bump if a newer DR11-specific tag exists.
FROM legacysurvey/legacypipe:DR10.3.7b

SHELL ["/bin/bash", "-c"]

# Web-server layer. The AWS "lite" deployment runs nginx and uwsgi together in one container
# (the Spin deployment splits nginx into its own container instead).
RUN apt-get update && \
    apt-get install -y --no-install-recommends nginx curl git && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Python web dependencies only (heavy science deps come from the base image).
RUN for x in \
      Django \
      pillow \
      psutil \
      psycopg2-binary \
      uwsgi \
      requests \
      tzdata \
      numba \
      bokeh \
    ; do \
      python3 -m pip install --no-cache-dir --break-system-packages "$x"; \
    done

# legacypipe/tractor/astrometry are installed under /usr/local/lib/python in the base image.
ENV PYTHONPATH=/usr/local/lib/python

WORKDIR /app

# Catalog helper files the viewer loads at runtime (SGA ellipses + Tycho-2).
# Done before COPY so the data dir exists; COPY does not delete these.
RUN mkdir -p /app/decals-web/data/sga && \
    curl -fSL -o /app/decals-web/data/sga/SGA-ellipse-v3.2-cut.kd.fits \
        https://portal.nersc.gov/project/cosmo/temp/dstn/SGA-ellipse-v3.2-cut.kd.fits && \
    curl -fSL -o /app/decals-web/data/tycho2-sub.kd.fits \
        https://portal.nersc.gov/project/cosmo/temp/dstn/tycho2-sub.kd.fits

# App code (this directory: entry.sh, viewer.conf, uwsgi_params, and the decals-web submodule).
COPY . /app

# Select the AWS "lite" dev settings (dev.viewer.legacysurvey.org, ENABLE_DR11).
# The viewer code does `from viewer import settings` (a direct module import) and
# wsgi.py/manage.py default to DJANGO_SETTINGS_MODULE=viewer.settings, but the repo
# ships no settings.py -- so materialize it from settings_pr_dev.py.
RUN cp /app/decals-web/viewer/settings_pr_dev.py /app/decals-web/viewer/settings.py

# nginx site config (proxies / -> uwsgi at 127.0.0.1:3032, serves /static).
RUN ln -sf /app/viewer.conf /etc/nginx/sites-enabled/ && \
    rm -f /etc/nginx/sites-enabled/default

EXPOSE 80

ENTRYPOINT ["/app/entry.sh"]
