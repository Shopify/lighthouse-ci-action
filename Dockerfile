FROM cpclermont/lighthouse-ci-action:2.0.0
RUN npm install -g @shopify/cli @shopify/theme
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
