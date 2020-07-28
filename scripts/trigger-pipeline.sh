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

cat \<\<EOF > /tmp/swissknife/trigger_pipeline.sh
  #!/bin/bash -x
  echo "----------------------------------------"
  echo "Triggering Pipeline"

  export vcs_type="$1";
  export username="$2";
  export reponame="$3";
  export branch="$4";
  export params="$5";
  echo "params is"
  echo $params

  trigger_workflow() {
    curl --silent -X POST \
      "https://circleci.com/api/v2/project/$vcs_type/$username/$reponame/pipeline?circle-token=${CIRCLE_TOKEN}" \
      -H 'Accept: */*' \
      -H 'Content-Type: application/json' \
      -d '{
        "branch": "'$branch'",
        "parameters": '$params'
      }'
  }

  trigger_workflow

  echo "Finished triggering pipeline"
  echo "----------------------------------------"
EOF

chmod +x /tmp/swissknife/trigger_pipeline.sh

if [[ "<< parameters.install-skip-trigger >>" == "false" ]]; then
  /tmp/swissknife/trigger_pipeline.sh << parameters.vcs-type >> $<< parameters.user >> $<< parameters.repo-name >> $<< parameters.branch >> '<< parameters.custom-parameters >>'
fi