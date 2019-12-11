
while true; do
        mkdir -p /tmp/swissknife/
        wget -P /tmp/swissknife/ -qi - https://github.com/aktau/github-release/releases/download/v0.7.2/darwin-amd64-github-release.tar.bz2

        tar xjf /tmp/swissknife/*.tar.bz2 -C /tmp/swissknife
        now=$(date +"%T")
        /tmp/swissknife/bin/linux/amd64/github-release release \
          --security-token $GITHUB_TOKEN \
          --user "BoltApp" \
          --repo "sleet" \
          --tag v1.0.0-$now
done
