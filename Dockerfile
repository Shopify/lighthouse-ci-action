FROM ghcr.io/invisiblethemes/gha-lighthouse-ci:2.0.0
LABEL org.opencontainers.image.source https://github.com/Shopify/lighthouse-ci-action
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
