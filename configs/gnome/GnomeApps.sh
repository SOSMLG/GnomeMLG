#!/usr/bin/env bash
# Install the small package set this GNOME setup expects.
# Safe to re-run. Run as a normal user; this script escalates per command.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../scripts/lib/common.sh
source "$SCRIPT_DIR/../../scripts/lib/common.sh"

OMB_INSTALL_URL="https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh"
APT_UPDATED=0

apt_update_once() {
    [ "$APT_UPDATED" -eq 1 ] && return 0
    [ "${GNOMEMLG_SKIP_APT_UPDATE:-0}" = 1 ] && return 0
    priv apt-get update
    APT_UPDATED=1
}

install_pkg() {
    local pkg="$1"
    dpkg -s "$pkg" >/dev/null 2>&1 && return 0
    apt_update_once
    priv apt-get install -y "$pkg"
}

add_i386() {
    if dpkg --print-foreign-architectures 2>/dev/null | grep -qx i386; then
        log_ok "i386 architecture already enabled"
        return 0
    fi
    priv dpkg --add-architecture i386
    log_ok "enabled i386 architecture"
}

install_oh_my_bash() {
    if [ -d "$HOME/.oh-my-bash" ]; then
        log_ok "oh-my-bash already present"
        return 0
    fi
    if [ "${GNOMEMLG_OMB_INSTALL:-1}" != 1 ]; then
        log_warn "oh-my-bash skipped by GNOMEMLG_OMB_INSTALL=0"
        return 0
    fi
    if ! command_exists wget; then
        apt_update_once
        priv apt-get install -y wget
    fi
    log_info "installing oh-my-bash from the upstream installer"
    bash -c "$(wget -qO- "$OMB_INSTALL_URL")"
}

if [ "$(id -u)" -eq 0 ]; then
    log_err "run as a normal user, not root"
    exit 1
fi

add_i386
install_pkg git
install_pkg wget
install_oh_my_bash
