CIRCLE_WORKFLOW_ID=4ca8a629-569b-4f52-bd6c-118f5fd9101c
api_endpoint="api/v2/workflow/${CIRCLE_WORKFLOW_ID}/job"

can_i_run="true"

mkdir -p /tmp/swissknife

# This is a global variable used to get return value for get_workflow_start_time
job_status=""
job_number=""

get_job_status() {
  wf_url="https://circleci.com/$api_endpoint?circle-token=${CIRCLE_TOKEN}"
  curl -f -s $wf_url > /tmp/swissknife/wf_$CIRCLE_WORKFLOW_ID.json
  job_status=$(jq -r '.items[] | select(.name=="lint-and-misc") | .status' /tmp/swissknife/wf_$CIRCLE_WORKFLOW_ID.json)
  job_number=$(jq -r '.items[] | select(.name=="lint-and-misc") | .job_number' /tmp/swissknife/wf_$CIRCLE_WORKFLOW_ID.json)
}

current_wait_time=0

while true; do
  get_job_status
  if [[ "$job_status" == "success" || "$job_status" == "failed" || "$job_status" == "" ]]; then
    echo "Its finally my turn. $job_status exiting"
    exit 0
  else
    echo "Looks like the other guy ($job_number) is still running."
    echo "Going to sleep for 30"
    sleep 30
    current_wait_time=$(( current_wait_time + 30 ))
  fi

  if (( $current_wait_time > 1800 )); then
    if [[ "true" == "true" ]]; then
      echo "Proceeding with future steps";
      exit 0;
    else
      echo "Failing job by exiting forcefully";
      exit 1;
    fi
  fi
done