# shopify/lighthouse-ci-action

[About this repo](#about-this-repo) | [Usage](#usage) | [Authentication](#authentication) | [Configuration](#configuration)

## About this repo

[Lighthouse CI](https://github.com/googleChrome/lighthouse-ci) on Shopify Theme Pull Requests using GitHub Actions.

## Usage

Add `shopify/lighthouse-ci-action` to the workflow of your Shopify theme.

```yml
# .github/workflows/lighthouse-ci.yml
name: Shopify Lighthouse CI
on: [push]
jobs:
  lhci:
    name: Lighthouse
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Lighthouse
        uses: shopify/lighthouse-ci-action@v1
        with:
          store: ${{ secrets.SHOP_STORE }}
          access_token: ${{ secrets.SHOP_ACCESS_TOKEN }}
          lhci_github_app_token: ${{ secrets.LHCI_GITHUB_APP_TOKEN }}
          lhci_min_score_performance: 0.9
          lhci_min_score_accessibility: 0.9
```

## Authentication

1. Follow the steps to [install the Theme Access app](https://shopify.dev/themes/tools/theme-access#install-the-theme-access-app)
2. Follow the steps to [create a password](https://shopify.dev/themes/tools/theme-access#create-a-password)
3. Add the following to your repository's [GitHub Secrets](https://docs.github.com/en/actions/reference/encrypted-secrets#creating-encrypted-secrets-for-an-environment):
   - `SHOPIFY_CLI_THEME_TOKEN`: the Theme Access app password
   - `SHOP_STORE`: Shopify store `<store>.myshopify.com` URL

## Configuration

The `shopify/lighthouse-ci-action` accepts the following arguments:

* `access_token` - (required) see [Authentication](#authentication)
* `store` - (required) Shopify store Admin URL, e.g. `my-store.myshopify.com`.
* `password` - (optional) For password protected shops
* `product_handle` - (optional) Product handle to run the product page Lighthouse run on. Defaults to the first product.
* `theme_root` - (optional) The root folder for the theme files that will be uploaded. Defaults to `.`
* `collection_handle` - (optional) Collection handle to run the product page Lighthouse run on. Defaults to the first collection.
* `lhci_min_score_performance` - (optional, default: 0.6) Minimum performance score for a passed audit (must be between 0 and 1).
* `lhci_min_score_accessibility` - (optional, default: 0.9) Minimum accessibility score for a passed audit

For the GitHub Status Checks on PR. One of the two arguments is required:

* `lhci_github_app_token` - (optional) [Lighthouse GitHub app](https://github.com/apps/lighthouse-ci) token
* `lhci_github_token` - (optional) GitHub personal access token

For more details on the implications of choosing one over the other, refer to the [Lighthouse CI Getting Started Page](https://github.com/GoogleChrome/lighthouse-ci/blob/main/docs/getting-started.md#github-status-checks)

## Docker Image Registry on GitHub
Docker image is hosted on [GitHub packages](ghcr.io).

See [Package configuration on GitHub](https://github.com/orgs/Shopify/packages/container/lighthouse-ci-action/settings) for more details.

### Deprecated authentication configurations

The following were used to authenticate with private apps.

* `app_id` - (deprecated) Shopify store private app ID.
* `app_password` - (deprecated) Shopify store private app password.

Another deprecated authentication method is with [Custom App access tokens](https://shopify.dev/apps/auth/admin-app-access-tokens).

1. [Create the app](https://help.shopify.com/en/manual/apps/custom-apps#create-and-install-a-custom-app).
2. Click the `Configure Admin API Scopes` button.
3. Enable the following scopes:
   - `read_products`
   - `write_themes`
4. Click `Save`.
5. From the `API credentials` tab, install the app.
6. Take note of the `Admin API access token`.
7. Add the following to your repository's [GitHub Secrets](https://docs.github.com/en/actions/reference/encrypted-secrets#creating-encrypted-secrets-for-an-environment):
   - `SHOP_ACCESS_TOKEN`: the Admin API access token
   - `SHOP_STORE`: Shopify store `<store>.myshopify.com` URL
