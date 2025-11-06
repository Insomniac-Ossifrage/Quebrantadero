#!/bin/bash
set -e

# Function to fetch organization name and registration token
fetch_registration_token() {
  local GH_ORG_NAME=$(echo "$GH_REPOSITORY_URL" | awk -F'/' '{print $NF}')
  if [ -z "$GH_ORG_NAME" ]; then
    echo "Error: Unable to extract organization name from URL."
    exit 1
  fi

  local REGISTRATION_URL="https://api.github.com/orgs/$GH_ORG_NAME/actions/runners/registration-token"
  GH_REGISTRATION_TOKEN=$(curl -s -X POST -H "Authorization: Bearer $GH_ACCESS_TOKEN" \
                            -H "Accept: application/vnd.github.v3+json" \
                            "$REGISTRATION_URL" | jq -r '.token')

  if [ -z "$GH_REGISTRATION_TOKEN" ] || [ "$GH_REGISTRATION_TOKEN" == "null" ]; then
    echo "Error: Failed to obtain a registration token for organization $GH_ORG_NAME."
    exit 1
  fi
}

# Function to validate environment variables
validate_env_vars() {
  if [ -z "$GH_ACCESS_TOKEN" ]; then
    echo "Error: Missing GH_ACCESS_TOKEN environment variable."
    exit 1
  fi

  if [ -z "$GH_REPOSITORY_URL" ]; then
    echo "Error: Missing GH_REPOSITORY_URL environment variable."
    exit 1
  fi

  if [ -z "$GH_RUNNER_GROUP" ]; then
    echo "Error: Missing GH_RUNNER_GROUP environment variable."
    exit 1
  fi

  if [ -z "$GH_RUNNER_PREFIX" ]; then
    echo "Error: Missing GH_RUNNER_PREFIX environment variable."
    exit 1
  fi
}

# Function to configure the runner
configure_runner() {
  echo "Configuring the runner..."
  ./config.sh \
    --url "$GH_REPOSITORY_URL" \
    --token "$GH_REGISTRATION_TOKEN" \
    --name "$GH_RUNNER_NAME" \
    --runner-group "$GH_RUNNER_GROUP" \
    --unattended --ephemeral --replace
  echo "Runner configured."
}

# Function to clean up the runner
cleanup_runner() {
  echo "Removing runner..."
  ./config.sh remove --token "${GH_REGISTRATION_TOKEN}" || echo "Runner was already removed."
  echo "Runner removed."
}

# Function to start the runner
start_runner() {
  echo "Starting the runner..."
  ./run.sh &
  wait $!
}

# Main function
main() {

  GH_RUNNER_NAME="${GH_RUNNER_PREFIX}-${HOSTNAME}"

  validate_env_vars
  fetch_registration_token
  configure_runner

  # Trap SIGTERM and SIGINT to execute cleanup
  trap 'cleanup_runner; exit 130' INT
  trap 'cleanup_runner; exit 143' TERM

  start_runner
}

# Entry point
main "$@"