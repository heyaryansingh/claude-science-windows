#!/usr/bin/env bash
#
# ClaudeScience-Server.sh - Multi-user team server manager for Claude Science.
# This script sets up a dedicated Linux server to host Claude Science for multiple users.
#
# Usage:
#   sudo ./ClaudeScience-Server.sh install       - Install base dependencies
#   sudo ./ClaudeScience-Server.sh add <user>    - Provision a new user and start their daemon
#   sudo ./ClaudeScience-Server.sh login <user>  - Generate a secure sign-in link for a user
#   sudo ./ClaudeScience-Server.sh list          - List all users and their ports
#   sudo ./ClaudeScience-Server.sh rm <user>     - Remove a user and purge their data
#

set -eo pipefail

ACCT_PREFIX="csu-"
ACCT_GROUP="csusers"
HOME_BASE="/var/lib/claude-science-server"
PORT_BASE=8010
BIN="/usr/local/bin/claude-science"

die() { echo -e "\033[1;31merror:\033[0m $*" >&2; exit 1; }
say() { echo -e "\033[1;36m==>\033[0m $*"; }

if [ "$EUID" -ne 0 ]; then
  die "Please run this script as root (use sudo)."
fi

cmd_install() {
  say "Installing system dependencies..."
  apt-get update
  env DEBIAN_FRONTEND=noninteractive apt-get install -y ca-certificates curl bubblewrap systemd

  if [ ! -x "$BIN" ]; then
    say "Installing Claude Science binary..."
    tmp=$(mktemp -d)
    curl -fsSL https://claude.ai/install-claude-science.sh | CLAUDE_SCIENCE_INSTALL_DIR="$tmp" bash
    install -m 0755 "$tmp/claude-science" "$BIN"
    rm -rf "$tmp"
  fi

  groupadd -f "$ACCT_GROUP"
  mkdir -p "$HOME_BASE"
  chmod 751 "$HOME_BASE"
  
  say "Install complete! You can now add users: sudo ./ClaudeScience-Server.sh add <username>"
}

cmd_add() {
  local user="$1"
  [[ "$user" =~ ^[a-z0-9-]+$ ]] || die "User name must be lowercase alphanumeric and hyphens."
  
  local acct="${ACCT_PREFIX}${user}"
  if id "$acct" >/dev/null 2>&1; then
    die "User '$user' already exists."
  fi

  # Find next available port
  local port=$PORT_BASE
  while ss -tln | grep -q ":$port "; do
    port=$((port + 1))
  done

  local dd="${HOME_BASE}/${user}"
  say "Provisioning '$user' on port $port..."

  # Create locked unix account
  useradd -r -m -d "$dd" -s /usr/sbin/nologin -g "$ACCT_GROUP" "$acct"
  chmod 700 "$dd"
  chown "${acct}:${ACCT_GROUP}" "$dd"

  # Systemd daemon
  cat <<EOF > "/etc/systemd/system/claude-science-${user}.service"
[Unit]
Description=Claude Science daemon for ${user}
After=network-online.target

[Service]
Type=simple
User=${acct}
Group=${ACCT_GROUP}
Environment=HOME=${dd}
ExecStart=${BIN} serve --no-browser --no-auto-update --data-dir ${dd} --port ${port} --host 0.0.0.0
Restart=always
MemoryMax=8G
CPUQuota=200%
TasksMax=512

[Install]
WantedBy=multi-user.target
EOF

  systemctl daemon-reload
  systemctl enable --now "claude-science-${user}.service"

  say "Provisioned '$user'!"
  say "To get their sign-in link, run: sudo ./ClaudeScience-Server.sh login $user"
}

cmd_login() {
  local user="$1"
  local acct="${ACCT_PREFIX}${user}"
  id "$acct" >/dev/null 2>&1 || die "User '$user' not found."

  local dd="${HOME_BASE}/${user}"
  say "Generating secure sign-in link for '$user'..."
  
  # Fetch URL using the user's account
  local out
  out=$(sudo -u "$acct" "$BIN" url --data-dir "$dd")
  
  # Replace localhost with the server's actual LAN IP
  local ip
  ip=$(hostname -I | awk '{print $1}')
  [ -z "$ip" ] && ip="127.0.0.1"
  
  local url
  url=$(echo "$out" | sed "s/localhost/$ip/g" | sed "s/127.0.0.1/$ip/g")
  
  echo ""
  echo "Send this exact URL to $user securely. They only need to sign in once:"
  echo -e "\033[1;32m$url\033[0m"
  echo ""
}

cmd_list() {
  say "Active Users:"
  printf "%-15s %-10s %s\n" "USER" "PORT" "STATUS"
  echo "--------------------------------------"
  for f in /etc/systemd/system/claude-science-*.service; do
    [[ "$f" == *"-bridge-"* ]] && continue
    [ -e "$f" ] || continue
    
    local name
    name=$(basename "$f" .service | sed 's/claude-science-//')
    
    local port
    port=$(grep -oE -e '--port [0-9]+' "$f" | cut -d' ' -f2 || echo "unknown")
    
    local status
    status=$(systemctl is-active "claude-science-${name}.service" || echo "inactive")
    
    printf "%-15s %-10s %s\n" "$name" "$port" "$status"
  done
}

cmd_rm() {
  local user="$1"
  local acct="${ACCT_PREFIX}${user}"
  id "$acct" >/dev/null 2>&1 || die "User '$user' not found."

  say "Removing user '$user'..."
  systemctl disable --now "claude-science-${user}.service" >/dev/null 2>&1 || true
  
  rm -f "/etc/systemd/system/claude-science-${user}.service"
  systemctl daemon-reload
  
  userdel -r "$acct" >/dev/null 2>&1 || true
  
  say "User '$user' and all their data have been completely removed."
}

if [ $# -eq 0 ]; then
  echo "ClaudeScience-Server.sh - Multi-User Manager"
  echo "Usage: sudo ./ClaudeScience-Server.sh [install | add <user> | login <user> | list | rm <user>]"
  exit 0
fi

COMMAND="$1"
shift

case "$COMMAND" in
  install) cmd_install "$@" ;;
  add)     [ -n "$1" ] || die "Missing user. Usage: add <user>"; cmd_add "$1" ;;
  login)   [ -n "$1" ] || die "Missing user. Usage: login <user>"; cmd_login "$1" ;;
  list)    cmd_list ;;
  rm)      [ -n "$1" ] || die "Missing user. Usage: rm <user>"; cmd_rm "$1" ;;
  *)       die "Unknown command: $COMMAND" ;;
esac
