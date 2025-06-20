# proxmox
Subscription nag remover for Proxmox 8.4

Note: Make sure to make your script executable (chmod +x sub-nag.sh)

Script checks for v 8.4 or prior, also checks if patch is already applied.
If patch is not applied, a backup of the file is created. Then script searches for first line matching ".data.status.toLowerCase() !== 'active'" and removes the ! in the line.

If you want to undo the patch, replace proxmoxlib.js with proxmoxlib.js.bak in /usr/share/javascript/proxmox-widget-toolkit
