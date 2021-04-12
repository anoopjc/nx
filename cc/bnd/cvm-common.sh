#!/bin/env bash
# Copyright (c) 2020 Anoop Joe Cyriac

SCRIPT_DIR="$( cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd )"
GLOBALS="${SCRIPT_DIR}/globals.sh"
# shellcheck source="${SCRIPT_DIR}/globals.sh"
source "${GLOBALS}"

_getip() {
    local ip
    ip=$(/sbin/ifconfig eth0 | grep 'inet ' | awk '{ print $2}')
    echo "${ip}"
}

allssh() {
    CMDS=$@
    DEFAULT_OPTS="-q -o LogLevel=ERROR -o StrictHostKeyChecking=no"
    EXTRA_OPTS=${ALLSSH_OPTS-"-t"}
    OPTS="${DEFAULT_OPTS} ${EXTRA_OPTS}"
    for i in $(svmips); do
        if [ "x${i}" == "x${IP}" ]; then
           continue
        fi
        echo "================== ${i} ================="
        /usr/bin/ssh ${OPTS} ${i} "source /etc/profile; export USE_SAFE_RM=yes; $@"
    done
    echo "================== ${IP} ================="
    /usr/bin/ssh ${OPTS} ${i} "source /etc/profile; export USE_SAFE_RM=yes; $@"
}
