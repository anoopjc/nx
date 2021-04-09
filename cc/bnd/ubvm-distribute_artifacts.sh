#!/bin/env bash
# Copyright (c) 2020 Anoop Joe Cyriac

set -ex
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
GLOBALS="${SCRIPT_DIR}/globals.sh"
# shellcheck source="${SCRIPT_DIR}/globals.sh"
source "${GLOBALS}"


# In CVM, take a back up of the artifact dir, created most probably during a
# previous run, and cleanup the dir to have the latest.
cvm-cleanup() {
    local ssh_cmd

    ssh_cmd="rm -rf ${SSH_CVM_TAR_BAK_DIR}; cp -rf ${SSH_CVM_TAR_DIR} "
    ssh_cmd+="${SSH_CVM_TAR_BAK_DIR}; rm -rf ${SSH_CVM_TAR_DIR}"
    ssh "${SSH_CVM}" "${ssh_cmd}"
}

# Create a tar out of script dir, transfer it to CVM and extract there into dir
# of ${SSH_CVM_BUILD_SCRIPTS_TAR}
transfer_scripts_to_cvm() {
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

# SCP the created artifacts to CVM's dir ${SSH_CVM_TAR_DIR}  
scp_artifacts_to_cvm() {
    ssh "${SSH_CVM}" "mkdir -p ${SSH_CVM_TAR_DIR}"
    scp "${INFRA_SERVER_TAR}" "${SSH_CVM}":"${SSH_CVM_TAR_DIR}"/
    scp "${INFRA_CLIENT_TAR}" "${SSH_CVM}":"${SSH_CVM_TAR_DIR}"/
}

# In CVM, extract the transferred artifact and get the eggs.
cvm-extract_eggs() {
    local ssh_cmd

    ssh_cmd="rm -rf ${SSH_CVM_EGG_DIR}; mkdir -p ${SSH_CVM_SERVER_EGG_DIR}; "
    ssh_cmd+="mkdir -p ${SSH_CVM_CLIENT_EGG_DIR};"
    ssh "${SSH_CVM}" "${ssh_cmd}"

    ssh_cmd="tar -xzf ${SSH_CVM_INFRA_SERVER_TAR} -C ${SSH_CVM_SERVER_EGG_DIR}; "
    ssh_cmd+="tar -xzf ${SSH_CVM_INFRA_CLIENT_TAR} -C ${SSH_CVM_CLIENT_EGG_DIR};"
    ssh "${SSH_CVM}" "${ssh_cmd}"

    ssh_cmd="ls -la ${SSH_CVM_EGG_DIR} ${SSH_CVM_SERVER_EGG_DIR} "
    ssh_cmd+="${SSH_CVM_CLIENT_EGG_DIR};"
    ssh "${SSH_CVM}" "${ssh_cmd}"
}

# In CVM, the transferred eggs is also transferred to all CVMs and after taking
# a backup of NX eggs, deployed in NX path.
cvm-deploy_eggs_to_all_cvms() {
    # TODO: why even --login have no effect... eg: ${IP} ?
    ssh "${SSH_CVM}" "bash --login ${SSH_CVM_DISTRIBUTE_SCRIPT}"

    # Running external scripts can change the state. Making sure it is as
    # expected.
    set -ex
}

main() {
    cvm-cleanup
    transfer_scripts_to_cvm
    scp_artifacts_to_cvm
    cvm-extract_eggs
    cvm-deploy_eggs_to_all_cvms
}

main
set +ex

