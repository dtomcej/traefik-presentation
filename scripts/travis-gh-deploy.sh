#!/bin/bash

set -eux

ZIP_FILE=gh-pages.zip
REPOSITORY_NAME=traefik-presentation
REPOSITORY_OWNER=dduportal
REPOSITORY_URL="https://github.com/${REPOSITORY_OWNER}/${REPOSITORY_NAME}/archive/${ZIP_FILE}"
GH_PAGE_BASE_URL="https://${REPOSITORY_OWNER}.github.io/${REPOSITORY_NAME}"

# Rebuild the docs directory which will be uploaded to gh-pages
rm -rf ./docs
curl -sSLO "${REPOSITORY_URL}"
unzip -o "./${ZIP_FILE}"
mv ./${REPOSITORY_NAME}-${ZIP_FILE%%.*} ./docs # No ".zip" at the end
rm -f "./${ZIP_FILE}"

# If a tag triggered the deploy, we deploy to a folder having the tag name
# otherwise we are on master and we deploy into latest
set +u
if [ -n "${TRAVIS_TAG}" ]; then
    DEPLOY_DIR="./docs/${TRAVIS_TAG}"

    # Generate QRCode and overwrite the defaullt one
    npm install -g qrcode
    rm -f ./dist/images/qrcode.svg
    qrcode -t svg -o ./dist/images/qrcode.svg "${GH_PAGE_BASE_URL}/${TRAVIS_TAG}"
else
    DEPLOY_DIR="./docs"
fi
set -u

rm -rf "${DEPLOY_DIR}"
cp -r ./dist "${DEPLOY_DIR}"
