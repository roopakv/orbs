slug="github/org/repo"
branch_to_consider="master"

# Assume there is one workflow running.
total_workflows_running="1"
can_i_run="true"

CIRCLE_WORKFLOW_ID="some-id"

mkdir -p /tmp/swissknife

# This is a global variable used to get return value for get_workflow_start_time
workflow_start_time=""

get_workflow_start_time() {
  wf_url="https://circleci.com/api/v2/workflow/${1}?circle-token=${CIRCLE_TOKEN}"
  curl -f -s $wf_url > /tmp/swissknife/wf_${1}.json
  workflow_start_time=$(jq '.created_at' /tmp/swissknife/wf_${1}.json)
}

get_num_running_workflows() {
  running_jobs_url="https://circleci.com/api/v1.1/project/$slug/tree/$branch_to_consider?circle-token=${CIRCLE_TOKEN}&filter=running"
  curl -f -s $running_jobs_url > /tmp/swissknife/running_jobs.json
  total_workflows_running=$(jq --arg curworkflow "$CIRCLE_WORKFLOW_ID" '[unique_by(.workflows.workflow_id) | .[] | select(.workflows.workflow_name|test("staging-local-chrome")) | select(.workflows.workflow_id|test($curworkflow)|not) ] | length' /tmp/swissknife/running_jobs.json)
  # If no other workflows are running, we're good. just return
  if [ "$total_workflows_running" == "0" ]; then
    echo "no other workflows"
    return 0
  fi
  jq -r --arg curworkflow "$CIRCLE_WORKFLOW_ID" 'unique_by(.workflows.workflow_id) | .[] | select(.workflows.workflow_name|test("staging-local-chrome")) | select(.workflows.workflow_id|test($curworkflow)|not) | .workflows.workflow_id' /tmp/swissknife/running_jobs.json > /tmp/swissknife/running_workflows.txt

  get_workflow_start_time $CIRCLE_WORKFLOW_ID
  current_workflow_start_time=$workflow_start_time
  echo "I started at $current_workflow_start_time"

  can_i_run="true"
  while IFS= read -r line
  do
    get_workflow_start_time $line
    running_wf_start_time=$workflow_start_time
    if [[ $running_wf_start_time < $current_workflow_start_time ]] ; then
      echo "another workflow $line started at $running_wf_start_time which is before me"
      can_i_run="false"
      break
    fi
  done < /tmp/swissknife/running_workflows.txt
}

kill_workflow(){
  echo "Cancelleing workflow by cancelling build ${CIRCLE_BUILD_NUM}"
  cancel_workflow_url="https://circleci.com/api/v1.1/project/$slug/${CIRCLE_BUILD_NUM}/cancel?circle-token=${CIRCLE_TOKEN}"
  curl -s -X POST $cancel_workflow_url
  # Give CircleCI enough time to kill this workflow
  sleep 30
  # If the job wasnt canceled in 30 seconds fail.
  exit 1;
}

current_wait_time=0

while true; do
  get_num_running_workflows
  if [[ "$total_workflows_running" == "0" || "$can_i_run" == "true" ]]; then
    echo "Its finally my turn. exiting"
    exit 0
  else
    echo "Looks like $total_workflows_running are still running. and can_i_run:$can_i_run"
    echo "Going to sleep for 30"
    sleep 30
    current_wait_time=$(( current_wait_time + 30 ))
  fi

  if (( $current_wait_time > 600 )); then
    if [[ "false" == "true" ]]; then
      echo "Killing workflow by cancelling";
      kill_workflow
    else
      echo "Killing workflow by exiting forcefully";
      exit 1;
    fi
  fi
done