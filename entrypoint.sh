#!/usr/bin/env bash

####################################################################
# START of GitHub Action specific code

# This script assumes that node, curl, sudo, python and jq are installed.

# If you want to run this script in a non-GitHub Action environment,
# all you'd need to do is set the following environment variables and
# delete the code below. Everything else is platform independent.
#
# Here, we're translating the GitHub action input arguments into environment variables
# for this script to use.
[[ -n "$INPUT_THEME_TOKEN" ]]       && export SHOP_THEME_TOKEN="$INPUT_THEME_TOKEN"
[[ -n "$INPUT_STORE" ]]             && export SHOP_STORE="$INPUT_STORE"
[[ -n "$INPUT_PASSWORD" ]]          && export SHOP_PASSWORD="$INPUT_PASSWORD"
[[ -n "$INPUT_PRODUCT_HANDLE" ]]    && export SHOP_PRODUCT_HANDLE="$INPUT_PRODUCT_HANDLE"
[[ -n "$INPUT_COLLECTION_HANDLE" ]] && export SHOP_COLLECTION_HANDLE="$INPUT_COLLECTION_HANDLE"
[[ -n "$INPUT_THEME_ROOT" ]]        && export THEME_ROOT="$INPUT_THEME_ROOT"

# Optional, these are used by Lighthouse CI to add pass/fail checks on
# the GitHub Pull Request.
[[ -n "$INPUT_LHCI_GITHUB_APP_TOKEN" ]] && export LHCI_GITHUB_APP_TOKEN="$INPUT_LHCI_GITHUB_APP_TOKEN"
[[ -n "$INPUT_LHCI_GITHUB_TOKEN" ]]     && export LHCI_GITHUB_TOKEN="$INPUT_LHCI_GITHUB_TOKEN"

# Optional, these are used
[[ -n "$INPUT_LHCI_MIN_SCORE_PERFORMANCE" ]]   && export LHCI_MIN_SCORE_PERFORMANCE="$INPUT_LHCI_MIN_SCORE_PERFORMANCE"
[[ -n "$INPUT_LHCI_MIN_SCORE_ACCESSIBILITY" ]] && export LHCI_MIN_SCORE_ACCESSIBILITY="$INPUT_LHCI_MIN_SCORE_ACCESSIBILITY"

# Add global node bin to PATH (from the Dockerfile)
export PATH="$PATH:$npm_config_prefix/bin"

# END of GitHub Action Specific Code
####################################################################

# Portable code below
set -eou pipefail

log() {
  echo "$@" 1>&2
}

step() {
  cat <<-EOF 1>&2
	==============================
	$1
	EOF
}

is_installed() {
  # This works with scripts and programs. For more info, check
  # http://goo.gl/B9683D
  type $1 &> /dev/null 2>&1
}

api_request() {
  local url="$1"
  local err="$(mktemp)"
  local out="$(mktemp)"

  set +e
  curl -sS -f -X GET \
    "$url" \
    -H "X-Shopify-Access-Token: ${SHOP_THEME_TOKEN}" \
    1> "$out" \
    2> "$err"
  set -e

  local exit_code="$?"
  local errors="$(cat "$out" | jq '.errors')"

  if [[ $exit_code != '0' ]]; then
    log "There's been a curl error when querying the API"
    cat "$err" 1>&2
    return 1
  elif [[ $errors != 'null' ]]; then
    log "There's been an error when querying the API"
    log "$errors"
    cat "$err" 1>&2
    return 1
  fi

  cat "$out"
}

cleanup() {
  if [[ -n "${theme+x}" ]]; then
    step "Disposing development theme"
    shopify theme delete -d -f
    shopify logout
  fi

  if [[ -f "lighthouserc.yml" ]]; then
    rm "lighthouserc.yml"
  fi

  if [[ -f "setPreviewCookies.js" ]]; then
    rm "setPreviewCookies.js"
  fi

  return $1
}

trap 'cleanup $?' EXIT

step "Configuring shopify CLI"

# Disable analytics
mkdir -p ~/.config/shopify && cat <<-YAML > ~/.config/shopify/config
[analytics]
enabled = false
YAML

# Secret environment variable that turns shopify CLI into CI mode that accepts environment credentials
export SHOPIFY_CLI_TTY=0
export SHOPIFY_FLAG_STORE="${SHOP_STORE#*(https://|http://)}"
export SHOPIFY_CLI_THEME_TOKEN="$SHOP_THEME_TOKEN"

host="https://${SHOP_STORE#*(https://|http://)}"
theme_root="${THEME_ROOT:-.}"

# Use the $SHOP_PASSWORD defined as a Github Secret for password protected stores.
[[ -z ${SHOP_PASSWORD+x} ]] && shop_password='' || shop_password="$SHOP_PASSWORD"

log "Will run Lighthouse CI on $host"

step "Creating development theme"

theme_push_log="$(mktemp)"

theme_command="shopify theme push --development --path=$theme_root > "$theme_push_log" && cat "$theme_push_log""

log theme_command

eval theme_command

preview_url="$(cat "$theme_push_log" | awk '/View your theme:/{getline; print}' | sed 's/^ *//g')"
editor_url="$(cat "$theme_push_log" | awk '/Customize this theme in the Theme Editor:/{getline; print}' | sed 's/^ *//g')"
preview_id="$(echo "$editor_url" | sed -n 's/.*themes\/\([0-9]*\)\/editor.*/\1/p')"

if [ $? -eq 1 ]; then
  echo "Error pushing theme" >&2
  exit 1
fi

step "Configuring Lighthouse CI"

if [[ -n "${SHOP_PRODUCT_HANDLE+x}" ]]; then
  product_handle="$SHOP_PRODUCT_HANDLE"
else
  log "Fetching product handle"
  product_response="$(api_request "$host/admin/api/2021-04/products.json?published_status=published&limit=1")"
  product_handle="$(echo "$product_response" | jq -r '.products[0].handle')"
  log "Using $product_handle"
fi

if [[ -n "${SHOP_COLLECTION_HANDLE+x}" ]]; then
  collection_handle="$SHOP_COLLECTION_HANDLE"
else
  log "Fetching collection handle"
  collection_response="$(api_request "$host/admin/api/2021-04/custom_collections.json?published_status=published&limit=1")"
  collection_handle="$(echo "$collection_response" | jq -r '.custom_collections[0].handle')"
  log "Using $collection_handle"
fi

# Disable redirects + preview bar
query_string="?preview_theme_id=${preview_id}&_fd=0&pb=0"
min_score_performance="${LHCI_MIN_SCORE_PERFORMANCE:-0.6}"
min_score_accessibility="${LHCI_MIN_SCORE_ACCESSIBILITY:-0.9}"

cat <<- EOF > lighthouserc.yml
ci:
  collect:
    url:
      - "$host/$query_string"
      - "$host/products/$product_handle$query_string"
      - "$host/collections/$collection_handle$query_string"
    puppeteerScript: './setPreviewCookies.js'
    puppeteerLaunchOptions:
      args:
        - "--no-sandbox"
        - "--disable-setuid-sandbox"
        - "--disable-dev-shm-usage"
        - "--disable-gpu"
  upload:
    target: temporary-public-storage
  assert:
    assertions:
      "categories:performance":
        - error
        - minScore: $min_score_performance
          aggregationMethod: median-run
      "categories:accessibility":
        - error
        - minScore: $min_score_accessibility
          aggregationMethod: median-run
EOF

cat <<-EOF > setPreviewCookies.js
module.exports = async (browser) => {
  // launch browser for LHCI
  console.error('Getting a new page...');
  const page = await browser.newPage();
  // Get password cookie if password is set
  if ('$shop_password' !== '') {
    console.error('Getting password cookie...');
    await page.goto('$host/password$query_string');
    await page.waitForSelector('form[action*=password] input[type="password"]');
    await page.\$eval('form[action*=password] input[type="password"]', input => input.value = '$shop_password');
    await Promise.all([
      page.waitForNavigation(),
      page.\$eval('form[action*=password]', form => form.submit()),
    ])
  }
  // Get preview cookie
  console.error('Getting preview cookie...');
  await page.goto('$preview_url');
  // close session for next run
  await page.close();
};
EOF

step "Running Lighthouse CI"
lhci autorun
