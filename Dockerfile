FROM ghcr.io/poitrin/lighthouse-ci-action-alternative:1.1.0
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
