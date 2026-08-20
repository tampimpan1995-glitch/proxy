#!/bin/bash
# Copyright (c) Meta Platforms, Inc. and affiliates.
#
# License found in the LICENSE file in the root directory
# of this source tree.

set -e

CONFIG_FILE="/usr/local/etc/haproxy/haproxy.cfg"
STARTUP_HOOK="/usr/local/etc/haproxy/startup-hook.sh"

# Source an optional deployment-provided hook before starting HAProxy. Sourcing
# lets the hook export environment variables used by the HAProxy configuration.
if [[ -r "$STARTUP_HOOK" ]]; then
    echo "[PROXYHOST] Running configured startup hook"
    # shellcheck source=/dev/null
    source "$STARTUP_HOOK"
fi

# Generate a new certificate for the HTTPS port on each startup.
pushd /home/haproxy/certs
/usr/local/bin/generate-certs.sh
mv proxy.whatsapp.net.pem /etc/haproxy/ssl/proxy.whatsapp.net.pem
chown haproxy:haproxy /etc/haproxy/ssl/proxy.whatsapp.net.pem
popd

# Start HAProxy as the container's main process.
exec haproxy -f "$CONFIG_FILE"
