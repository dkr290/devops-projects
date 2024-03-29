virt-install \
-n cks-master \
--description "cks-master" \
--os-type Linux \
--os-variant ubuntu22.04 \
--memory 4096 \
--vcpus 2 \
--disk path=/var/lib/libvirt/images/cks-master.qcow2,bus=virtio,size=50 \
--graphics none \
--network network=default,model=virtio \
--location /var/lib/libvirt/images/ubuntu-22.04.2-live-server-amd64.iso,kernel=casper/hwe-vmlinuz,initrd=casper/hwe-initrd \
--noreboot \
--extra-args 'console=ttyS0,115200n8 serial autoinstall'