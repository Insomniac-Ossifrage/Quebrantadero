#!/usr/bin/env bash
set -euo pipefail

#=== Validate Required Tools ===#
command -v curl >/dev/null 2>&1 || { echo "curl is required"; exit 1; }
command -v jq   >/dev/null 2>&1 || { echo "jq is required"; exit 1; }

#=== Validate Required Environment Variables ===#
: "${REPO:?Environment variable REPO must be set (e.g. owner/repo)}"
: "${TOKEN:?Environment variable TOKEN must be set}"

REPOSITORY="${REPO}"
ACCESS_TOKEN="${TOKEN}"

echo "Repository: ${REPOSITORY}"
echo "Token: ${ACCESS_TOKEN:0:4}**** (masked)"

#=== Obtain Runner Registration Token ===#
api_url="https://api.github.com/repos/${REPOSITORY}/actions/runners/registration-token"

echo "Requesting registration token..."
response="$(curl -sSL -w "%{http_code}" \
  -X POST \
  -H "Authorization: token ${ACCESS_TOKEN}" \
  -H "Accept: application/vnd.github+json" \
  "${api_url}"
)"

# Separate body and status code
http_status="${response: -3}"
response_body="${response::-3}"

if [[ "$http_status" != "201" ]]; then
  echo "Failed to obtain registration token: HTTP ${http_status}"
  echo "Response: ${response_body}"
  exit 1
fi

REG_TOKEN="$(echo "$response_body" | jq -r '.token')"

if [[ -z "$REG_TOKEN" || "$REG_TOKEN" == "null" ]]; then
  echo "Registration token not found in response"
  exit 1
fi

cd /home/docker/actions-runner

#=== Cleanup function ===#
cleanup() {
  echo "Removing runner..."
  ./config.sh remove --unattended --token "${REG_TOKEN}" || true
}

# Trap interrupt/terminate signals and script exit
trap cleanup INT TERM EXIT

#=== Configure and Run Runner ===#
./config.sh \
  --url "https://github.com/${REPOSITORY}" \
  --token "${REG_TOKEN}"

echo "Runner registered. Starting..."
./run.sh &
wait $!
 
