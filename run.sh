#!/usr/bin/env bash
# GNOME MLG step runner. Run as a normal user from a checkout of this repo.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/common.sh
source "$SCRIPT_DIR/scripts/lib/common.sh"

ASSUME_YES=0
FULL=0
VERIFY_ONLY=0
ONLY=""
STEPS="bash apps theme"

usage() {
    cat <<'EOF'
Usage: ./run.sh [options]

Options:
  --list              list steps and exit
  --yes               accept defaults without prompting
  --full              run every step with yes assumed
  --only bash,apps    run only the named steps
  --no-update         skip apt-get update in the apps step
  --verify            run the end-state verifier only
  -h, --help          show this help
EOF
}

ask() {
    local prompt="$1" answer
    [ "$ASSUME_YES" -eq 1 ] && return 0
    printf '%s [Y/n] ' "$prompt"
    IFS= read -r answer || answer=""
    case "$answer" in
        n|N|no|NO) return 1 ;;
        *) return 0 ;;
    esac
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        --list) printf '%s\n' $STEPS; exit 0 ;;
        --yes|-y) ASSUME_YES=1 ;;
        --full) FULL=1; ASSUME_YES=1 ;;
        --only) ONLY="${2:-}"; shift ;;
        --no-update) export GNOMEMLG_SKIP_APT_UPDATE=1 ;;
        --verify) VERIFY_ONLY=1 ;;
        -h|--help) usage; exit 0 ;;
        *) log_err "unknown option: $1"; usage >&2; exit 2 ;;
    esac
    shift
done

if [ "$(id -u)" -eq 0 ]; then
    log_err "run as a normal user, not root"
    exit 1
fi

if [ "$VERIFY_ONLY" -eq 1 ]; then
    exec bash "$SCRIPT_DIR/verify.sh"
fi

selected="$STEPS"
if [ -n "$ONLY" ]; then
    selected="$(printf '%s\n' "$ONLY" | tr ',' ' ')"
fi

run_bash() {
    local src="$SCRIPT_DIR/configs/bash/.bashrc"
    [ -f "$src" ] || { log_err "missing $src"; return 1; }
    ask "Deploy the portable bash config to ~/.bashrc?" || return 0
    install_file "$src" "$HOME/.bashrc"
}

run_apps() {
    local src="$SCRIPT_DIR/configs/gnome/GnomeApps.sh"
    [ -f "$src" ] || { log_err "missing $src"; return 1; }
    ask "Install the GNOME app prerequisites?" || return 0
    bash "$src"
}

run_theme() {
    local archive="$SCRIPT_DIR/graphite-amber-theme.7z"
    [ -f "$archive" ] || { log_err "missing $archive"; return 1; }
    ask "Stage and apply the bundled graphite-amber-theme.7z?" || return 0
    mkdir -p "$GNOMEMLG_DATA_DIR"
    cp "$archive" "$GNOMEMLG_DATA_DIR/graphite-amber-theme.7z"
    log_ok "staged theme archive in $GNOMEMLG_DATA_DIR"
    if ! command_exists 7z; then
        log_warn "7z not installed; extract $GNOMEMLG_DATA_DIR/graphite-amber-theme.7z manually"
        return 0
    fi
    if [ -d "$HOME/.themes" ]; then
        local bak="$HOME/.themes.bak.$(date +%Y%m%d-%H%M%S)"
        mv "$HOME/.themes" "$bak"
        log_info "backed up $HOME/.themes to $bak"
    fi
    mkdir -p "$HOME/.themes"
    7z x -y -o"$HOME/.themes" "$archive" >/dev/null
    log_ok "extracted theme archive to $HOME/.themes"
}

run_step() {
    case "$1" in
        bash) run_bash ;;
        apps) run_apps ;;
        theme) run_theme ;;
        *) log_err "unknown step: $1"; return 2 ;;
    esac
}

for step in $selected; do
    log_info "step: $step"
    run_step "$step"
done

if [ "$FULL" -eq 1 ]; then
    bash "$SCRIPT_DIR/verify.sh"
fi
