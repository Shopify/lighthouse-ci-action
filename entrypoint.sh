#!/usr/bin/env bash

####################################################################
# START of GitHub Action specific code

# This script assumes that node, curl, sudo, python and jq are installed.

# If you want to run this script in a non-GitHub Action environment,
# all you'd need to do is set the following environment variables and
# delete the code below. Everything else is platform independent.
#
# Here, we're translating the GitHub action input arguments into environment variables
# for this scrip to use.
[[ -n "$INPUT_APP_ID" ]]            && export SHOP_APP_ID="$INPUT_APP_ID"
[[ -n "$INPUT_APP_PASSWORD" ]]      && export SHOP_APP_PASSWORD="$INPUT_APP_PASSWORD"
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

cleanup() {
  if [[ -s "$errlog" ]]; then
    cat "$errlog"
  fi

  if [[ -n "${theme_id+x}" ]]; then
    step "Disposing ephemeral theme"
    curl -s -X DELETE \
      -u $username:$password \
      "$host/admin/api/2021-04/themes/$theme_id.json"
  fi

  if [[ -f "lighthouserc.yml" ]]; then
    rm "lighthouserc.yml"
  fi

  if [[ -f "setPreviewCookies.js" ]]; then
    rm "setPreviewCookies.js"
  fi

  if [[ -n "${theme_placeholder_dir+x}" ]]; then
    rm -rf "$theme_placeholder_dir"
  fi

  return $1
}

trap 'cleanup $?' EXIT

if ! is_installed lhci; then
  step "Installing Lighthouse CI"
  log npm install -g @lhci/cli@0.7.x puppeteer
  npm install -g @lhci/cli@0.7.x puppeteer
fi

if ! is_installed theme; then
  step "Installing Theme Kit"
  log "curl -s https://shopify.dev/themekit.py | sudo python"
  curl -s https://shopify.dev/themekit.py | sudo python
fi

step "Configuring Theme Kit"
username="$SHOP_APP_ID"
password="$SHOP_APP_PASSWORD"
host="https://$SHOP_STORE"
errlog="$(mktemp)"

# Use the $SHOP_PASSWORD defined as a Github Secret for password protected stores.
[[ -z ${SHOP_PASSWORD+x} ]] && shop_password='' || shop_password="$SHOP_PASSWORD"

theme_root="$THEME_ROOT"

log "Will run Lighthouse CI on $host"

step "Creating ephemeral theme"
export THEMEKIT_PASSWORD="$SHOP_APP_PASSWORD"
export THEMEKIT_STORE="$SHOP_STORE"
commit_sha="$(echo ${GITHUB_SHA:-$(git rev-parse --ref HEAD)} | head -c 8)"
theme_name="lhci/$commit_sha"

# We're creating a fake theme here to bypass theme-kit validation. We're going to remove those files.
theme_placeholder_dir="$(mktemp -d)"
theme new --env="lighthouse-ci" --dir "$theme_placeholder_dir" --no-ignore --name="$theme_name" \
  &> "$errlog" && rm "$errlog"

# Getting the theme_id from the theme_name
theme_id="$(
  theme get --list \
    | grep "$theme_name" \
    | tail -n 1 \
    | cut -d ' ' -f3 \
    | sed -e 's/\[//g' -e 's/\]//g'
)"

export THEMEKIT_THEME_ID="$theme_id"

step "Deleting placeholder files"
placeholder_files="$(
  cd $theme_placeholder_dir &&  \
  find * -type f -print \
  | grep -E -v "^config/" \
  | grep -E -v "^layout/theme.liquid" \
  | grep -E -v "^templates/gift_card.liquid" \
  | xargs
)"
theme --env="lighthouse-ci" --dir "$theme_placeholder_dir" remove $placeholder_files \
  &> "$errlog" && rm "$errlog"

# Files must be uploaded in a certain order otherwise Theme Kit will
# complain about using section files before they are defined.
step "Deploying ephemeral theme"
for folder in assets locales snippets layout sections templates config; do
  log theme --env="lighthouse-ci" --dir="$theme_root" deploy $folder
  theme --env="lighthouse-ci" --dir="$theme_root" deploy $folder \
    &> "$errlog" && rm "$errlog"
done

step "Configuring Lighthouse CI"

if [[ -n "${SHOP_PRODUCT_HANDLE+x}" ]]; then
  product_handle="$SHOP_PRODUCT_HANDLE"
else
  product_handle="$(
    curl -s -X GET \
      -u $username:$password \
      "$host/admin/api/2021-04/products.json?published_status=published&limit=1" \
      | jq -r '.products[0].handle'
  )"
fi

if [[ -n "${SHOP_COLLECTION_HANDLE+x}" ]]; then
  collection_handle="$SHOP_COLLECTION_HANDLE"
else
  collection_handle="$(
    curl -s -X GET \
      -u $username:$password \
      "$host/admin/api/2021-04/custom_collections.json?published_status=published&limit=1" \
      | jq -r '.custom_collections[0].handle'
  )"
fi

# Disable redirects + preview bar
query_string="?_fd=0&pb=0"
min_score_performance="${LHCI_MIN_SCORE_PERFORMANCE:-'0.6'}"
min_score_accessibility="${LHCI_MIN_SCORE_ACCESSIBILITY:-'0.9'}"

cat <<- EOF > lighthouserc.yml
ci:
  collect:
    url:
      - $host/$query_string
      - $host/products/$product_handle$query_string
      - $host/collections/$collection_handle$query_string
    puppeteerScript: './setPreviewCookies.js'
    puppeteerLaunchOptions:
      args:
        - "--no-sandbox"
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
  const page = await browser.newPage();
  // Get password cookie if password is set
  if ('$shop_password' !== '') await page.goto('$host/password?password=$shop_password');
  // Get preview cookie
  await page.goto('$host?_fd=0&preview_theme_id=$theme_id');
  // close session for next run
  await page.close();
};
EOF

step "Running Lighthouse CI"
lhci autorun
