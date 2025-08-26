#!/bin/sh
CONF="$1"; PUBIP="$2"; RPC="$3"; P2P="$4"
sed -i "s#^rpc.laddr.*#rpc.laddr = \\"tcp://0.0.0.0:$RPC\\"#g" "$CONF"
sed -i "s#^p2p.laddr.*#p2p.laddr = \\"tcp://0.0.0.0:$P2P\\"#g" "$CONF"
grep -q "^external_address" "$CONF" && \
  sed -i "s#^external_address.*#external_address = \\"tcp://$PUBIP:$P2P\\"#g" "$CONF" || \
  echo "external_address = \\"tcp://$PUBIP:$P2P\\"" >> "$CONF"