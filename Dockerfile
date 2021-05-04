FROM ruby:2.7.0-alpine

RUN apk add git alpine-sdk

ENV APP_HOME /app
WORKDIR ${APP_HOME}

COPY Gemfile talktome.gemspec $APP_HOME/
COPY ./lib/talktome/version.rb $APP_HOME/lib/talktome/version.rb

RUN bundle install

COPY . $APP_HOME

CMD ["bundle", "exec", "rackup", "--host", "0.0.0.0", "-p", "4567"]

EXPOSE 4567