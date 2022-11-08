# syntax = docker/dockerfile:experimental

ARG RUBY_VERSION=3.1.2-jemalloc
FROM quay.io/evl.ms/fullstaq-ruby:${RUBY_VERSION}-slim as build

ARG RAILS_ENV=production
ARG RAILS_MASTER_KEY
ENV RAILS_ENV=${RAILS_ENV}
ENV BUNDLE_PATH vendor/bundle
ENV RAILS_MASTER_KEY=${RAILS_MASTER_KEY}
ENV SECRET_KEY_BASE 1
RUN mkdir /app
WORKDIR /app

# Reinstall runtime dependencies that need to be installed as packages

RUN --mount=type=cache,id=apt-cache,sharing=locked,target=/var/cache/apt \
    --mount=type=cache,id=apt-lib,sharing=locked,target=/var/lib/apt \
    apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    postgresql-client file rsync git build-essential libpq-dev wget vim curl gzip xz-utils \
    && rm -rf /var/lib/apt/lists /var/cache/apt/archives

RUN curl -sO https://nodejs.org/dist/v16.0.0/node-v16.0.0-linux-x64.tar.xz && cd /usr/local && tar --strip-components 1 -xvf /app/node*xz && rm /app/node*xz && cd ~

RUN gem install -N bundler -v 2.2.17
RUN npm install -g yarn

ENV PATH $PATH:/usr/local/bin

COPY bin/rsync-cache bin/rsync-cache

# Install rubygems
COPY Gemfile* ./

ENV BUNDLE_WITHOUT development:test

RUN --mount=type=cache,target=/cache,id=bundle bin/rsync-cache /cache vendor/bundle "bundle install"

COPY package.json yarn.lock ./

RUN --mount=type=cache,target=/cache,id=node2 \
    bin/rsync-cache /cache node_modules "yarn"

COPY . .

ENV NODE_ENV production

RUN --mount=type=cache,target=/cache,id=assets bin/rsync-cache /cache public/assets "bundle exec rails assets:precompile"

RUN rm -rf node_modules vendor/bundle/ruby/*/cache

FROM quay.io/evl.ms/fullstaq-ruby:${RUBY_VERSION}-slim

ARG RAILS_ENV=production

RUN --mount=type=cache,id=apt-cache,sharing=locked,target=/var/cache/apt \
    --mount=type=cache,id=apt-lib,sharing=locked,target=/var/lib/apt \
    apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    postgresql-client file git wget vim curl gzip  \
    && rm -rf /var/lib/apt/lists /var/cache/apt/archives

ENV RAILS_ENV=${RAILS_ENV}
ENV RAILS_SERVE_STATIC_FILES true
ENV BUNDLE_PATH vendor/bundle
ENV BUNDLE_WITHOUT development:test
ENV RAILS_MASTER_KEY=${RAILS_MASTER_KEY}

COPY --from=build /app /app

WORKDIR /app

RUN mkdir -p tmp/pids
EXPOSE 8080

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
