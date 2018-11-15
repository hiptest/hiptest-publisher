FROM ruby:2.5.3-alpine

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY . /usr/src/app

RUN set -ex \
  && apk add --no-cache --virtual .builddeps \
    autoconf \
    coreutils \
    gcc \
    git \
    libc-dev \
    make \
    libxml2-dev \
  && bundle install --without="development test" --jobs=3 --retry=3 --no-cache \
  && git config --global user.name 'Snail Mail' \
  && git config --global user.email '<>' \
  && git init . \
  && git add . \
  && git commit -m 'fake commit' \
  && bundle exec rake install \
  && rm -rf /usr/local/bundle/cache \
    /root/.bundle \
    /root/.gem \
    .git \
  && apk del --no-cache .builddeps

ENTRYPOINT ["hiptest-publisher"]

# RUN chmod 777 .
WORKDIR /app
VOLUME /app
