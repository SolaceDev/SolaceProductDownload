#!/bin/bash

export SOLACE_PRODUCT_DOWNLOAD_NAME=${SOLACE_PRODUCT_DOWNLOAD_NAME:-solace-product-download}
export SOLACE_PRODUCT_DOWNLOAD_ORG=${SOLACE_PRODUCT_DOWNLOAD_ORG:-solace}
export SOLACE_PRODUCT_DOWNLOAD_DOCKER_NAME="$SOLACE_PRODUCT_DOWNLOAD_ORG/$SOLACE_PRODUCT_DOWNLOAD_NAME"
export SOLACE_PRODUCT_DOWNLOAD_DOCKER_TARGET="$SOLACE_PRODUCT_DOWNLOAD_NAME"

export DOCKER_USERNAME=${DOCKER_USERNAME:-}
export DOCKER_PASSWORD=${DOCKER_PASSWORD:-}
export DOCKER_REGISTRY=${DOCKER_REGISTRY:-}

echo "Building $SOLACE_PRODUCT_DOWNLOAD_DOCKER_NAME"

sudo docker build . -t "$SOLACE_PRODUCT_DOWNLOAD_DOCKER_NAME"

if [ ! -z $DOCKER_REGISTRY ]; then
  echo "Using docker registry $DOCKER_REGISTRY"
  export SOLACE_PRODUCT_DOWNLOAD_DOCKER_TARGET="$DOCKER_REGISTRY/$SOLACE_PRODUCT_DOWNLOAD_NAME"
  echo "Tagging $SOLACE_PRODUCT_DOWNLOAD_DOCKER_NAME with $SOLACE_PRODUCT_DOWNLOAD_DOCKER_TARGET"
  sudo docker tag $SOLACE_PRODUCT_DOWNLOAD_DOCKER_NAME $SOLACE_PRODUCT_DOWNLOAD_DOCKER_TARGET
fi

if [ ! -z $DOCKER_USERNAME ] && [ ! -z $DOCKER_PASSWORD ]; then
  echo "Logging into docker as $DOCKER_USERNAME"
  sudo docker login -u "$DOCKER_USERNAME" -p "$DOCKER_PASSWORD"
fi

echo "Pushing $SOLACE_PRODUCT_DOWNLOAD_DOCKER_TARGET to $DOCKER_REGISTRY"
sudo docker push "$SOLACE_PRODUCT_DOWNLOAD_DOCKER_TARGET"

