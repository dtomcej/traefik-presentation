#!/bin/bash

set -eux

ZIP_FILE=gh-pages.zip
REPOSITORY_NAME=traefik-presentation
REPOSITORY_OWNER=dduportal
REPOSITORY_URL="https://github.com/${REPOSITORY_OWNER}/${REPOSITORY_NAME}/archive/${ZIP_FILE}"
CURRENT_DIR="$(cd "$(dirname "${0}")" && pwd -P)"
DOCS_DIR="${CURRENT_DIR}/../docs"

# Rebuild the docs directory which will be uploaded to gh-pages
rm -rf "${DOCS_DIR}"
if curl -sSLI --fail "${REPOSITORY_URL}"
then
    curl -sSLO "${REPOSITORY_URL}"
    unzip -o "./${ZIP_FILE}"
    mv ./${REPOSITORY_NAME}-${ZIP_FILE%%.*} "${DOCS_DIR}" # No ".zip" at the end
    rm -f "./${ZIP_FILE}"
else
    echo "== No gh-pages found, I assume this is the first time."
    mkdir -p "${DOCS_DIR}"
fi

# If a tag triggered the deploy, we deploy to a folder having the tag name
# otherwise we are on master and we deploy into latest
set +u
if [ -n "${TRAVIS_TAG}" ]; then
    DEPLOY_DIR="${DOCS_DIR}/${TRAVIS_TAG}"

    # Generate QRCode and overwrite the default one
    make chmod
    make qrcode
else
    DEPLOY_DIR="${DOCS_DIR}"
fi
set -u

cp -r ./dist/* "${DEPLOY_DIR}/"
