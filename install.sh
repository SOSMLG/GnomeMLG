#!/usr/bin/env bash
# Unattended GNOME MLG installer. Run as a normal user.
# Runs every step (including optional groups) and verifies the end state.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

NO_VERIFY=0
ARGS=()
for arg in "$@"; do
    case "$arg" in
        --no-verify|--list|--help|-h|--verify) NO_VERIFY=1 ;;
    esac
    case "$arg" in
        --no-verify) ;;
        *) ARGS+=("$arg") ;;
    esac
done

if [ "${#ARGS[@]}" -gt 0 ]; then
    bash "$SCRIPT_DIR/scripts/lib/runner.sh" --full "${ARGS[@]}"
else
    bash "$SCRIPT_DIR/scripts/lib/runner.sh" --full
fi

if [ "$NO_VERIFY" -eq 0 ]; then
    bash "$SCRIPT_DIR/verify.sh"
fi
