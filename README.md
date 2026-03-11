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
      - uses: actions/checkout@v4
      - name: Lighthouse
        uses: shopify/lighthouse-ci-action@v1
        with:
          store: ${{ secrets.SHOP_STORE }}
          client_id: ${{ secrets.SHOP_CLIENT_ID }}
          client_secret: ${{ secrets.SHOP_CLIENT_SECRET }}
          lhci_github_app_token: ${{ secrets.LHCI_GITHUB_APP_TOKEN }}
          lhci_min_score_performance: 0.9
          lhci_min_score_accessibility: 0.9
```

## Authentication

### Dev Dashboard App (recommended — required for apps created after Jan 2026)

1. [Create an app via the Shopify Dev Dashboard](https://shopify.dev/docs/apps/build/dev-dashboard/create-apps-using-dev-dashboard).
2. When creating the app version, configure these required access scopes:
   - `read_products`
   - `write_themes`
3. Install the app on your store.
4. Copy the `client_id` and `client_secret` from the app credentials.
5. Add the following to your repository's [GitHub Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets#creating-encrypted-secrets-for-a-repository):
   - `SHOP_CLIENT_ID`: the client ID
   - `SHOP_CLIENT_SECRET`: the client secret
   - `SHOP_STORE`: Shopify store `<store>.myshopify.com` URL

Tokens are fetched automatically at the start of each action run and are valid for 24 hours — well beyond the duration of a typical run.

```yml
- uses: shopify/lighthouse-ci-action@v1
  with:
    store: ${{ secrets.SHOP_STORE }}
    client_id: ${{ secrets.SHOP_CLIENT_ID }}
    client_secret: ${{ secrets.SHOP_CLIENT_SECRET }}
```

### Legacy Custom App (for apps created before Jan 2026)

> [!IMPORTANT]
> As of January 1, 2026 Shopify no longer allows creating new custom apps. Existing custom apps continue to work with this method.

1. [Create the app](https://help.shopify.com/en/manual/apps/custom-apps#create-and-install-a-custom-app).
2. Click the `Configure Admin API Scopes` button.
3. Enable the following scopes:
   - `read_products`
   - `write_themes`
4. Click `Save`.
5. From the `API credentials` tab, install the app.
6. Take note of the `Admin API access token`.
7. Add the following to your repository's [GitHub Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets#creating-encrypted-secrets-for-a-repository):
   - `SHOP_ACCESS_TOKEN`: the Admin API access token
   - `SHOP_STORE`: Shopify store `<store>.myshopify.com` URL

```yml
- uses: shopify/lighthouse-ci-action@v1
  with:
    store: ${{ secrets.SHOP_STORE }}
    access_token: ${{ secrets.SHOP_ACCESS_TOKEN }}
```

## Configuration

The `shopify/lighthouse-ci-action` accepts the following arguments:

**Authentication (one method required):**
* `client_id` - Client ID for a Dev Dashboard app (use with `client_secret`)
* `client_secret` - Client secret for a Dev Dashboard app (use with `client_id`)
* `access_token` - Legacy custom app access token (for apps created before Jan 2026)

**Store:**
* `store` - (required) Shopify store Admin URL, e.g. `my-store.myshopify.com`.

**Optional:**
* `password` - For password protected shops
* `product_handle` - Product handle to run the product page Lighthouse run on. Defaults to the first product.
* `theme_root` - The root folder for the theme files that will be uploaded. Defaults to `.`
* `collection_handle` - Collection handle to run the collection page Lighthouse run on. Defaults to the first collection.
* `pull_theme` - The ID or name of a theme from which the settings and JSON templates should be used. If not provided Lighthouse will be run against the theme's default settings.
* `lhci_min_score_performance` - (default: 0.6) Minimum performance score for a passed audit (must be between 0 and 1).
* `lhci_min_score_accessibility` - (default: 0.9) Minimum accessibility score for a passed audit

For the GitHub Status Checks on PR. One of the two arguments is required:

* `lhci_github_app_token` - (optional) [Lighthouse GitHub app](https://github.com/apps/lighthouse-ci) token
* `lhci_github_token` - (optional) GitHub personal access token

For more details on the implications of choosing one over the other, refer to the [Lighthouse CI Getting Started Page](https://github.com/GoogleChrome/lighthouse-ci/blob/main/docs/getting-started.md#github-status-checks)
