# GNOME MLG

![Debian](https://img.shields.io/badge/Debian-supported-A81D33?logo=debian&logoColor=white)
![Devuan](https://img.shields.io/badge/Devuan-supported-9B183E?logo=devuan&logoColor=white)
![GNOME](https://img.shields.io/badge/Desktop-GNOME-3B8EE9?logo=gnome&logoColor=white)
![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)

A small GNOME setup kit. It deploys a portable bash config, installs the few
prerequisites this desktop expects, and stages the bundled theme archive.
Everything runs as a normal user and escalates only the commands that need it.

## Quick start

```bash
git clone https://github.com/SOSMLG/GnomeMLG.git
cd GnomeMLG
./install.sh
```

`install.sh` runs every step with prompts answered yes, then runs the
verifier. Reboot or log out and back in after the bash config is deployed.

For a step-by-step run:

```bash
./run.sh              # prompts before each step
./run.sh --list       # show step names
./run.sh --verify     # audit the current state only
```

## What it does

| Step | Effect |
|---|---|
| `bash` | Copies `configs/bash/.bashrc` to `~/.bashrc`, keeping a timestamped backup. The config uses `$HOME` instead of a fixed username. |
| `apps` | Enables the `i386` architecture, installs `git` and `wget` when missing, and installs oh-my-bash from its upstream installer when `~/.oh-my-bash` is absent. |
| `theme` | Copies `theming.7z` into `$XDG_DATA_HOME/gnome-mlg` (default `~/.local/share/gnome-mlg`). If 7z is installed, it backs up `~/.themes` and extracts the archive there. Otherwise it tells you where to extract it manually. |

The app step never upgrades the whole system and never runs as root. Package
names are checked before install, so steps are safe to re-run.

## Options

| Option | Meaning |
|---|---|
| `--list` | Print step names and exit. |
| `--yes`, `-y` | Accept defaults without prompting. |
| `--full` | Run all steps and then verify. Used by `install.sh`. |
| `--only bash,apps` | Run selected steps. |
| `--no-update` | Skip `apt-get update` in the apps step. |
| `--verify` | Run only the end-state verifier. |
| `-h`, `--help` | Show help. |

Environment overrides:

| Variable | Meaning |
|---|---|
| `GNOMEMLG_PRIV` | Force `sudo` or `doas` as the escalation helper. |
| `GNOMEMLG_SKIP_APT_UPDATE=1` | Skip the apt lists refresh. |
| `GNOMEMLG_OMB_INSTALL=0` | Do not run the oh-my-bash installer. |

## Verification

```bash
./verify.sh
./verify.sh --json
```

The verifier is read-only. It checks the repo payload, the portable bashrc
path, the deployed bashrc, oh-my-bash, the staged theme archive and the i386
architecture. It prints `PASS`, `WARN` or `FAIL` and exits nonzero only on
`FAIL`.

## Layout

```
install.sh                 unattended wrapper
run.sh                     ordered step runner
verify.sh                  read-only end-state verifier
scripts/lib/common.sh      shared helpers (priv, logging, backups)
configs/bash/.bashrc       portable bash config
configs/gnome/GnomeApps.sh app prerequisite step
theming.7z                 bundled theme archive
AGENTS.md                  project conventions
```

## License

MIT. See [LICENSE](LICENSE).

## Related repos

- [DebianSway](https://github.com/SOSMLG/DebianSway): Sway on Debian/Devuan.
- [DevuanSway](https://github.com/SOSMLG/DevuanSway): Sway on Devuan with OpenRC.
- [Devuan-Kde](https://github.com/SOSMLG/Devuan-Kde): KDE Plasma on Devuan.
- [XfceMlg](https://github.com/SOSMLG/XfceMlg): XFCE desktop toolkit.
