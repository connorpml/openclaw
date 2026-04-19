#!/usr/bin/env bash
# Copy freshly built BorgPrime wheels into this directory so `docker compose build`
# can consume them. Run BorgPrime/build.sh over in the BorgPrime repo first.
set -euo pipefail

# --- CONFIG ---------------------------------------------------------------
# Path to your local BorgPrime checkout's dist/ directory (where build.sh
# drops wheels). Override at invocation time with:
#   BORGPRIME_DIST=/path/to/BorgPrime/dist ./sync-wheels.sh
BORGPRIME_DIST_DEFAULT="/c/Users/conno/Desktop/BorgPrime/dist"
# --------------------------------------------------------------------------

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="${BORGPRIME_DIST:-$BORGPRIME_DIST_DEFAULT}"

if ! compgen -G "$SRC/*.whl" >/dev/null; then
  echo "error: no wheels in $SRC. run BorgPrime/build.sh first." >&2
  echo "       (edit BORGPRIME_DIST_DEFAULT in this script, or set \$BORGPRIME_DIST)" >&2
  exit 1
fi

rm -f "$HERE/wheels"/*.whl
mkdir -p "$HERE/wheels"
cp "$SRC"/*.whl "$HERE/wheels/"
echo "synced from $SRC:"
ls -1 "$HERE/wheels"/*.whl
