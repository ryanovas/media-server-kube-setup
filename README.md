# media-server-kube-setup

This is a repo to keep my kube templates to run a full media server template. I've made it public in case anyone stumbles across it while looking for something similar. This is just a small personal project, so I can't promise any kind of maintenance but I'll be adding enough instructions so that it can be set up easily (likely by myself many moons from now having forgotten everything I did).

My setup involves Radarr, Sonarr, qBittorrent, Prowlarr, Jellyseer, and Jellyfin (cause Plex is a heavy, proprietary, privavy-poor headache). I also include tailscale for exposing services remotely to your tailnet via ingresses. 

I also set up ... for books and audiobooks.

## Setup

1. Make sure you have some kind of Kubernetes installed and configured. I'm using microk8s on a mini PC.
2. Install kubectl and helm.
3. Configure your media folder like described in [this doc](https://trash-guides.info/Hardlinks/How-to-setup-for/Docker/). But please note I have swapped the `data` folder to be `media` and their subfolder `media` to be `library`. See below for a tree of my folders, it would be easiest to simply match my directory and adjust the root folders accordingly in Radarr/Sonarr
3. Configure the various `values.yaml` files throughout the project - in particular the PersistentVolume related configs in the main `values.yaml`
4. Install the chart with `helm install media-server ./media-server-chart`
5. Finally, if necessary, allow access through your firewall, e.g. `sudo ufw allow 9091` - these must match the params in your values.yaml files
6. Follow the setup steps in the GUIs of each software.
7. Lastly, install Jellyfin directly on your computer unless you wanna fuck with getting GPU acceleration into Kubernetes: `curl https://repo.jellyfin.org/install-debuntu.sh | sudo bash`
8. Install tailscale into your kube: https://tailscale.com/kb/1236/kubernetes-operator#installation (please note that on microk8s you need to do the things described in this issue to make it work at the time of writing: https://github.com/canonical/microk8s/issues/3241#issuecomment-1321242714)

## Services Setup Steps

Read the docs of each software for the full details of your setup, but in short:

1. Configure the download location of qBittorrent to be in the `media/torrents/complete` folder
2. Configure Prowlarr to use the indexes you would like (I use 1337, pirate bay, rarbg, yts, limetorrents as recommended across Reddit, though private ones sound better if you can)
3. Tell Prowlarr to connect to each of the various *arr services under settings>apps. You can use the name of the services obtained with `kubectl get services -n media-server` and it will auto-resolve their local IPs
4. In each *arr app, configure the root folder as described in the link I posted in the last section. Configure qBittorrent as the download client. Set whatever other settings you'd like. Set auth to not be required on local network.
5. Bazarr: https://wiki.bazarr.media/Getting-Started/Setup-Guide/
6. This software is highly recommended if you're going to be streaming videos, the fancy file formats can be sketchy or unsupported by chromecast and the like: https://docs.unmanic.app/docs/installation/pip but keep in mind you can't use hardlinks anymore. You'll have to set something up to clean up your torrents folder once in awhile.

## Links if you follow my setup:

- qBittorrent: localhost:30909
- Prowlar: localhost:30969
- Radarr: localhost:30787
- Sonarr: localhost:30898
- Bazarr: localhost:30676
- Jellyseerr: localhost:30505
- LazyLibrarian: localhost:30529
- Calibre Web: localhost:30883

## Using gluetun

Heads up this might be a real pain in the butt. I set mine up with a static IP from Windscribe with port forwarding. There is a good chance you will have to change the template if you choose a different VPN provider and be ready for headaches as gluetun is not easy. If you match my setup, simply change the values in the values.yaml of the service you want to go through gluetun, and double check the outbound subnet CIDR range in the deployment template itself. You must use openvpn for my setup. If you are port forwarding, you don't need to add anything extra, I open all the container ports set in values.yml in gluetun.

Then all that's left is to set Kube secrets with your username and password (or if you aren't gunna commit this change the charts to hardcode it - I'm not your boss). Pro tip, they look a little funky but you're just saving a key/value pair under a name.

`kubectl create secret generic openvpnuser --from-literal=username='whatever' -n media-server`

You will also need to generate an ovpn file from the port forwarding menu and save it in the persistent storage you configured earlier.

## Troubleshooting

- If anything goes wrong this command is your best friend: `kubectl get events --all-namespaces  --sort-by='.metadata.creationTimestamp'`
- You can easily uninstall the whole setup with `helm uninstall media-server`
- Don't get hasty with the uninstall/install command. If you uninstall, wait until it's complete. Check your kube dashboard. (if you're on microk8s like me you can use the proxy command, or set a nodeport on the dashboard pod and configure an admin user. Google it.)
- Sometimes when you boot it shows deployment failure, then all green. It happens when one of the PVCs doesn't mount right away. Check the events before you panic.