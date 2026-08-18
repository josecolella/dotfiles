#!/usr/bin/env bash
INPUT=$(cat)
TEXT=$(echo "$INPUT" | jq -r '
  .tool_input |
  (.text // .message // .content // "") |
  if type == "string" then . else "" end
')
[[ -z "$TEXT" ]] && exit 0
if ! echo "$TEXT" | grep -qF ":claude: Jose's AI agent"; then
  jq -n '{"decision":"block","reason":"Missing Slack signature. Append :claude: Jose'\''s AI agent to the message."}'
fi
exit 0
