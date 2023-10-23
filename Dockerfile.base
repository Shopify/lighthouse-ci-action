FROM node:14-buster

ENV PATH="/root/.rbenv/shims:${PATH}"

# Install dependencies
RUN apt-get update \
    && apt-get -y install sudo jq rbenv \
    && mkdir -p "$(rbenv root)"/plugins \
    && git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build \
    && git -C "$(rbenv root)"/plugins/ruby-build pull \
    && rbenv install 3.1.4 \
    && rbenv global 3.1.4 \
    && gem install shopify-cli -N

###
# Chrome in Docker fix
# Install latest chrome dev package and fonts to support major charsets (Chinese, Japanese, Arabic, Hebrew, Thai and a few others)
# Note: this installs the necessary libs to make the bundled version of Chromium that Puppeteer installs, work.
RUN apt-get update \
    && apt-get install -y wget gnupg \
    && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
    && apt-get update \
    && apt-get install -y google-chrome-stable fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst fonts-freefont-ttf libxss1 \
      --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

ENV npm_config_prefix="$GITHUB_WORKSPACE/.node"
ENV PATH="$npm_config_prefix:${PATH}"
RUN mkdir -p "$npm_config_prefix" \
  && chmod -R 777 "$npm_config_prefix" \
  && umask 000 \
  && npm install -g @lhci/cli@0.8.x puppeteer
