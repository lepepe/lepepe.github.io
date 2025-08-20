FROM jekyll/jekyll:pages

WORKDIR /srv/jekyll

# Install build dependencies for native Ruby gems
RUN apk add --no-cache build-base
COPY Gemfile ./
RUN bundle install
COPY . .
CMD ["bundle", "exec", "jekyll", "serve", "--watch", "--incremental", "--host", "0.0.0.0"]
