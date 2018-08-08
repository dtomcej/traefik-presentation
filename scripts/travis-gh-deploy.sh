#!/bin/bash

set -eux

ZIP_FILE=gh-pages.zip
REPOSITORY_NAME=traefik-presentation
REPOSITORY_OWNER=dduportal
REPOSITORY_URL="https://github.com/${REPOSITORY_OWNER}/${REPOSITORY_NAME}/archive/${ZIP_FILE}"
CURRENT_DIR="$(cd "$(dirname "${0}")" && pwd -P)"

# Rebuild the docs directory which will be uploaded to gh-pages
rm -rf "${CURRENT_DIR}/docs"
if curl -sSLI --fail "${REPOSITORY_URL}"
then
    curl -sSLO "${REPOSITORY_URL}"
    unzip -o "./${ZIP_FILE}"
    mv ./${REPOSITORY_NAME}-${ZIP_FILE%%.*} "${CURRENT_DIR}/docs" # No ".zip" at the end
    rm -f "./${ZIP_FILE}"
else
    echo "== No gh-pages found, I assume this is the first time."
    mkdir -p "${CURRENT_DIR}/docs"
fi

# If a tag triggered the deploy, we deploy to a folder having the tag name
# otherwise we are on master and we deploy into latest
set +u
if [ -n "${TRAVIS_TAG}" ]; then
    DEPLOY_DIR="${CURRENT_DIR}/docs/${TRAVIS_TAG}"

    # Generate QRCode and overwrite the default one
    make chmod
    make qrcode
else
    DEPLOY_DIR="${CURRENT_DIR}/docs"
fi
set -u

cp -r ./dist/* "${DEPLOY_DIR}/"
