# pull official base image
FROM python:3.8-buster

# set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# create Django directory for the app user
ARG UID=1000
RUN groupadd app && useradd -m -u ${UID} app -g app
ENV APP_HOME=/usr/src/app
RUN mkdir -p $APP_HOME && \
    mkdir $APP_HOME/staticfiles && \
    mkdir $APP_HOME/staticfiles/media_root && \
    mkdir $APP_HOME/staticfiles/static_root

# set work directory
WORKDIR $APP_HOME

# install dependencies
COPY --chown=app:app ./Pipfile .
COPY --chown=app:app ./Pipfile.lock .
RUN apt update && \
    apt install -y libpq5 libxml2 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*  && \
    pip install pipenv && \
    pipenv install --dev --system

# copy entrypoint shell file
COPY --chown=app:app ./entrypoint.sh $APP_HOME

# copy project
COPY --chown=app:app . $APP_HOME

# change to the app user
USER ${UID}

# run entrypoint shell file
ENTRYPOINT ["/usr/src/app/entrypoint.sh"]
