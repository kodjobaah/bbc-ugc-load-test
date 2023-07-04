#!/usr/bin/env bash

env=$1
cnd="aws s3 sync s3://afriex-marketplace-media-staging s3://afriex-marketplace-media-dev  --profile afriex --region eu-west-3"
eval $cnd
