FROM invisiblethemes/gha-lighthouse-ci:2.0.0
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
