# Lighthouse CI Action

## About this repo

This theme uses [Lighthouse CI](https:/github.com/googleChrome/lighthouse-ci) on Shopify Theme Pull Requests using GitHub Actions and was forked from [Shopify/lighthouse-ci-action](https://github.com/Shopify/lighthouse-ci-action).

## Installation

[TODO]

## Usage

[TODO]

## Updating Dockerfile.base

If you update the base Dockerfile you'll have to do the following:
1. Run `docker login` with an account that has access to the invisiblethemes Docker Hub account
1. Run `make push` to build the docker image and push it to Docker Hub.

TODO: automate this with a GH Action for Rosey itself
