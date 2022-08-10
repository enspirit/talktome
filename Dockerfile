FROM ruby:3-alpine3.15

ENV APP_HOME=/home/app

RUN apk add git alpine-sdk && \
  addgroup -S app && \
  adduser -S app -G app && \
  mkdir -p ${APP_HOME} && \
  chown app:app ${APP_HOME}

USER app
WORKDIR ${APP_HOME}

COPY --chown=app:app Gemfile talktome.gemspec ${APP_HOME}/
COPY --chown=app:app ./lib/talktome/version.rb ${APP_HOME}/lib/talktome/version.rb

RUN bundle install

COPY --chown=app:app . ${APP_HOME}

CMD ["bundle", "exec", "rackup", "--host", "0.0.0.0", "-p", "3000"]

EXPOSE 3000
