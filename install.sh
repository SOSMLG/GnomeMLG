#!/usr/bin/env bash
# Unattended GNOME MLG installer. Run as a normal user.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec bash "$SCRIPT_DIR/run.sh" --full "$@"
