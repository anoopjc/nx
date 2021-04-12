#!/bin/env bash
# Copyright (c) 2020 Anoop Joe Cyriac

set -ex
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
GLOBALS="${SCRIPT_DIR}/globals.sh"
# shellcheck source="${SCRIPT_DIR}/globals.sh"
source "${GLOBALS}"

_setup_toolchain() {
    # mounting toolchain-builds defined in fstab
    sudo mount -a
    export TOOLCHAIN_BASE=/mnt/toolchain-builds

    local cur_dir
    cur_dir=$(pwd)
    cd "${TOP}"

    # Create a link to the mounted toolchains.
    # Refer: https://confluence.eng.nutanix.com:8443/display/ES/PHX+Dev+vm+setup
    cd "$(dirname ${TOP})"
    if [ ! -L toolchain-builds ]; then
        ln -s /mnt/toolchain-builds toolchain-builds
    fi
    cd -

    cd "$cur_dir"
}

prepare() {
    # All steps are on pjt main directory
    cd "${TOP}"

    _setup_toolchain
}

cleanup() {
    git clean -fdx && \
    make realclean
}

trigger_build() {
    make -j 33 all_pydeps && \
    make -j 33 all && \
    make -j 33 package && \
    make -j 33 deploy-local 
}


# Creating the egg
main() {
    prepare
    cleanup && \
        trigger_build
}

main
set +ex

