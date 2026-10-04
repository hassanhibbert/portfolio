#!/usr/bin/env bash
# Builds the site and rsyncs dist/ to DreamHost over SSH.
#
# Connection details come from environment variables only:
#   DEPLOY_USER, DEPLOY_HOST, DEPLOY_PATH
# They can be exported in your shell (or set in CI), or put in
# .env.deploy.local (gitignored). Variables already set in the environment
# win over the file. Values are never printed.
#
# Usage: yarn deploy [--dry-run]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ENV_FILE="$PROJECT_ROOT/.env.deploy.local"

DRY_RUN=false
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    *)
      echo "Unknown option: $arg (usage: yarn deploy [--dry-run])" >&2
      exit 1
      ;;
  esac
done

# Load KEY=VALUE lines from the env file without overriding anything already
# set. Parsed line by line instead of `source`, so the file can't run code.
if [ -f "$ENV_FILE" ]; then
  while IFS='=' read -r key value || [ -n "$key" ]; do
    key="${key//[[:space:]]/}"
    [[ -z "$key" || "$key" == \#* ]] && continue
    [[ "$key" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]] || continue
    if [ -z "${!key+x}" ]; then
      value="${value%\"}"; value="${value#\"}"
      value="${value%\'}"; value="${value#\'}"
      export "$key=$value"
    fi
  done < "$ENV_FILE"
fi

missing=()
for var in DEPLOY_USER DEPLOY_HOST DEPLOY_PATH; do
  [ -n "${!var:-}" ] || missing+=("$var")
done
if [ ${#missing[@]} -gt 0 ]; then
  echo "Missing: ${missing[*]}" >&2
  echo "Export them, or copy .env.deploy.local.example to .env.deploy.local and fill it in." >&2
  exit 1
fi

# --delete mirrors dist/ exactly, so refuse paths that clearly aren't a
# site folder (filesystem root or a home directory).
if [[ "$DEPLOY_PATH" =~ ^(/|~|/home/[^/]+|~/)/?$ ]]; then
  echo "DEPLOY_PATH must be the site's own folder, not / or a home directory." >&2
  exit 1
fi

echo "Building..."
(cd "$PROJECT_ROOT" && yarn build)

# Paths in DEPLOY_PATH that aren't part of this site but must stay on the
# server. rsync --delete never removes excluded paths. A leading "/" anchors
# the pattern to the top of DEPLOY_PATH.
KEEP_ON_SERVER=(
  /.well-known   # DreamHost / SSL certificate files
  /.htaccess     # server config and redirects
  /trainer
  /calc-tip
  /gas-tank
)

RSYNC_FLAGS=(-avz --delete)
for keep in "${KEEP_ON_SERVER[@]}"; do
  RSYNC_FLAGS+=(--exclude "$keep")
done
if [ "$DRY_RUN" = true ]; then
  RSYNC_FLAGS+=(--dry-run --itemize-changes)
  echo "Dry run: nothing will be uploaded or deleted. Lines starting with '*deleting' would be removed."
fi

# rsync and ssh echo the user, host and path in their own messages (e.g.
# "user@host: Permission denied"). Mask them so values never reach the terminal.
# Literal string replacement, so dots and slashes in the values are safe.
redact() {
  local line
  while IFS= read -r line || [ -n "$line" ]; do
    line="${line//"$DEPLOY_PATH"/DEPLOY_PATH}"
    line="${line//"$DEPLOY_HOST"/DEPLOY_HOST}"
    line="${line//"$DEPLOY_USER"/DEPLOY_USER}"
    printf '%s\n' "$line"
  done
}

# BatchMode makes SSH fail instead of prompting for a password: key auth only.
echo "Uploading dist/ to DEPLOY_HOST:DEPLOY_PATH ..."
rsync "${RSYNC_FLAGS[@]}" \
  -e "ssh -o BatchMode=yes" \
  "$PROJECT_ROOT/dist/" \
  "$DEPLOY_USER@$DEPLOY_HOST:$DEPLOY_PATH/" 2>&1 | redact

if [ "$DRY_RUN" = true ]; then
  echo "Dry run complete."
else
  echo "Deploy complete."
fi
