
hash jq 2>/dev/null || { echo >&2 "jq is not installed.  Aborting."; exit 1; }

JOB_NUM=22762
FILE_NAME=NA
if [[ "$JOB_NUM" == "0" ]]; then
  JOB_NUM=$CIRCLE_PREVIOUS_BUILD_NUM;
fi

mkdir -p /tmp/swissknife/artifacts

SLUG="github/${CIRCLE_PROJECT_USERNAME}/${CIRCLE_PROJECT_REPONAME}"
API_ENDPOINT="project/$SLUG/$JOB_NUM/artifacts"

get_artifact() {
  ARTIFACTS_URL="https://circleci.com/api/v2/${API_ENDPOINT}?circle-token=${CIRCLE_TOKEN}"
  curl -f -s $ARTIFACTS_URL > /tmp/swissknife/artifacts.json
  REQUIRED_ARTIFACT_URL=$(jq -r '.items[] | select(.path| test("failedSpecs..json")) | .url' /tmp/swissknife/artifacts.json)

  cd /tmp/swissknife/artifacts
  if [[ "$FILE_NAME" == "NA" ]]; then
    curl -H "Circle-Token: $CIRCLE_TOKEN" --remote-name $REQUIRED_ARTIFACT_URL
  else
    curl -H "Circle-Token: $CIRCLE_TOKEN" -O $FILE_NAME $REQUIRED_ARTIFACT_URL
  fi
}

get_artifact
echo "Finished"