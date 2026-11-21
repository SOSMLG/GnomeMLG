#!/usr/bin/env bash
# Read-only end-state verifier for GNOME MLG.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/common.sh
source "$SCRIPT_DIR/scripts/lib/common.sh"

JSON=0
[ "${1:-}" = "--json" ] && JSON=1
STATUS=0
JSON_LINES=()

json_escape() {
    printf '%s' "$1" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g'
}

report() {
    local level="$1" name="$2" message="$3"
    if [ "$JSON" -eq 1 ]; then
        JSON_LINES+=("{\"check\":\"$(json_escape "$name")\",\"status\":\"$level\",\"message\":\"$(json_escape "$message")\"}")
    else
        printf '[%s] %s: %s\n' "$level" "$name" "$message"
    fi
    [ "$level" = FAIL ] && STATUS=1
    return 0
}

check_file() {
    local name="$1" path="$2"
    if [ -f "$path" ]; then
        report PASS "$name" "$path exists"
    else
        report FAIL "$name" "$path is missing"
    fi
}

check_file "repo-bash-config" "$SCRIPT_DIR/configs/bash/.bashrc"
check_file "repo-app-step" "$SCRIPT_DIR/configs/gnome/GnomeApps.sh"
check_file "theme-archive" "$SCRIPT_DIR/graphite-amber-theme.7z"

if grep -Fq 'export OSH="$HOME/.oh-my-bash"' "$SCRIPT_DIR/configs/bash/.bashrc" 2>/dev/null; then
    report PASS "portable-bashrc" "config uses \$HOME for OSH"
else
    report FAIL "portable-bashrc" "config still contains a hard-coded home path"
fi

if grep -Fq 'export OSH="$HOME/.oh-my-bash"' "$HOME/.bashrc" 2>/dev/null; then
    report PASS "deployed-bashrc" "$HOME/.bashrc has the portable OSH path"
else
    report WARN "deployed-bashrc" "$HOME/.bashrc does not have the portable OSH path yet"
fi

if [ -d "$HOME/.oh-my-bash" ]; then
    report PASS "oh-my-bash" "$HOME/.oh-my-bash exists"
else
    report WARN "oh-my-bash" "$HOME/.oh-my-bash is not installed"
fi

if [ -f "$GNOMEMLG_DATA_DIR/graphite-amber-theme.7z" ]; then
    report PASS "staged-theme" "theme archive is staged in $GNOMEMLG_DATA_DIR"
else
    report WARN "staged-theme" "theme archive is not staged yet"
fi

if command_exists dpkg && dpkg --print-foreign-architectures 2>/dev/null | grep -qx i386; then
    report PASS "i386-arch" "i386 architecture is enabled"
else
    report WARN "i386-arch" "i386 architecture is not enabled"
fi

if [ "$JSON" -eq 1 ]; then
    printf '{"results":[%s]}\n' "$(IFS=,; echo "${JSON_LINES[*]}")"
fi

exit "$STATUS"
