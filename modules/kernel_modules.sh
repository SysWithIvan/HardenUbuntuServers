#!/usr/bin/env bash
# ========================================================================
# Tested on:     Ubuntu 24.04 LTS
# Author:        Iván Texenery Díaz García (ivantexenery@gmail.com)
# Version:       1.0.0 (2025-09-15)
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (c) 2025 Iván Texenery Díaz García
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version. See the LICENSE file for details.       
# =======================================================================

# squashfs is used by Ubuntu Snap packages, so we dont't disable them.
# overlayfs  is used by Docker/containerd/Kubernetes and “live-boot” tools, so we dont't disable them.
modules=(cramfs freevxfs hfs hfsplus jffs2 udf usb-storage afs dccp tipc rds sctp)
for module in "${modules[@]}"; do
        echo "install ${module} /bin/false" | sudo tee /etc/modprobe.d/${module}.conf
        echo "blacklist ${module}" | sudo tee -a /etc/modprobe.d/${module}.conf
        sudo modprobe -r ${module} 2>/dev/null
        sudo rmmod ${module} 2>/dev/null
done