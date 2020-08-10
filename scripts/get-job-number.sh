if [ -z "$BASH" ]; then
  echo Bash not installed.
  exit 1
fi
hash jq 2>/dev/null || { echo >&2 "jq is not installed.  Aborting."; exit 1; }
if [[ "$CIRCLE_TOKEN" == "" ]]; then
  echo "CIRCLE_TOKEN not set. Set a token to access the circle API in the env var CIRCLE_TOKEN";
  exit 1;
fi

mkdir -p /tmp/swissknife

FINAL_WORKFLOW_ID="$CIRCLE_WORKFLOW_ID"
if [[ "$WORKFLOW_ID" != "this" ]]; then
  FINAL_WORKFLOW_ID="$WORKFLOW_ID"
fi

JOB_NUM=""

get_job_in_workflow() {
  JOBS_IN_WORKFLOW_ENDPOINT="https://circleci.com/api/v2/workflow/${FINAL_WORKFLOW_ID}/job?circle-token=${CIRCLE_TOKEN}"
  curl -f -s $JOBS_IN_WORKFLOW_ENDPOINT > /tmp/swissknife/current_wf_jobs.json
  JOB_NUM=$(jq -r --arg curjobname "$JOB_NAME" '.items[] | select(.name | test("^" + $curjobname + "$")).job_number' /tmp/swissknife/current_wf_jobs.json)
}

get_job_in_workflow

if [[ "$JOB_NUM" == "" ]]; then
  echo "Job not found";
  exit 1;
fi

echo "Found job $JOB_NAME the number id $JOB_NUM";

echo "This job is a rerun of $PREVIOUS_JOB, adding this to the bash env."

echo "export SK_JOB_NUM=$JOB_NUM" >> $BASH_ENV
