FROM cpclermont/lighthouse-ci-action:1.0.0
RUN gem uninstall shopify-cli
# Install dependencies
RUN sudo npm install -g @shopify/cli @shopify/theme
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
