#!/bin/env bash
# Copyright (c) 2020 Anoop Joe Cyriac

set -ex
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
GLOBALS="${SCRIPT_DIR}/globals.sh"
# shellcheck source="${SCRIPT_DIR}/globals.sh"
source "${GLOBALS}"
CC_BND_METHOD=${CC_BND_METHOD:-${METHOD_SAFE_BUT_SLOW}}

check_prerequisite() {
    if [ ! -f "${SRC_CHANGED_FILES_LIST}" ]; then
        printf "File:[%s] containing list of changed files not present, exiting!!!\n" "${SRC_CHANGED_FILES_LIST}"
        exit 1
    fi
}

# In CVM, take a back up of the artifact dir, created most probably during a
# previous run, and cleanup the dir to have the latest.
cvm-cleanup() {
    local ssh_cvm_eggs_base_dir=${1:-${CVM_TMP_DIR}}
    local ssh_cmd

    ssh_cmd="rm -rf ${CVM_TMP_DIR}"
    ssh "${SSH_CVM}" "${ssh_cmd}"
}

transfer_ccfiles_to_cvm() {
    local ssh_cvm_eggs_base_dir=${1:-${CVM_TMP_DIR}}

    cd "${TOP}"
    while IFS= read -r ccfile; do
        local scp_relative_filepath
        ccfile=$(remove_redundant_fslash "${ccfile}")
        scp_relative_filepath=$(echo ${ccfile} | sed "s:^$TOP/::" | sed "s:${SRC_CHANGED_FILES_UNWANTED_PATH}::")
        scp "${ccfile}" "${SSH_CVM}":"${ssh_cvm_eggs_base_dir}/${scp_relative_filepath}"
    done < "${SRC_CHANGED_FILES_LIST}"
}

cvm-extract_nx_eggs() {
    ssh -t ${SSH_CVM} "CC_BND_METHOD=${CC_BND_METHOD} bash --login ${SSH_CVM_EXTRACT_NXEGGS_SCRIPT}"

    # Running external scripts can change the state. Making sure it is as
    # expected.
    set -ex
}

main() {
    print_git_info "${TOP}"
    check_prerequisite
    source_ubvm_common
    cvm-cleanup
    transfer_bndscripts_to_cvm
    cvm-extract_nx_eggs
    transfer_ccfiles_to_cvm
    CC_BND_METHOD="${METHOD_UNSAFE_BUT_FAST}" cvm-deploy_eggs_to_all_cvms
}

main
set +ex
