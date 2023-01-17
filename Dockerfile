FROM cpclermont/lighthouse-ci-action:1.0.0
RUN gem uninstall shopify-cli
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
