FROM ghcr.io/shopify/lighthouse-ci-action:3.0.0
RUN npm install -g @shopify/cli @shopify/theme
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
