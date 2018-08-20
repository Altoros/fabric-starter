FROM node:8-alpine
LABEL com.altoros.version="0.1"

RUN apk add --update \
    python \
    python-dev \
    py-pip \
    build-base \
    curl \
  && pip install --upgrade pip \
  && pip install virtualenv \
  && rm -rf /var/cache/apk/*

# Create app directory
WORKDIR /usr/src/app
COPY . .