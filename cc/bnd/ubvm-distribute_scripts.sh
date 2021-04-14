#!/bin/env bash
# Copyright (c) 2020 Anoop Joe Cyriac

set -ex
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
GLOBALS="${SCRIPT_DIR}/globals.sh"
# shellcheck source="${SCRIPT_DIR}/globals.sh"
source "${GLOBALS}"

check_prerequisite() {
    if [ ! -f "${SRC_CHANGED_FILES_LIST}" ]; then
        printf "File:[%s] containing list of changed files not present, exiting!!!\n" "${SRC_CHANGED_FILES_LIST}"
        exit 1
    fi
}
transfer_ccfiles_to_cvm() {
    cd "${TOP}"
    while IFS= read -r ccfile; do
        ccfile=$(remove_redundant_fslash "${ccfile}")
        scp "${ccfile}"
    done < "${SRC_CHANGED_FILES_LIST}"
}

cvm-extract_nx_eggs() {

}

main() {
    print_git_info "${TOP}"
    check_prerequisite
    source_ubvm_common
    transfer_bndscripts_to_cvm
    transfer_ccfiles_to_cvm
    cvm-extract_nx_eggs
    cvm-deploy_eggs_to_all_cvms
}

main
set +ex
