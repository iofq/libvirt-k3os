# Usage:

Set `$DISK_PATH` to your desired .qcow2 storage location

Set `$K3OS_RAM`, `$K3OS_DISK` and `$K3OS_CPU` to match resource needs

Edit src/k3os_conf.yaml (see [docs](https://github.com/rancher/k3os/blob/master/README.md#configuration))

`k3os.sh` -> Creates a VM with the naming scheme "k3os_[a-z,0-9]{4}"
