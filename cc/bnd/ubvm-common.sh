#!/bin/env bash
# Copyright (c) 2020 Anoop Joe Cyriac

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
GLOBALS="${SCRIPT_DIR}/globals.sh"
# shellcheck source="${SCRIPT_DIR}/globals.sh"
source "${GLOBALS}"
CC_BND_METHOD=${CC_BND_METHOD:-${METHOD_SAFE_BUT_SLOW}}

# Create a tar out of script dir, transfer it to CVM and extract there into dir
# of ${SSH_CVM_BUILD_SCRIPTS_TAR}
transfer_bndscripts_to_cvm() {
    local tar_file="${TMP_DIR}/${BUILD_SCRIPTS_DIRNAME}.tar.gz"
    local tarring_dir=${SCRIPT_DIR}
    local ssh_cmd

    create-cc_build_scripts-tar "${tar_file}" "${tarring_dir}"
    ssh "${SSH_CVM}" "rm -rf ${SSH_CVM_SCRIPTS_DIR}; mkdir -p ${SSH_CVM_SCRIPTS_DIR}"
    scp "${tar_file}" "${SSH_CVM}":"${SSH_CVM_BUILD_SCRIPTS_TAR}"
    ssh_cmd="tar -C $(dirname ${SSH_CVM_BUILD_SCRIPTS_TAR}) "
    ssh_cmd+="-xzf ${SSH_CVM_BUILD_SCRIPTS_TAR}"
    ssh "${SSH_CVM}" "${ssh_cmd}"
}

# In CVM, the transferred eggs is also transferred to all CVMs and after taking
# a backup of NX eggs, deployed in NX path.
cvm-deploy_eggs_to_all_cvms() {
    # --login OR "source /etc/profile.d/nutanix_env.sh" have no effect... eg: ${IP}, allssh ?
    ssh -t "${SSH_CVM}" "CC_BND_METHOD=${CC_BND_METHOD} bash --login ${SSH_CVM_DISTRIBUTE_SCRIPT}"

    # Running external scripts can change the state. Making sure it is as
    # expected.
    set -ex
}
