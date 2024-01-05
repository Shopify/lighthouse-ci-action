FROM node:18-buster

ENV PATH="/root/.rbenv/shims:${PATH}"

# Install dependencies
RUN apt-get update \
    && apt-get -y install sudo jq rbenv \
    && mkdir -p "$(rbenv root)"/plugins \
    && git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build \
    && git -C "$(rbenv root)"/plugins/ruby-build pull \
    && rbenv install 3.2.0 \
    && rbenv global 3.2.0

ENV npm_config_prefix="$GITHUB_WORKSPACE/.node"
ENV PATH="$npm_config_prefix:${PATH}"
RUN mkdir -p "$npm_config_prefix" \
  && chmod -R 777 "$npm_config_prefix" \
  && umask 000 \
  && npm install -g @lhci/cli@0.13.x puppeteer \
  && npx puppeteer browsers install chrome

# every time
RUN npm install -g @shopify/cli @shopify/theme
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
