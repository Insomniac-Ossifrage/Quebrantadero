#!/bin/bash

# Function to display usage
usage() {
  echo "Usage: $0 --token ACCESS_TOKEN --url REPOSITORY_URL --count RUNNER_COUNT --cores CORES_PER_RUNNER --tag IMAGE_TAG --runner-group RUNNER_GROUP"
  echo
  echo "Options:"
  echo "  --token         GitHub Personal Access Token"
  echo "  --url           GitHub Organization URL (e.g., https://github.com/org-name)"
  echo "  --count         Number of runners to launch"
  echo "  --cores         Number of CPU cores per runner"
  echo "  --tag           Docker image tag for the runner (e.g., 2.308.0, or use latest explicitly)"
  echo "  --runner-group  Runner group to assign the runner to"
  echo
  exit 1
}


# Function to validate required arguments
validate_argument() {
  local arg_value="$1"
  local arg_name="$2"
  if [[ -z "$arg_value" ]]; then
    echo "Error: Missing value for $arg_name."
    usage
  fi
}


# Function to validate integer arguments
validate_integer() {
  local arg_value="$1"
  local arg_name="$2"
  if [[ -z "$arg_value" || ! "$arg_value" =~ ^[0-9]+$ || "$arg_value" -le 0 ]]; then
    echo "Error: $arg_name must be a positive integer."
    usage
  fi
}


# Function to parse command line arguments
parse_arguments() {
  while [[ "$#" -gt 0 ]]; do
    case $1 in
      --tag)          export IMAGE_TAG="$2";        validate_argument "$IMAGE_TAG" "--tag"; shift ;;
      --token)        export ACCESS_TOKEN="$2";     validate_argument "$ACCESS_TOKEN" "--token"; shift ;;
      --url)          export REPOSITORY_URL="$2";   validate_argument "$REPOSITORY_URL" "--url"; shift ;;
      --count)        export RUNNER_COUNT="$2";     validate_integer "$RUNNER_COUNT" "--count"; shift ;;
      --cores)        export CORES_PER_RUNNER="$2"; validate_integer "$CORES_PER_RUNNER" "--cores"; shift ;;
      --runner-group) export RUNNER_GROUP="$2";     validate_argument "$RUNNER_GROUP" "--runner-group"; shift ;;
      *) echo "Unknown option: $1"; usage ;;
    esac
    shift
  done
}


# Function to validate CPU core allocation
validate_cores() {
  local TOTAL_CORES=$(nproc)
  local REQUIRED_CORES=$((RUNNER_COUNT * CORES_PER_RUNNER))
  if [ "$REQUIRED_CORES" -gt "$TOTAL_CORES" ]; then
    echo "Error: Not enough CPU cores available. Requested $REQUIRED_CORES, but only $TOTAL_CORES cores are available."
    exit 1
  fi
}


# Function to launch runners
launch_runners() {
  for (( i=1; i<=RUNNER_COUNT; i++ )); do
    export RUNNER_NAME="github-runner-${HOSTNAME}-${i}"
    echo "Launching runner: $RUNNER_NAME with $CORES_PER_RUNNER CPUs using image tag $IMAGE_TAG..."
    docker compose up -d
  done

  echo "All runners have been launched successfully."
}


# Main script execution
main() {
  parse_arguments "$@"
  validate_cores
  launch_runners
}

# Entry point
main "$@"
