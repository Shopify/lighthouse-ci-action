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
        uses: shopify/lighthouse-ci-action
        with:
          app_id: ${{ secrets.SHOP_APP_ID }}
          app_password: ${{ secrets.SHOP_APP_PASSWORD }}
          store: ${{ secrets.SHOP_STORE }}
          lhci_github_app_token: ${{ secrets.LHCI_GITHUB_APP_TOKEN }}
          lhci_min_score_performance: 0.9
          lhci_min_score_accessibility: 0.9
```

## Authentication

Authentication is done with private app credentials. The same ones you'd use with [Theme Kit](https://shopify.dev/tools/theme-kit/getting-started#step-2-generate-api-credentials).

You will need to provide the `app_id`, `app_password` and `store` as parameters to the GitHub action. It is recommended to set these as [GitHub secrets](https://docs.github.com/en/actions/reference/encrypted-secrets#creating-encrypted-secrets-for-an-environment) on your repo.

```yml
jobs:
  lhci:
    name: Lighthouse
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Lighthouse
        uses: shopify/lighthouse-ci-action
        with:
          app_id: ${{ secrets.SHOP_APP_ID }}
          app_password: ${{ secrets.SHOP_APP_PASSWORD }}
          store: ${{ secrets.SHOP_STORE }}
```

## Configuration

The `shopify/lighthouse-ci-action` accepts the following arguments:

* `app_id` - (required) Shopify store private app ID.
* `app_password` - (required) Shopify store private app password.
* `store` - (required) Shopify store `<domain>.myshopify.com` URL.
* `password` - (optional) For password protected shops
* `product_handle` - (optional) Product handle to run the product page Lighthouse run on. Defaults to the first product.
* `theme_root` - (optional) The root folder for the theme assets that will be uploaded. Defaults to `.`
* `collection_handle` - (optional) Collection handle to run the product page Lighthouse run on. Defaults to the first collection.
* `lhci_min_score_performance` - (optional, default: 0.6) Minimum performance score for a passed audit (must be between 0 and 1).
* `lhci_min_score_accessibility` - (optional, default: 0.9) Minimum accessibility score for a passed audit

For the GitHub Status Checks on PR. One of the two arguments is required:

* `lhci_github_app_token` - (optional) [Lighthouse GitHub app](https://github.com/apps/lighthouse-ci) token
* `lhci_github_token` - (optional) GitHub personal access token

For more details on the implications of choosing one over the other, refer to the [Lighthouse CI Getting Started Page](https://github.com/GoogleChrome/lighthouse-ci/blob/main/docs/getting-started.md#github-status-checks)
