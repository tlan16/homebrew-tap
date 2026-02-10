FROM ruby:alpine

WORKDIR /app
COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .
CMD ["tail", "-f", "/dev/null"]
