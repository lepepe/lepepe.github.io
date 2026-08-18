FROM jekyll/jekyll:pages

WORKDIR /srv/jekyll

# Install build dependencies for native Ruby gems
RUN apt-get update && apt-get install -y --no-install-recommends build-essential
COPY Gemfile ./
RUN bundle install
COPY . .
CMD ["bundle", "exec", "jekyll", "serve", "--watch", "--incremental", "--host", "0.0.0.0"]
