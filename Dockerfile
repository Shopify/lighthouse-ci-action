FROM node:22-bookworm

# Install system dependencies
RUN apt-get update \
    && apt-get -y install sudo jq \
    && apt-get clean

# Install latest chrome stable package (using signed-by for Bookworm compatibility).
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/google-chrome.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update \
    && apt-get install -y google-chrome-stable --no-install-recommends \
    && apt-get clean

# Install puppeteer and LHCI
ENV npm_config_prefix="$GITHUB_WORKSPACE/.node"
ENV PATH="$npm_config_prefix:${PATH}"
RUN mkdir -p "$npm_config_prefix" \
  && chmod -R 777 "$npm_config_prefix" \
  && umask 000 \
  && npm install -g @lhci/cli@0.13.x lighthouse puppeteer

# Install Shopify CLI
RUN npm install -g @shopify/cli

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
