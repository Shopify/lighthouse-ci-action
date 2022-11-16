FROM ruby:3

# Install dependencies
RUN apt-get update \
    && apt-get -y install sudo jq chromium

# Use latest bundler version so that Shopify CLI does not complain
RUN gem install bundler -N

# Install Shopify CLI 2.x
RUN gem install shopify-cli -N

# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
RUN apt-get install -y nodejs

# See https://github.com/nodejs/docker-node/blob/main/docs/BestPractices.md#global-npm-dependencies
# for reasons why we need to set `npm_config_prefix`.
ENV npm_config_prefix="${GITHUB_WORKSPACE:-/home}/.node"
ENV PATH="$npm_config_prefix:${PATH}"

# Install Shopify CLI 3.x
RUN npm install -g @shopify/cli @shopify/theme puppeteer @lhci/cli

# Chrome in Docker fix
# Install latest fonts to support major charsets (Chinese, Japanese, Arabic, Hebrew, Thai and a few others)
# Note: this installs the necessary libs to make the bundled version of Chromium that Puppeteer installs, work.
RUN apt-get install -y fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst fonts-freefont-ttf libxss1 \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
