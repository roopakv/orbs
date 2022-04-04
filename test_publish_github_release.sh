#!/bin/bash

GITHUB_REPO="sleet"
GITHUB_USER="BoltApp"

set -ex
echo "Running test"
mkdir -p /tmp/swissknife/
wget -P /tmp/swissknife/ -q "https://github.com/github-release/github-release/releases/download/v0.7.2/darwin-amd64-github-release.tar.bz2"

echo "Unpacking file"
tar xjf /tmp/swissknife/*.tar.bz2 -C /tmp/swissknife
now=$(date +"%s")
echo "Now . " + $now
/tmp/swissknife/bin/darwin/amd64/github-release release \
  --security-token $GITHUB_TOKEN \
  --user "$GITHUB_USER" \
  --repo "$GITHUB_REPO" \
  --tag v1.0.1-$now
