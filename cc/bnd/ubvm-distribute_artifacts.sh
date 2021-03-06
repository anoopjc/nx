#!/bin/env bash
# Copyright (c) 2020 Anoop Joe Cyriac

set -ex
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
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

# SCP the created artifacts to CVM's dir ${SSH_CVM_TAR_DIR}
scp_artifacts_to_cvm() {
    ssh "${SSH_CVM}" "mkdir -p ${SSH_CVM_TAR_DIR}"
    scp "${INFRA_SERVER_TAR}" "${SSH_CVM}":"${SSH_CVM_TAR_DIR}"/
    scp "${INFRA_CLIENT_TAR}" "${SSH_CVM}":"${SSH_CVM_TAR_DIR}"/
}

# In CVM, extract the transferred artifact and get the eggs.
cvm-extract_tarred_eggs() {
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

main() {
    print_git_info "${TOP}"
    source_ubvm_common
    cvm-cleanup
    transfer_bndscripts_to_cvm
    scp_artifacts_to_cvm
    cvm-extract_tarred_eggs
    cvm-deploy_eggs_to_all_cvms
}

main
set +ex
