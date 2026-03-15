#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# ── Options ──────────────────────────────────────────────────────────────────
REMOVE_VOLUMES=false
REMOVE_NETWORKS=false

usage() {
  echo "Usage: $0 [--volumes] [--networks]"
  echo ""
  echo "  --volumes    Also remove Docker volumes"
  echo "  --networks   Also remove Docker networks"
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --volumes)  REMOVE_VOLUMES=true  ;;
    --networks) REMOVE_NETWORKS=true ;;
    -h|--help)  usage ;;
    *) echo "Unknown option: $1"; usage ;;
  esac
  shift
done

# ── Resolve env file from git branch ─────────────────────────────────────────
cd "$PROJECT_DIR"

BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")"

if [[ "$BRANCH" == "main" ]]; then
  ENV_SOURCE=".env.prod"
elif [[ "$BRANCH" == "dev" ]]; then
  ENV_SOURCE=".env.dev"
else
  echo "ERROR: Current git branch is '$BRANCH'. Expected 'main' or 'dev'." >&2
  exit 1
fi

if [[ ! -f "$ENV_SOURCE" ]]; then
  echo "ERROR: Env file '$ENV_SOURCE' not found." >&2
  exit 1
fi

echo "Branch: $BRANCH → using $ENV_SOURCE"

# ── Tear down ────────────────────────────────────────────────────────────────
DOWN_FLAGS=""
$REMOVE_VOLUMES  && DOWN_FLAGS="$DOWN_FLAGS --volumes"
$REMOVE_NETWORKS && DOWN_FLAGS="$DOWN_FLAGS --remove-orphans"

echo "Stopping and removing containers..."
# shellcheck disable=SC2086
docker compose down $DOWN_FLAGS

if $REMOVE_NETWORKS; then
  echo "Removing project networks..."
  docker network prune -f --filter "label=com.docker.compose.project=$(basename "$PROJECT_DIR")" 2>/dev/null || true
fi

# ── Swap .env ────────────────────────────────────────────────────────────────
echo "Removing .env and copying from $ENV_SOURCE..."
rm -f .env
cp "$ENV_SOURCE" .env

# ── Start ────────────────────────────────────────────────────────────────────
echo "Starting services..."
docker compose up -d

echo "Done."
