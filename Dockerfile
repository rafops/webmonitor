FROM ruby:2.7-alpine AS builder
RUN apk add --update \
  build-base
WORKDIR /usr/local/src
COPY Gemfile Gemfile.lock ./
RUN bundle config set without 'test development' && \
  bundle install

FROM ruby:2.7-alpine
COPY --from=builder /usr/local/bundle/ /usr/local/bundle/
WORKDIR /opt/webmonitor
COPY webmonitor.rb ./
RUN adduser -D webmonitor
USER webmonitor
ENTRYPOINT ["ruby", "webmonitor.rb"]
