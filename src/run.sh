#!/bin/bash
set -e

export_base="/exports/"

### Handle `docker stop` for graceful shutdown
function shutdown {
    echo "- Shutting down nfs-server.."
    service nfs-kernel-server stop
    echo "- Nfs server is down"
    exit 0
}

trap "shutdown" SIGTERM
####

echo "Export points:"
echo "$export_base *(rw,sync,insecure,fsid=0,no_subtree_check,no_root_squash)" | tee /etc/exports

read -a exports <<< "${@}"
for export in "${exports[@]}"; do
    src=`echo "$export" | sed 's/^\///'` # trim the first '/' if given in export path
    src="$export_base$src"
    mkdir -p $src
    chmod 777 $src
    echo "$src *(rw,sync,insecure,no_subtree_check,no_root_squash)" | tee -a /etc/exports
done

echo -e "\n- Changing NFS Config.."
sed -i 's/STATDOPTS=/STATDOPTS="--port 32765 --outgoing-port 32766"/g' /etc/default/nfs-common
sed -i 's/RPCMOUNTDOPTS="--manage-gids"/RPCMOUNTDOPTS="--manage-gids -p 32767"/g' /etc/default/nfs-kernel-server

echo -e "\n- Initializing nfs server.."
rpcbind
service nfs-kernel-server start

echo "- Nfs server is up and running.."

## Run until signaled to stop...
while :
do
    sleep 1  # Interupt interval time
done
