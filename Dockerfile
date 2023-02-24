FROM ghcr.io/poitrin/lighthouse-ci-action:latest
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
