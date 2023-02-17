FROM invisiblethemes/gha-shopify-cli:1.0.1
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
