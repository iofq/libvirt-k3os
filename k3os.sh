#!/bin/bash
#Usage:
#Set DISK_PATH to your desired .qcow2 storage location
#Set K3OS_RAM, K3OS_DISK and K3OS_CPU to match resource needs
#./<name>.sh
#Creates VMs with the naming scheme "k3s_****"

K3OS=k3s_$(head /dev/urandom | tr -dc a-z0-9 | head -c4)
VERSION="v0.20.11-k3s1r1"
[[ -z $DISK_PATH ]] && DISK_PATH=/var/lib/libvirt/images

[[ -z $K3OS_RAM ]] && K3OS_RAM=2048
[[ -z $K3OS_CPU ]] && K3OS_CPU=1
[[ -z $K3OS_DISK ]] && K3OS_DISK=4

kernel_args="\
  k3os.mode=install \
  k3os.fallback_mode=install \
  k3os.install.silent=true \
  init_cmd=\"cp /.base/k3os_conf.yaml /config.yaml\" \
  k3os.install.config_url=/config.yaml \
  k3os.install.iso_url=\"https://github.com/rancher/k3os/releases/download/$VERSION/k3os-amd64.iso\" \
  k3os.install.device=/dev/sda \
  k3os.hostname=${K3OS} \
  k3os.install.debug=true \
  k3os.debug=true \
  "

(( $EUID != 0 )) && echo "Please run as root..." && exit 1

mkdir -p base
[[ -f base/k3os-amd64.iso ]] || \
  curl -L -o base/k3os-amd64.iso https://github.com/rancher/k3os/releases/download/$VERSION/k3os-amd64.iso
[[ -f base/k3os-vmlinuz-amd64 ]] || \
  curl -L -o base/k3os-vmlinuz-amd64 https://github.com/rancher/k3os/releases/download/$VERSION/k3os-vmlinuz-amd64
[[ -f base/k3os-initrd-amd64 ]] || \
  curl -L -o base/k3os-initrd-amd64 https://github.com/rancher/k3os/releases/download/$VERSION/k3os-initrd-amd64
unset VERSION

sed -i "s/hostname:.*/hostname: ${K3OS}/" src/k3os_conf.yaml 

virt-install \
  --name $K3OS \
  --ram $K3OS_RAM \
  --vcpus $K3OS_CPU \
  --os-type linux \
  --os-variant generic \
  --graphics vnc,listen=0.0.0.0 \
  --network bridge=br0,model=virtio \
  --disk path=$VM_DISK_PATH/$K3OS.qcow2,size=$K3OS_DISK,device=disk \
  --disk path=base/k3os-amd64.iso,device=cdrom \
  --install kernel=base/k3os-vmlinuz-amd64,initrd=base/k3os-initrd-amd64 \
  --initrd-inject src/k3os_conf.yaml \
  --extra-args "${kernel_args}" \
  --autostart
