# Contributing to Shopify/lighthouse-ci-action

We love receiving pull requests!

## Standards

- PR should explain what the feature does, and why the change exists.
- PR should include any carrier specific documentation explaining how it works.
- Code should be generic and reusable.

## How to contribute

1. Fork it ( https://github.com/Shopify/lighthouse-ci-action/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Useful `docker`/`podman` commands

`docker` and `podman` should be interchangeable.

### Start the engine

```shell
podman machine init
podman machine start
```

### Build the base image

```shell
podman build --tag lighthouse -f Dockerfile.base .
```

### Run Lighthouse tests

```shell
THEME_FOLDER="my-theme"
INPUT_STORE="my-store.myshopify.com"
INPUT_PASSWORD="my-password-for-store"
INPUT_ACCESS_TOKEN="shpat_123456789"

podman run --name lighthouse --rm -i -t \
    --mount "type=bind,source=$(pwd)/entrypoint.sh,target=/entrypoint.sh" \
    --mount "type=bind,source=$(pwd)/$THEME_FOLDER,target=/$THEME_FOLDER" \
    -e "INPUT_STORE=$INPUT_STORE" \
    -e "INPUT_THEME_ROOT=./$THEME_FOLDER" \
    -e "INPUT_PASSWORD=$INPUT_PASSWORD" \
    -e "INPUT_ACCESS_TOKEN=$INPUT_ACCESS_TOKEN" \
    --entrypoint "/entrypoint.sh" \
    lighthouse
```

### Remove container

```shell
podman container rm lighthouse -f
```

### Start interactive shell

```shell
podman run -it \
    -e "INPUT_STORE=$INPUT_STORE" \
    -e "INPUT_ACCESS_TOKEN=$INPUT_ACCESS_TOKEN" \
    --mount "type=bind,source=$(pwd)/$THEME_FOLDER,target=/$THEME_FOLDER" \
    --entrypoint /bin/bash \
    lighthouse
```
