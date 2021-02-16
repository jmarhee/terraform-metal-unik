#!/bin/bash

sleep 360

if [ ! -d /root/src ]; then mkdir /root/src; fi && \
cd /root/src && \
git clone https://github.com/solo-io/unik.git && \
cd unik && \
make && \
mv _build/unik /usr/local/bin/

cat > /root/daemon-config.yaml <<EOF
providers:
  virtualbox:
    - name: my-vbox
      adapter_type: host_only
      adapter_name: NEW_HOST_ONLY_ADAPTER
  qemu:
    - name: my-qemu
      no_graphic: false
EOF

unik target --host localhost && \
ln -s /usr/bin/qemu-system-x86_64 /usr/local/bin/qemu && \
which qemu && \
cat /root/daemon-config.yaml
