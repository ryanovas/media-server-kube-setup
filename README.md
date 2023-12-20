# media-server-kube-setup

This is a repo to keep my kube templates to run a full media server template. I've made it public in case anyone stumbles across it while looking for something similar. This is just a small personal project, so I can't promise any kind of maintenance but I'll be adding enough instructions so that it can be set up easily (likely by myself many moons from now having forgotten everything I did).

My setup involves Radarr, Sonarr, Transmission, Prowlarr, Overseer, and Jellyfin (cause Plex is a heavy, proprietary, privavy-poor headache).

## Setup

1. Make sure you have some kind of Kubernetes installed and configured. I'm just using microk8s on a mini PC.
2. Install kubectl and helm.
3. Configure the various values.yaml files throughout the project - in particular the PersistentVolume related configs
4. Install the chart with `helm install media-server ./media-server-chart`
5. Finally, allow access through your firewall, e.g. `sudo ufw allow 9091,51413,51413/udp` - these must match the params in your values.yaml files

## Troubleshooting

- If anything goes wrong this command is your best friend: `kubectl get events --all-namespaces  --sort-by='.metadata.creationTimestamp'`
- You can easily uninstall the whole setup with `helm uninstall media-server`