#!/bin/bash
#
# setup_environment.sh
#
# This script sets up a user environment by:
#   - Disabling IPv6 at the system level
#   - Creating common directories (`~/src` and `~/bin`)
#   - Cloning the unix-utils repository if not already present
#   - Copying utility scripts to the appropriate locations
#   - Setting up shell aliases in `.bashrc`
#   - Adding `~/bin` to the user's `PATH`
#   - Disabling the system bell (GNOME Terminal & `.inputrc`)
#
# The script ensures **idempotency**, meaning it will not reapply changes
# if they have already been made. It also correctly determines the user's
# home directory when executed via `sudo` and maintains proper file
# ownership.
#
# Usage:
#   Run this script as root:
#     sudo ./setup_environment.sh
#
# Exit codes:
#   0 - Success
#   1 - Script must be run as root
#
# Author: Damian Sullivan
# License: MIT

set -e  # Exit immediately if a command exits with a non-zero status.

# Ensure script is run as root
if [[ $EUID -ne 0 ]]; then
  echo "Error: This script must be run as root." >&2
  exit 1
fi

# Get actual user running the script (fallback to root's home if necessary)
if [[ -z "$SUDO_USER" ]]; then
  USER_HOME="$HOME"
else
  USER_HOME=$(eval echo ~$SUDO_USER)
fi

USER_BIN="$USER_HOME/bin"
USER_SRC="$USER_HOME/src"

# Disable IPv6 if not already set in /etc/sysctl.conf
if ! grep -q "net.ipv6.conf.all.disable_ipv6 = 1" /etc/sysctl.conf; then
  echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
fi

if ! grep -q "net.ipv6.conf.default.disable_ipv6 = 1" /etc/sysctl.conf; then
  echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
fi

if ! grep -q "net.ipv6.conf.lo.disable_ipv6 = 1" /etc/sysctl.conf; then
  echo "net.ipv6.conf.lo.disable_ipv6 = 1" >> /etc/sysctl.conf
fi

# Apply only the specified IPv6 changes
sysctl -w net.ipv6.conf.all.disable_ipv6=1
sysctl -w net.ipv6.conf.default.disable_ipv6=1
sysctl -w net.ipv6.conf.lo.disable_ipv6=1

# Create necessary directories as the user
sudo -u "$SUDO_USER" mkdir -p "$USER_SRC"
sudo -u "$SUDO_USER" mkdir -p "$USER_BIN"

# Clone unix-utils if not already present (run as the user)
if [[ ! -d "$USER_SRC/unix-utils" ]]; then
  sudo -u "$SUDO_USER" git clone \
    https://github.com/DamianSullivan/unix-utils.git "$USER_SRC/unix-utils"
fi

# Copy files only if they do not already exist
[[ -f "$USER_HOME/.bash_eternal_history.sh" ]] || cp \
  "$USER_SRC/unix-utils/bash_eternal_history.sh" "$USER_HOME/.bash_eternal_history.sh"

[[ -f "$USER_HOME/.orange_cursor.sh" ]] || cp \
  "$USER_SRC/unix-utils/orange_cursor.sh" "$USER_HOME/.orange_cursor.sh"

[[ -f "$USER_BIN/rollup" ]] || cp \
  "$USER_SRC/unix-utils/rollup.pl" "$USER_BIN/rollup"

# Ensure correct permissions for rollup script
[[ -f "$USER_BIN/rollup" ]] && chmod 755 "$USER_BIN/rollup"

# Add aliases to .bashrc if not already present
if ! grep -q "source $USER_HOME/.bash_eternal_history.sh" "$USER_HOME/.bashrc"; then
  echo "source $USER_HOME/.bash_eternal_history.sh" >> "$USER_HOME/.bashrc"
fi

if ! grep -q "source $USER_HOME/.orange_cursor.sh" "$USER_HOME/.bashrc"; then
  echo "source $USER_HOME/.orange_cursor.sh" >> "$USER_HOME/.bashrc"
fi

# Ensure ~/bin is in the PATH
if ! grep -q "PATH=\$PATH:$USER_BIN" "$USER_HOME/.bashrc"; then
  echo "PATH=\$PATH:$USER_BIN" >> "$USER_HOME/.bashrc"
fi

# Disable the system bell in ~/.inputrc if not already set
if ! grep -q "set bell-style none" "$USER_HOME/.inputrc"; then
  echo "set bell-style none" >> "$USER_HOME/.inputrc"
fi

# Disable GNOME Terminal bell if gsettings is available
if command -v gsettings &> /dev/null; then
  echo "Disabling GNOME Terminal bell..."
  sudo -u "$SUDO_USER" gsettings set org.gnome.desktop.wm.preferences audible-bell false
  sudo -u "$SUDO_USER" gsettings set org.gnome.desktop.wm.preferences visual-bell false
else
  echo "gsettings not found. Attempting to install it..."
  apt update && apt install -y gsettings-desktop-schemas
  if command -v gsettings &> /dev/null; then
    echo "gsettings installed. Disabling GNOME Terminal bell..."
    sudo -u "$SUDO_USER" gsettings set org.gnome.desktop.wm.preferences audible-bell false
    sudo -u "$SUDO_USER" gsettings set org.gnome.desktop.wm.preferences visual-bell false
  else
    echo "Failed to install gsettings. GNOME Terminal bell not disabled." >&2
  fi
fi

# Correct file ownership if script is run as root and SUDO_USER is set
if [[ -n "$SUDO_USER" ]]; then
  chown -R "$SUDO_USER:$SUDO_USER" "$USER_HOME"
fi

echo "Configuration complete. Please restart your shell for changes to take effect."
exit 0

