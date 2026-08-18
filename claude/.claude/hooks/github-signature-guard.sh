#!/usr/bin/env bash
# PreToolUse: require the "🤖 Jose's AI agent" footer on anything posted to GitHub.
#
# Two input shapes are handled. A GitHub MCP tool puts prose in .tool_input.body;
# the Bash tool puts the whole `gh` invocation in .tool_input.command, where the
# body is usually inline in a heredoc — so the signature is checked against the
# entire command string rather than by parsing --body out of it. When the body lives
# on disk (--body-file / -F / -f / @file) the referenced file is appended before the
# check; a path this hook cannot open is reported as such, not as a missing footer.
set -uo pipefail

SIG="🤖 Jose's AI agent"
INPUT=$(cat)

block() {
  jq -n --arg r "$1" '{"decision": "block", "reason": $r}'
  exit 0
}

BODY=$(printf '%s' "$INPUT" | jq -r '
  .tool_input |
  (.body // .message // .text // .comment // "") |
  if type == "string" then . else "" end
')

if [[ -n "$BODY" ]]; then
  printf '%s' "$BODY" | grep -qF "$SIG" ||
    block "Missing GitHub signature. Append *🤖 Jose's AI agent* to the body/message."
  exit 0
fi

CMD=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty')
[[ -z "$CMD" ]] && exit 0

# Prose that *quotes* a gh invocation in backticks -- a commit message, or a comment in a
# script that edits this hook -- is not itself posting anything. Detection therefore runs
# against the command with backticked spans stripped, while the signature check below
# still sees the whole thing. Legacy backtick command substitution is the deliberate
# trade-off: it is rare next to how often the quoted form shows up in prose, and the
# $(...) form is unaffected.
CMD_CODE=$(printf '%s' "$CMD" | sed 's/`[^`]*`//g')

# Only gh subcommands that publish prose, and only when a body is actually supplied
# (so `gh pr edit --add-label` and a bare `gh pr review --approve` stay unaffected).
posts_prose() {
  printf '%s' "$CMD_CODE" | grep -qE '(^|[^[:alnum:]_-])gh[[:space:]]+(pr|issue)[[:space:]]+(create|comment|review|edit)' && return 0
  printf '%s' "$CMD_CODE" | grep -qE '(^|[^[:alnum:]_-])gh[[:space:]]+release[[:space:]]+(create|edit)' && return 0
  printf '%s' "$CMD_CODE" | grep -qE '(^|[^[:alnum:]_-])gh[[:space:]]+api' &&
    printf '%s' "$CMD_CODE" | grep -qE '(^|[^[:alnum:]_-])(body|comments)=' && return 0
  return 1
}

has_body() {
  printf '%s' "$CMD_CODE" | grep -qE -- '(--body([[:space:]]|=)|--body-file([[:space:]]|=)|-b[[:space:]]|-F[[:space:]]|-f[[:space:]]|--field|--raw-field|body=)'
}

posts_prose || exit 0
has_body || exit 0

TEXT="$CMD"
UNREADABLE=""
READ_ANY=""
# --body-file PATH, its -F/-f shorthand, and -F body=@PATH all put the prose on disk,
# outside the command string. Candidates containing "=" are gh api field specs
# (-F body=@file); the real path is the part after the @.
while IFS= read -r p; do
  [[ -z "$p" ]] && continue
  # -F body=@PATH arrives as one token because the -F branch consumes it whole;
  # the real path is whatever follows the last @.
  [[ "$p" == *@* ]] && p="${p##*@}"
  # a remaining "=" means a field spec with no file (body=text, body=@-): nothing to read.
  [[ "$p" == *=* || "$p" == "-" ]] && continue
  # prose that merely mentions these flags yields junk tokens; keep only plausible paths
  p="${p%%[\`,;:)]*}"
  [[ "$p" == */* && ${#p} -gt 1 && "$p" != *[\<\>]* ]] || continue
  if [[ -f "$p" ]]; then
    TEXT+=$(cat "$p")
    READ_ANY=1
  else
    UNREADABLE+="$p "
  fi
done < <(printf '%s' "$CMD_CODE" |
  grep -oE -- '(--body-file[= ]|-F[[:space:]]+|-f[[:space:]]+|@)[^[:space:]"'"'"']+' |
  sed -E 's/^(--body-file[= ]|-F[[:space:]]+|-f[[:space:]]+|@)//')

printf '%s' "$TEXT" | grep -qF "$SIG" && exit 0

# A body file we could not open is not evidence of a missing footer — name it, rather
# than reporting a signature failure the author cannot act on. The usual cause is an
# unexpanded shell variable in the path, since this hook sees the raw command string.
if [[ -n "$UNREADABLE" && -z "$READ_ANY" ]]; then
  shown=$(printf '%s' "${UNREADABLE% }" | tr ' ' '\n' | head -3 | paste -sd' ' -)
  block "Could not read body file(s): $shown. This hook sees the raw command string, so a shell variable in the path cannot be resolved — re-run with a literal absolute path so the *🤖 Jose's AI agent* footer can be verified."
fi

block "Missing GitHub signature. This gh command posts to GitHub without the required footer — append *🤖 Jose's AI agent* to the body."
exit 0
