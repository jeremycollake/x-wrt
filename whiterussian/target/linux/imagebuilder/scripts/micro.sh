#!/bin/sh
LINUX_BUILD_DIR="$1"
rm -f ${LINUX_BUILD_DIR}/lib/modules/2.4.30/sch_htb.o
rm -f ${LINUX_BUILD_DIR}/lib/modules/2.4.30/switch-adm.o
