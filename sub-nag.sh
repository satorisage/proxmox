#!/bin/bash
# Remove no subscription nag from Proxmox 8.4
#
#

JSDIR="/usr/share/javascript/proxmox-widget-toolkit"
JSSCRIPT="proxmoxlib.js"
SCRIPT_PATH="${JSDIR}/${JSSCRIPT}"
BACKUP_PATH="${SCRIPT_PATH}.bak"

### Function: Check if Proxmox version is <= 8.4.x
check_proxmox_version() {
  local version
  version=$(pveversion | grep -oP 'pve-manager/\K[0-9]+\.[0-9]+')

  if [[ -z "$version" ]]; then
    echo "Could not detect Proxmox version." >&2
    return 1
  fi

  local major="${version%%.*}"
  local minor="${version##*.}"

  if (( major < 8 )) || { (( major == 8 )) && (( minor <= 4 )); }; then
    return 0  # OK
  else
    echo "Proxmox version is $version — not applying patch."
    return 1
  fi
}

### Function: Check if patch has been applied
is_patch_present() {
    grep -q "\.data\.status\.toLowerCase() == 'active'" "$SCRIPT_PATH"
}

### Function: Apply the patch
apply_patch() {
  echo "Creating backup: $BACKUP_PATH"
  cp "$SCRIPT_PATH" "$BACKUP_PATH"

  echo "Applying targeted patch to first instance of status check..."

  # In-place edit with sed — replace only the first match
  sed -i "0,/\.data\.status\.toLowerCase() !== 'active'/s//.data.status.toLowerCase() == 'active'/" "$SCRIPT_PATH"

  echo "Restarting PVE Proxy Service..."
  systemctl restart pveproxy.service
}

### Main Logic
main() {
  if ! check_proxmox_version; then
    exit 0  # Clean exit, nothing to do
  fi

  if is_patch_present; then
    echo "Patch already present — skipping."
    exit 0
  fi

  apply_patch
  echo "Patch applied."
}

main
