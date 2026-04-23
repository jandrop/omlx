#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

ORIGINAL_DIR="$(pwd)"

echo "Starting oMLX server..."
(cd "$PROJECT_DIR" && uv run python -m omlx.cli serve \
  --base-path ~/.omlx \
  --port 8000 > ~/.omlx/server.log 2>&1) &

SERVER_PID=$!
echo "Server PID: $SERVER_PID"

echo "Waiting for server to be ready..."
until curl -s http://127.0.0.1:8000/health > /dev/null 2>&1; do
  sleep 1
done

echo "Server ready. Launching opencode..."
cd "$ORIGINAL_DIR"
opencode

# When opencode exits, stop the server
kill $SERVER_PID 2>/dev/null
echo "Server stopped."
