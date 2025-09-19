# squashfs is used by Ubuntu Snap packages, so we dont't disable them.
# overlayfs  is used by Docker/containerd/Kubernetes and “live-boot” tools, so we dont't disable them.
modules=(cramfs freevxfs hfs hfsplus jffs2 udf usb-storage afs dccp tipc rds sctp)
for module in "${modules[@]}"; do
        echo "install ${module} /bin/false" | sudo tee /etc/modprobe.d/${module}.conf
        echo "blacklist ${module}" | sudo tee -a /etc/modprobe.d/${module}.conf
        sudo modprobe -r ${module} 2>/dev/null
        sudo rmmod ${module} 2>/dev/null
done