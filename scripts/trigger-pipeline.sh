if [ -z "$BASH" ]; then
  echo Bash not installed.
  exit 1
fi
git status >/dev/null 2>&1 || { echo >&2 "Not in a git directory or no git"; exit 1; }
circleci-agent >/dev/null 2>&1 || { echo >&2 "No Circle CI agent. These are in all Circle CI containers"; exit 1; }
if [[ "$CIRCLE_TOKEN" == "" ]]; then
  echo "CIRCLE_TOKEN not set. Set a token to access the circle API in the env var CIRCLE_TOKEN";
  exit 1;
fi

mkdir -p /tmp/swissknife/

cat > /tmp/swissknife/trigger_pipeline.sh <<'EOF'
  #!/bin/bash -x
  echo "----------------------------------------"
  echo "Triggering Pipeline"

  export vcs_type="$1";
  export username="$2";
  export reponame="$3";
  if [[ $4 == "-t" ]]; then
    export tag="$5";
    export params="$6";
    export body='{
      "tag": "'$tag'",
      "parameters": '"$params"'
    }';
  else
    export branch="$4";
    export params="$5";
    export body='{
      "branch": "'$branch'",
      "parameters": '"$params"'
    }';
  fi

  trigger_workflow() {
    curl --silent -X POST \
      "https://circleci.com/api/v2/project/$vcs_type/$username/$reponame/pipeline?circle-token=${CIRCLE_TOKEN}" \
      -H 'Accept: */*' \
      -H 'Content-Type: application/json' \
      -d "${body}"
  }

  trigger_workflow

  echo "Finished triggering pipeline"
  echo "----------------------------------------"
EOF

chmod +x /tmp/swissknife/trigger_pipeline.sh

PARAM_USER=$(printf '%s\n' "${!PARAM_USER_ENV_VAR}")
PARAM_REPO=$(printf '%s\n' "${!PARAM_REPO_ENV_VAR}")
PARAM_BRANCH=$(printf '%s\n' "${!PARAM_BRANCH_ENV_VAR}")
PARAM_TAG=$(printf '%s\n' "${!PARAM_TAG_ENV_VAR}")

if [[ "$SKIP_TRIGGER" == "0" || "$SKIP_TRIGGER" == "false" ]]; then
  if [[ "$PARAM_TAG" == "" ]]; then
    /tmp/swissknife/trigger_pipeline.sh "$VCS_TYPE" "$PARAM_USER" "$PARAM_REPO" "$PARAM_BRANCH" "$CUSTOM_PARAMS"
  else
    /tmp/swissknife/trigger_pipeline.sh "$VCS_TYPE" "$PARAM_USER" "$PARAM_REPO" -t "$PARAM_TAG" "$CUSTOM_PARAMS"
  fi
fi
