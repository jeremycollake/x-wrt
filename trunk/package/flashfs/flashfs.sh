#!/bin/sh
case $1 in
     save)
          tar -czf - -C /tmp/local . | mtd -f write - OpenWrt
          ;;
     load)
          tar -xzf /dev/mtdblock/4 -C /tmp/local
          ;;
        *)
          echo "Usage: $0 (load|save)"
          exit 1
          ;;
esac
exit $?
