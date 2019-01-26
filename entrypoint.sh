#!/bin/sh
export RESTIC_REPOSITORY=${RESTIC_REPOSITORY-/data}
if [ -z "$RESTIC_PASSWORD" ] && [ -z "$RESTIC_PASSWORD_FILE" ]; then
  echo "Please set either RESTIC_PASSWORD or RESTIC_PASSWORD_FILE"
  exit 1
fi

set -e
if [ -n "$RESTIC_REPOSITORY" ] && ! restic snapshots; then
    echo "Restic repository '${RESTIC_REPOSITORY}' does not exists. Running restic init."
    restic init
fi

exec "$@"