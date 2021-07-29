# Use an official Ruby runtime as a parent image
FROM ruby:3.0.1

ENV APP_DIR="/app/"
RUN mkdir $APP_DIR
WORKDIR $APP_DIR

RUN apt-get update && \
  apt-get upgrade -y && \
  apt-get install -y jq

# Try doing the bundle stuff first
COPY Gemfile Gemfile.lock $APP_DIR
RUN bundle install

# Copy the current directory contents into the container at /app
COPY . $APP_DIR
