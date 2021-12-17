FROM ruby:alpine3.15

RUN apk add git alpine-sdk && \
  addgroup -S app && \
  adduser -S app -G app

USER app
ENV APP_HOME=/home/app
WORKDIR ${APP_HOME}

COPY --chown=app:app Gemfile talktome.gemspec ${APP_HOME}/
COPY --chown=app:app ./lib/talktome/version.rb ${APP_HOME}/lib/talktome/version.rb

RUN bundle install

COPY . ${APP_HOME}

CMD ["bundle", "exec", "rackup", "--host", "0.0.0.0", "-p", "3000"]

EXPOSE 3000
