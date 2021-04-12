#!/bin/env bash
# Copyright (c) 2020 Anoop Joe Cyriac

set -ex
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
GLOBALS="${SCRIPT_DIR}/globals.sh"
# shellcheck source="${SCRIPT_DIR}/globals.sh"
source "${GLOBALS}"

# Create a tar out of script dir, transfer it to CVM and extract there into dir
# of ${SSH_CVM_BUILD_SCRIPTS_TAR}
transfer_bndscripts_to_cvm() {
    local tar_file="${TMP_DIR}/${BUILD_SCRIPTS_DIRNAME}.tar.gz"
    local tarring_dir=${SCRIPT_DIR}
    local ssh_cmd

    create-cc_build_scripts-tar "${tar_file}" "${tarring_dir}"
    ssh "${SSH_CVM}" "mkdir -p ${SSH_CVM_SCRIPTS_DIR}"
    scp "${tar_file}" "${SSH_CVM}":"${SSH_CVM_BUILD_SCRIPTS_TAR}"
    ssh_cmd="tar -C $(dirname ${SSH_CVM_BUILD_SCRIPTS_TAR}) "
    ssh_cmd+="-xzf ${SSH_CVM_BUILD_SCRIPTS_TAR}"
    ssh "${SSH_CVM}" "${ssh_cmd}"
}
