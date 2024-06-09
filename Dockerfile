ARG DBT_VERSION=1.8.latest
FROM ghcr.io/dbt-labs/dbt-postgres:${DBT_VERSION}

ENV DBT_PROFILES_DIR=.


RUN set -ex \
    && python -m pip install setuptools 
    # \
    # && python -m pip install dbt-postgres==1.7.1 dbt-core==1.7.1 numpy


ENTRYPOINT [ "tail", "-f", "/dev/null" ]
