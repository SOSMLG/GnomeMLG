#!/usr/bin/env bash
# Shared helpers for the GNOME MLG runner.
# Sourced by install.sh and verify.sh. No side effects on source.

GNOMEMLG_STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/gnome-mlg"
GNOMEMLG_DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/gnome-mlg"

log_info() { printf '[gnome-mlg] %s\n' "$*"; }
log_ok()   { printf '[gnome-mlg] OK: %s\n' "$*"; }
log_warn() { printf '[gnome-mlg] WARN: %s\n' "$*" >&2; }
log_err()  { printf '[gnome-mlg] FAIL: %s\n' "$*" >&2; }

command_exists() { command -v "$1" >/dev/null 2>&1; }

# Privilege escalation: explicit override, then sudo, then doas.
priv() {
    if [ -n "${GNOMEMLG_PRIV:-}" ]; then
        command_exists "$GNOMEMLG_PRIV" || {
            log_err "GNOMEMLG_PRIV=$GNOMEMLG_PRIV is not installed"
            return 1
        }
        "$GNOMEMLG_PRIV" "$@"
        return
    fi
    if command_exists sudo; then
        sudo "$@"
    elif command_exists doas; then
        doas "$@"
    else
        log_err "no privilege helper found (sudo or doas)"
        return 1
    fi
}

# Copy a file into place, keeping a timestamped backup of any existing target.
install_file() {
    local src="$1" dst="$2"
    mkdir -p "$(dirname "$dst")"
    if [ -e "$dst" ] || [ -L "$dst" ]; then
        local bak
        bak="${dst}.bak.$(date +%Y%m%d-%H%M%S)"
        cp -a "$dst" "$bak"
        log_info "backed up $dst to $bak"
    fi
    cp "$src" "$dst"
    log_ok "installed $dst"
}
