# GNOME MLG - project instructions

Small GNOME desktop setup for Debian/Devuan with a Graphite Amber visual
identity. The repo ships a portable bash config, an app prerequisite step,
and a bundled `graphite-amber-theme.7z` archive.

## Entry points

- `install.sh` is the ordered runner. Steps are `bash`, `apps`, `theme`.
- `install.sh` is the unattended wrapper (`install.sh --full`).
- `verify.sh` is the read-only end-state verifier. `install.sh --verify` wraps it.

## Layout

- `configs/bash/.bashrc` is the canonical shell config. Keep it portable:
  use `$HOME`, never a hard-coded username.
- `configs/gnome/GnomeApps.sh` installs the small package set and oh-my-bash.
  Keep package checks idempotent and escalate through `priv()`.
- `graphite-amber-theme.7z` is the real Graphite Amber GTK/Shell/Metacity
  theme archive. It is staged into `$GNOMEMLG_DATA_DIR`, extracted to
  `~/.themes/Graphite-Amber`, and applied with `gsettings` when available.

## Conventions

- Run as a normal user. `scripts/lib/common.sh` owns `priv()`: explicit
  `GNOMEMLG_PRIV`, then sudo, then doas. Do not write bare sudo in new code.
- Back up existing user files before replacing them.
- No systemd units or service calls.
- Keep `verify.sh` read-only; it prints PASS/WARN/FAIL and exits nonzero only
  on FAIL. `--json` is machine-readable.
