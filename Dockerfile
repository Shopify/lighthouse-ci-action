FROM ghcr.io/shopify/lighthouse-ci-action:1.1.0
LABEL org.opencontainers.image.source https://github.com/Shopify/lighthouse-ci-action
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
