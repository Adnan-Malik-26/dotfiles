#!/usr/bin/env bash

TOKEN=$(cat ~/.config/github_token)

RESP=$(curl -s -H "Authorization: bearer $TOKEN" \
  -X POST \
  -d '{"query":"query { viewer { contributionsCollection { contributionCalendar { totalContributions } } } }"}' \
  https://api.github.com/graphql)

TOTAL=$(jq -r '.data.viewer.contributionsCollection.contributionCalendar.totalContributions // empty' <<<"$RESP")

if [[ -z "$TOTAL" || "$TOTAL" == "null" ]]; then
  echo '{"text":": error","tooltip":"Failed to fetch"}'
else
  echo "{\"text\":\" : $TOTAL\",\"tooltip\":\"$TOTAL contributions in the last year\"}"
fi
