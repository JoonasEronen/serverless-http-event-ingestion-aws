#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

if [ ! -d "app" ]; then
  echo "Error: infra/app directory not found"
  exit 1
fi

rm -f build/lambda.zip
mkdir -p build
(cd app && zip -rq ../build/lambda.zip .)

echo "Built infra/build/lambda.zip"
